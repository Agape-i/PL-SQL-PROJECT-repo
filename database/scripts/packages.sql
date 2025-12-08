
-- PACKAGE 1: Farmer Operations Package
CREATE OR REPLACE PACKAGE farmer_operations_pkg AS
    
    -- Cursor types
    TYPE farmer_cursor IS REF CURSOR;
    TYPE delivery_record IS RECORD (
        delivery_id    deliveries.delivery_id%TYPE,
        delivery_date  deliveries.delivery_date%TYPE,
        weight_kg      deliveries.weight_kg%TYPE,
        quality_name   coffee_quality.quality_name%TYPE,
        amount_paid    payments.amount_paid%TYPE
    );
    TYPE delivery_table IS TABLE OF delivery_record;
    
    -- Procedures
    PROCEDURE register_farmer(
        p_full_name   IN VARCHAR2,
        p_phone       IN VARCHAR2,
        p_national_id IN VARCHAR2,
        p_sector      IN VARCHAR2,
        p_farmer_code OUT VARCHAR2
    );
    
    PROCEDURE get_farmer_deliveries(
        p_farmer_id IN NUMBER,
        p_cursor    OUT farmer_cursor
    );
    
    PROCEDURE update_farmer_status(
        p_farmer_id IN NUMBER,
        p_status    IN VARCHAR2
    );
    
    -- Functions
    FUNCTION get_farmer_balance(p_farmer_id IN NUMBER) RETURN NUMBER;
    FUNCTION get_top_farmers(p_limit IN NUMBER DEFAULT 10) RETURN farmer_cursor;
    
    -- Bulk operations
    PROCEDURE process_monthly_statements;
    PROCEDURE generate_yearly_reports(p_year IN NUMBER);
    
END farmer_operations_pkg;
/

CREATE OR REPLACE PACKAGE BODY farmer_operations_pkg AS
    
    PROCEDURE register_farmer(
        p_full_name   IN VARCHAR2,
        p_phone       IN VARCHAR2,
        p_national_id IN VARCHAR2,
        p_sector      IN VARCHAR2,
        p_farmer_code OUT VARCHAR2
    ) IS
        v_farmer_id NUMBER;
    BEGIN
        -- Validate phone
        IF validate_rwanda_phone(p_phone) NOT LIKE 'VALID%' THEN
            RAISE_APPLICATION_ERROR(-20020, 'Invalid phone number format');
        END IF;
        
        -- Generate unique code
        SELECT 'FARM-' || TO_CHAR(SYSDATE, 'YYMM') || '-' || 
               LPAD(farmers_seq.NEXTVAL, 4, '0')
        INTO p_farmer_code FROM dual;
        
        -- Insert with enhanced data
        INSERT INTO farmers (full_name, phone, national_id, sector)
        VALUES (p_full_name, p_phone, p_national_id, p_sector)
        RETURNING farmer_id INTO v_farmer_id;
        
        -- Initial audit log
        INSERT INTO audit_log (username, operation, object_name, object_key,
                              operation_status, reason)
        VALUES (USER, 'INSERT', 'FARMERS', 
                'FARMER_ID=' || v_farmer_id,
                'ALLOWED', 'Registered with code ' || p_farmer_code);
        
        COMMIT;
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20021, 'Duplicate farmer detected');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END register_farmer;
    
    PROCEDURE get_farmer_deliveries(
        p_farmer_id IN NUMBER,
        p_cursor    OUT farmer_cursor
    ) IS
    BEGIN
        OPEN p_cursor FOR
        SELECT 
            d.delivery_id,
            d.delivery_date,
            d.weight_kg,
            cq.quality_name,
            p.amount_paid,
            RANK() OVER (ORDER BY d.weight_kg DESC) AS weight_rank,
            ROUND(p.amount_paid / d.weight_kg, 2) AS price_per_kg,
            LAG(d.weight_kg) OVER (ORDER BY d.delivery_date) AS prev_weight,
            d.weight_kg - LAG(d.weight_kg) OVER (ORDER BY d.delivery_date) AS weight_change
        FROM deliveries d
        JOIN coffee_quality cq ON d.quality_id = cq.quality_id
        LEFT JOIN payments p ON d.delivery_id = p.delivery_id
        WHERE d.farmer_id = p_farmer_id
        ORDER BY d.delivery_date DESC;
        
    END get_farmer_deliveries;
    
    FUNCTION get_farmer_balance(p_farmer_id IN NUMBER) RETURN NUMBER IS
        v_total_earnings NUMBER := 0;
        v_total_paid     NUMBER := 0;
        v_balance        NUMBER := 0;
    BEGIN
        -- Calculate earnings from all deliveries
        SELECT COALESCE(SUM(p.amount_paid), 0)
        INTO v_total_earnings
        FROM deliveries d
        JOIN payments p ON d.delivery_id = p.delivery_id
        WHERE d.farmer_id = p_farmer_id;
        
        -- Calculate any deductions or advances (future enhancement)
        -- For now, balance = total earnings
        
        RETURN v_total_earnings;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_farmer_balance;
    
    FUNCTION get_top_farmers(p_limit IN NUMBER DEFAULT 10) RETURN farmer_cursor IS
        v_cursor farmer_cursor;
    BEGIN
        OPEN v_cursor FOR
        WITH farmer_stats AS (
            SELECT 
                f.farmer_id,
                f.full_name,
                f.sector,
                COUNT(d.delivery_id) AS total_deliveries,
                SUM(d.weight_kg) AS total_weight,
                SUM(p.amount_paid) AS total_earnings,
                ROUND(AVG(d.weight_kg), 2) AS avg_weight,
                RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS earnings_rank,
                DENSE_RANK() OVER (ORDER BY SUM(d.weight_kg) DESC) AS weight_rank,
                calculate_farmer_score(f.farmer_id) AS farmer_score
            FROM farmers f
            LEFT JOIN deliveries d ON f.farmer_id = d.farmer_id
            LEFT JOIN payments p ON d.delivery_id = p.delivery_id
            GROUP BY f.farmer_id, f.full_name, f.sector
        )
        SELECT *
        FROM farmer_stats
        WHERE earnings_rank <= p_limit
        ORDER BY earnings_rank;
        
        RETURN v_cursor;
    END get_top_farmers;
    
    PROCEDURE process_monthly_statements IS
        TYPE farmer_tab IS TABLE OF farmers.farmer_id%TYPE;
        v_farmers farmer_tab;
        
        CURSOR farmer_cursor IS
            SELECT farmer_id FROM farmers WHERE status = 'ACTIVE';
    BEGIN
        -- Use BULK COLLECT for performance
        OPEN farmer_cursor;
        FETCH farmer_cursor BULK COLLECT INTO v_farmers;
        CLOSE farmer_cursor;
        
        -- Process each farmer (could be parallelized)
        FOR i IN 1..v_farmers.COUNT LOOP
            DECLARE
                v_balance NUMBER := get_farmer_balance(v_farmers(i));
                v_statement CLOB;
            BEGIN
                -- Generate statement (simplified)
                v_statement := 'Monthly Statement for Farmer ID: ' || v_farmers(i) ||
                               CHR(10) || 'Balance: ' || v_balance ||
                               CHR(10) || 'Generated on: ' || SYSDATE;
                
                -- Store statement (future enhancement: statement table)
                DBMS_OUTPUT.PUT_LINE(v_statement);
                
                -- Log statement generation
                INSERT INTO audit_log (username, operation, object_name, object_key,
                                      operation_status, reason)
                VALUES (USER, 'STATEMENT', 'FARMERS', 
                        'FARMER_ID=' || v_farmers(i),
                        'ALLOWED', 'Monthly statement generated');
            END;
        END LOOP;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Processed statements for ' || v_farmers.COUNT || ' farmers');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END process_monthly_statements;
    
    PROCEDURE update_farmer_status(
        p_farmer_id IN NUMBER,
        p_status    IN VARCHAR2
    ) IS
    BEGIN
        UPDATE farmers 
        SET status = p_status
        WHERE farmer_id = p_farmer_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'Farmer not found');
        END IF;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_farmer_status;
    
    PROCEDURE generate_yearly_reports(p_year IN NUMBER) IS
        v_report CLOB;
    BEGIN
        -- Generate comprehensive yearly report
        v_report := 'YEARLY REPORT ' || p_year || CHR(10) ||
                   '====================' || CHR(10);
        
        -- Add statistics
        SELECT 
            'Total Farmers: ' || COUNT(*) || CHR(10) ||
            'Total Deliveries: ' || SUM(delivery_count) || CHR(10) ||
            'Total Weight: ' || SUM(total_weight) || ' kg' || CHR(10) ||
            'Total Payments: ' || SUM(total_payments) || ' RWF' || CHR(10) ||
            'Avg Farmer Score: ' || ROUND(AVG(farmer_score), 2)
        INTO v_report
        FROM (
            SELECT 
                COUNT(DISTINCT f.farmer_id) AS farmer_count,
                COUNT(d.delivery_id) AS delivery_count,
                SUM(d.weight_kg) AS total_weight,
                SUM(p.amount_paid) AS total_payments,
                calculate_farmer_score(f.farmer_id) AS farmer_score
            FROM farmers f
            LEFT JOIN deliveries d ON f.farmer_id = d.farmer_id 
                AND EXTRACT(YEAR FROM d.delivery_date) = p_year
            LEFT JOIN payments p ON d.delivery_id = p.delivery_id
        );
        
        DBMS_OUTPUT.PUT_LINE(v_report);
        
        -- Store report (future enhancement: reports table)
        INSERT INTO audit_log (username, operation, object_name,
                              operation_status, reason)
        VALUES (USER, 'REPORT', 'SYSTEM', 'ALLOWED',
                'Yearly report generated for ' || p_year);
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END generate_yearly_reports;
    
END farmer_operations_pkg;
/

-- PACKAGE 2: Analytics Package with Window Functions
CREATE OR REPLACE PACKAGE analytics_pkg AS
    
    -- Window function analytics
    FUNCTION get_delivery_trends RETURN SYS_REFCURSOR;
    FUNCTION get_seasonal_analysis(p_year IN NUMBER) RETURN SYS_REFCURSOR;
    PROCEDURE calculate_moving_averages;
    
    -- Advanced analytics
    FUNCTION detect_anomalies RETURN SYS_REFCURSOR;
    FUNCTION predict_yield(p_farmer_id IN NUMBER) RETURN NUMBER;
    
END analytics_pkg;
/

CREATE OR REPLACE PACKAGE BODY analytics_pkg AS
    
    FUNCTION get_delivery_trends RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        WITH daily_totals AS (
            SELECT 
                TRUNC(delivery_date) AS delivery_day,
                SUM(weight_kg) AS daily_weight,
                COUNT(*) AS daily_deliveries,
                SUM(amount_paid) AS daily_revenue
            FROM deliveries d
            LEFT JOIN payments p ON d.delivery_id = p.delivery_id
            GROUP BY TRUNC(delivery_date)
        )
        SELECT 
            delivery_day,
            daily_weight,
            daily_deliveries,
            daily_revenue,
            SUM(daily_weight) OVER (ORDER BY delivery_day) AS cumulative_weight,
            AVG(daily_weight) OVER (ORDER BY delivery_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS weekly_avg_weight,
            LAG(daily_weight) OVER (ORDER BY delivery_day) AS prev_day_weight,
            ROUND((daily_weight - LAG(daily_weight) OVER (ORDER BY delivery_day)) / 
                  LAG(daily_weight) OVER (ORDER BY delivery_day) * 100, 2) AS growth_percent
        FROM daily_totals
        ORDER BY delivery_day DESC;
        
        RETURN v_cursor;
    END get_delivery_trends;
    
    FUNCTION detect_anomalies RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        WITH delivery_stats AS (
            SELECT 
                farmer_id,
                AVG(weight_kg) AS avg_weight,
                STDDEV(weight_kg) AS std_weight
            FROM deliveries
            GROUP BY farmer_id
        ),
        anomalies AS (
            SELECT 
                d.delivery_id,
                d.farmer_id,
                d.weight_kg,
                ds.avg_weight,
                ds.std_weight,
                ROUND((d.weight_kg - ds.avg_weight) / ds.std_weight, 2) AS z_score,
                CASE 
                    WHEN ABS((d.weight_kg - ds.avg_weight) / ds.std_weight) > 2.5
                    THEN 'SUSPICIOUS'
                    ELSE 'NORMAL'
                END AS anomaly_status
            FROM deliveries d
            JOIN delivery_stats ds ON d.farmer_id = ds.farmer_id
            WHERE ds.std_weight > 0  -- Avoid division by zero
        )
        SELECT *
        FROM anomalies
        WHERE anomaly_status = 'SUSPICIOUS'
        ORDER BY ABS(z_score) DESC;
        
        RETURN v_cursor;
    END detect_anomalies;
    
    FUNCTION predict_yield(p_farmer_id IN NUMBER) RETURN NUMBER IS
        v_predicted_yield NUMBER;
    BEGIN
        -- Simple linear regression prediction
        WITH delivery_history AS (
            SELECT 
                ROWNUM AS seq,
                weight_kg,
                delivery_date
            FROM deliveries
            WHERE farmer_id = p_farmer_id
            ORDER BY delivery_date
        ),
        regression AS (
            SELECT 
                COUNT(*) AS n,
                SUM(seq) AS sum_x,
                SUM(weight_kg) AS sum_y,
                SUM(seq * weight_kg) AS sum_xy,
                SUM(seq * seq) AS sum_xx
            FROM delivery_history
