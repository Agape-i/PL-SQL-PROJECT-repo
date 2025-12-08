
--  PROCEDURES  


CREATE OR REPLACE PROCEDURE register_farmer(
    p_full_name      IN VARCHAR2,
    p_phone          IN VARCHAR2,
    p_national_id    IN VARCHAR2,
    p_sector         IN VARCHAR2,
    p_farmer_code    OUT VARCHAR2,
    p_status         OUT VARCHAR2
)
IS
    v_farmer_id    NUMBER;
    v_count        NUMBER;
    v_farmer_code  VARCHAR2(20);
    v_username     VARCHAR2(100) := USER;
BEGIN
    -- Check for duplicate national ID or phone
    SELECT COUNT(*) INTO v_count
    FROM farmers 
    WHERE national_id = p_national_id OR phone = p_phone;
    
    IF v_count > 0 THEN
        p_status := 'ERROR: Farmer already registered';
        RAISE_APPLICATION_ERROR(-20010, p_status);
    END IF;
    
    -- Generate unique farmer code (e.g., FARM-001-RW)
    SELECT 'FARM-' || LPAD(farmers_seq.NEXTVAL, 3, '0') || '-RW'
    INTO v_farmer_code FROM dual;
    
    -- Insert farmer
    INSERT INTO farmers (full_name, phone, national_id, sector)
    VALUES (p_full_name, p_phone, p_national_id, p_sector)
    RETURNING farmer_id INTO v_farmer_id;
    
    -- Log successful registration
    INSERT INTO audit_log (username, operation, object_name, object_key, 
                          operation_status, reason)
    VALUES (v_username, 'INSERT', 'FARMERS', 
            'FARMER_ID=' || v_farmer_id || ',CODE=' || v_farmer_code,
            'ALLOWED', 'New farmer registered successfully');
    
    p_farmer_code := v_farmer_code;
    p_status := 'SUCCESS: Farmer registered with code ' || v_farmer_code;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        RAISE;
END;
/

-- PROCEDURE 2: Record Delivery with Anomaly Detection
-- INNOVATION: Detects suspicious weights, auto-generates alerts
CREATE OR REPLACE PROCEDURE record_delivery(
    p_farmer_id      IN NUMBER,
    p_weight_kg      IN NUMBER,
    p_quality_id     IN NUMBER,
    p_delivery_id    OUT NUMBER,
    p_alert_message  OUT VARCHAR2
)
IS
    v_avg_weight  NUMBER;
    v_threshold   NUMBER := 50; -- 50% threshold for anomaly
    v_username    VARCHAR2(100) := USER;
BEGIN
    -- Get farmer's average delivery weight
    SELECT AVG(weight_kg) INTO v_avg_weight
    FROM deliveries 
    WHERE farmer_id = p_farmer_id;
    
    -- Check for weight anomaly (first delivery or >50% deviation)
    IF v_avg_weight IS NOT NULL AND 
       ABS(p_weight_kg - v_avg_weight) / v_avg_weight * 100 > v_threshold THEN
        
        p_alert_message := 'WARNING: Weight anomaly detected. ';
        p_alert_message := p_alert_message || 'Expected ~' || ROUND(v_avg_weight, 2) || 'kg, got ' || p_weight_kg || 'kg';
        
        -- Create alert record
        INSERT INTO alerts (delivery_id, alert_type, description)
        VALUES (deliveries_seq.CURRVAL, 'WEIGHT_ANOMALY', p_alert_message);
    ELSE
        p_alert_message := 'OK: Normal delivery recorded';
    END IF;
    
    -- Record delivery
    INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id)
    VALUES (p_farmer_id, SYSDATE, p_weight_kg, p_quality_id)
    RETURNING delivery_id INTO p_delivery_id;
    
    -- Auto-generate payment
    INSERT INTO payments (delivery_id) VALUES (p_delivery_id);
    
    -- Log to audit
    INSERT INTO audit_log (username, operation, object_name, object_key,
                          operation_status, reason)
    VALUES (v_username, 'INSERT', 'DELIVERIES', 
            'DELIVERY_ID=' || p_delivery_id,
            'ALLOWED', 'Delivery recorded with weight ' || p_weight_kg || 'kg');
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_alert_message := 'ERROR: ' || SQLERRM;
        RAISE;
END;
/

-- PROCEDURE 3: Process Bulk Payments with Performance Optimization
-- INNOVATION: Bulk processing, skip weekends/holidays, performance metrics
CREATE OR REPLACE PROCEDURE process_bulk_payments(
    p_start_date IN DATE,
    p_end_date   IN DATE,
    p_payments_processed OUT NUMBER,
    p_total_amount      OUT NUMBER
)
IS
    TYPE delivery_tab IS TABLE OF deliveries.delivery_id%TYPE;
    v_deliveries delivery_tab;
    
    v_is_holiday  NUMBER;
    v_day_of_week VARCHAR2(3);
BEGIN
    -- Check if today is a weekday and not holiday
    v_day_of_week := TO_CHAR(SYSDATE, 'DY');
    
    SELECT COUNT(*) INTO v_is_holiday
    FROM holidays 
    WHERE holiday_date = TRUNC(SYSDATE);
    
    IF v_day_of_week IN ('SAT', 'SUN') OR v_is_holiday > 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 
            'Payments cannot be processed on weekends or holidays');
    END IF;
    
    -- Find deliveries without payments in date range
    SELECT delivery_id 
    BULK COLLECT INTO v_deliveries
    FROM deliveries d
    WHERE d.delivery_date BETWEEN p_start_date AND p_end_date
      AND NOT EXISTS (
          SELECT 1 FROM payments p 
          WHERE p.delivery_id = d.delivery_id
      );
    
    -- Bulk insert payments (FAST performance)
    FORALL i IN 1..v_deliveries.COUNT
        INSERT INTO payments (delivery_id) 
        VALUES (v_deliveries(i));
    
    -- Calculate totals
    p_payments_processed := SQL%ROWCOUNT;
    
    SELECT SUM(amount_paid) INTO p_total_amount
    FROM payments 
    WHERE delivery_id IN (SELECT * FROM TABLE(v_deliveries));
    
    -- Log bulk operation
    INSERT INTO audit_log (username, operation, object_name, 
                          operation_status, reason)
    VALUES (USER, 'BULK_INSERT', 'PAYMENTS', 'ALLOWED',
            'Processed ' || p_payments_processed || 
            ' payments totaling ' || p_total_amount);
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- PROCEDURE 4: Generate Farmer Performance Report
-- INNOVATION: Comprehensive analytics, ranking, trend analysis
CREATE OR REPLACE PROCEDURE generate_farmer_report(
    p_farmer_id IN NUMBER,
    p_report OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN p_report FOR
    WITH farmer_stats AS (
        SELECT 
            f.farmer_id,
            f.full_name,
            f.sector,
            COUNT(d.delivery_id) AS total_deliveries,
            SUM(d.weight_kg) AS total_weight,
            SUM(p.amount_paid) AS total_earnings,
            AVG(d.weight_kg) AS avg_delivery_weight,
            MAX(d.weight_kg) AS max_delivery_weight,
            MIN(d.weight_kg) AS min_delivery_weight
        FROM farmers f
        LEFT JOIN deliveries d ON f.farmer_id = d.farmer_id
        LEFT JOIN payments p ON d.delivery_id = p.delivery_id
        WHERE f.farmer_id = p_farmer_id
        GROUP BY f.farmer_id, f.full_name, f.sector
    ),
    quality_breakdown AS (
        SELECT 
            cq.quality_name,
            COUNT(d.delivery_id) AS deliveries_count,
            SUM(d.weight_kg) AS total_weight,
            ROUND(AVG(d.weight_kg), 2) AS avg_weight
        FROM deliveries d
        JOIN coffee_quality cq ON d.quality_id = cq.quality_id
        WHERE d.farmer_id = p_farmer_id
        GROUP BY cq.quality_name
    ),
    monthly_trend AS (
        SELECT 
            TO_CHAR(d.delivery_date, 'YYYY-MM') AS delivery_month,
            COUNT(d.delivery_id) AS deliveries,
            SUM(d.weight_kg) AS total_weight,
            SUM(p.amount_paid) AS total_earnings
        FROM deliveries d
        LEFT JOIN payments p ON d.delivery_id = p.delivery_id
        WHERE d.farmer_id = p_farmer_id
        GROUP BY TO_CHAR(d.delivery_date, 'YYYY-MM')
        ORDER BY delivery_month DESC
    )
    SELECT 
        fs.*,
        (SELECT quality_name FROM quality_breakdown WHERE ROWNUM = 1) AS top_quality,
        (SELECT total_weight FROM quality_breakdown WHERE ROWNUM = 1) AS top_quality_weight,
        (SELECT * FROM monthly_trend WHERE ROWNUM = 1) AS recent_month
    FROM farmer_stats fs;
    
    -- Log report generation
    INSERT INTO audit_log (username, operation, object_name, object_key,
                          operation_status, reason)
    VALUES (USER, 'REPORT', 'FARMERS', 'FARMER_ID=' || p_farmer_id,
            'ALLOWED', 'Performance report generated');
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/

-- PROCEDURE 5: Data Maintenance and Archiving
-- INNOVATION: Smart archiving, data retention policy, performance cleanup
CREATE OR REPLACE PROCEDURE archive_old_data(
    p_months_to_keep IN NUMBER DEFAULT 24
)
IS
    v_cutoff_date DATE := ADD_MONTHS(SYSDATE, -p_months_to_keep);
    v_rows_archived NUMBER := 0;
BEGIN
    -- Archive old audit logs
    INSERT INTO audit_log_archive
    SELECT * FROM audit_log 
    WHERE log_timestamp < v_cutoff_date;
    
    v_rows_archived := v_rows_archived + SQL%ROWCOUNT;
    
    DELETE FROM audit_log 
    WHERE log_timestamp < v_cutoff_date;
    
    -- Archive old deliveries (keep only summary)
    INSERT INTO deliveries_summary_archive
    SELECT 
        farmer_id,
        EXTRACT(YEAR FROM delivery_date) AS delivery_year,
        EXTRACT(MONTH FROM delivery_date) AS delivery_month,
        COUNT(*) AS total_deliveries,
        SUM(weight_kg) AS total_weight,
        SYSDATE AS archived_date
    FROM deliveries
    WHERE delivery_date < v_cutoff_date
    GROUP BY farmer_id, EXTRACT(YEAR FROM delivery_date), 
             EXTRACT(MONTH FROM delivery_date);
    
    v_rows_archived := v_rows_archived + SQL%ROWCOUNT;
    
    -- Log archiving operation
    INSERT INTO audit_log (username, operation, object_name,
                          operation_status, reason)
    VALUES (USER, 'ARCHIVE', 'SYSTEM',
            'ALLOWED', 'Archived ' || v_rows_archived || 
            ' rows older than ' || p_months_to_keep || ' months');
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Archived ' || v_rows_archived || ' old records');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
