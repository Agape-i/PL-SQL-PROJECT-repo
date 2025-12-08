
-- FUNCTION 1: Calculate Farmer Credit Score

CREATE OR REPLACE FUNCTION calculate_farmer_score(
    p_farmer_id IN NUMBER
) RETURN NUMBER
IS
    v_total_score NUMBER := 100; -- Base score
    v_consistency_score NUMBER;
    v_quality_score NUMBER;
    v_volume_score NUMBER;
    v_penalty_score NUMBER := 0;
BEGIN
    -- Consistency: Standard deviation of delivery weights
    SELECT 
        CASE 
            WHEN STDDEV(weight_kg) < 10 THEN 20
            WHEN STDDEV(weight_kg) < 20 THEN 15
            WHEN STDDEV(weight_kg) < 30 THEN 10
            ELSE 5
        END
    INTO v_consistency_score
    FROM deliveries
    WHERE farmer_id = p_farmer_id
    GROUP BY farmer_id;
    
    -- Quality: Percentage of Grade A deliveries
    SELECT 
        CASE 
            WHEN COUNT(*) = 0 THEN 0
            ELSE (COUNT(CASE WHEN quality_id = 1 THEN 1 END) / COUNT(*)) * 30
        END
    INTO v_quality_score
    FROM deliveries
    WHERE farmer_id = p_farmer_id;
    
    -- Volume: Total weight delivered
    SELECT 
        CASE 
            WHEN SUM(weight_kg) > 1000 THEN 30
            WHEN SUM(weight_kg) > 500 THEN 25
            WHEN SUM(weight_kg) > 200 THEN 20
            WHEN SUM(weight_kg) > 100 THEN 15
            ELSE 10
        END
    INTO v_volume_score
    FROM deliveries
    WHERE farmer_id = p_farmer_id;
    
    -- Penalties: Alerts and anomalies
    SELECT COUNT(*) * 5 INTO v_penalty_score
    FROM alerts a
    JOIN deliveries d ON a.delivery_id = d.delivery_id
    WHERE d.farmer_id = p_farmer_id;
    
    -- Calculate final score (0-100 scale)
    v_total_score := LEAST(GREATEST(
        v_consistency_score + v_quality_score + v_volume_score - v_penalty_score, 
        0), 100);
    
    RETURN ROUND(v_total_score, 2);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- New farmer
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

-- FUNCTION 2: Predict Next Delivery Date
-- INNOVATION: Machine learning-like prediction based on patterns
CREATE OR REPLACE FUNCTION predict_next_delivery(
    p_farmer_id IN NUMBER
) RETURN DATE
IS
    v_avg_interval NUMBER;
    v_last_delivery DATE;
    v_predicted_date DATE;
BEGIN
    -- Get average days between deliveries
    WITH delivery_intervals AS (
        SELECT 
            delivery_date,
            LAG(delivery_date) OVER (ORDER BY delivery_date) AS prev_date,
            delivery_date - LAG(delivery_date) OVER (ORDER BY delivery_date) AS days_between
        FROM deliveries
        WHERE farmer_id = p_farmer_id
    )
    SELECT AVG(days_between), MAX(delivery_date)
    INTO v_avg_interval, v_last_delivery
    FROM delivery_intervals
    WHERE days_between IS NOT NULL;
    
    -- If no history, predict 14 days from now
    IF v_avg_interval IS NULL THEN
        v_predicted_date := SYSDATE + 14;
    ELSE
        v_predicted_date := v_last_delivery + v_avg_interval;
    END IF;
    
    -- Adjust for weekends (deliveries only on weekdays)
    WHILE TO_CHAR(v_predicted_date, 'DY') IN ('SAT', 'SUN') LOOP
        v_predicted_date := v_predicted_date + 1;
    END LOOP;
    
    RETURN v_predicted_date;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN SYSDATE + 14; -- Default prediction
END;
/

-- FUNCTION 3: Calculate Seasonal Price Adjustment
-- INNOVATION: Dynamic pricing based on season and supply
CREATE OR REPLACE FUNCTION calculate_seasonal_price(
    p_quality_id IN NUMBER,
    p_delivery_date IN DATE DEFAULT SYSDATE
) RETURN NUMBER
IS
    v_base_price NUMBER;
    v_season_factor NUMBER := 1.0;
    v_month NUMBER := EXTRACT(MONTH FROM p_delivery_date);
BEGIN
    -- Get base price
    SELECT price_per_kg INTO v_base_price
    FROM coffee_quality
    WHERE quality_id = p_quality_id;
    
    -- Apply seasonal adjustments
    CASE 
        WHEN v_month IN (3, 4, 5) THEN    -- Peak harvest season
            v_season_factor := 0.95;       -- 5% discount (high supply)
        WHEN v_month IN (6, 7, 8) THEN    -- Low season
            v_season_factor := 1.10;       -- 10% premium (low supply)
        WHEN v_month IN (12, 1, 2) THEN   -- Holiday season
            v_season_factor := 1.15;       -- 15% premium (high demand)
        ELSE                               -- Normal season
            v_season_factor := 1.0;
    END CASE;
    
    -- Apply random market fluctuation (±2%)
    v_season_factor := v_season_factor * (0.98 + DBMS_RANDOM.VALUE(0, 0.04));
    
    RETURN ROUND(v_base_price * v_season_factor, 2);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

-- FUNCTION 4: Validate Phone Number (Rwanda-specific)
-- INNOVATION: Country-specific validation with carrier detection
CREATE OR REPLACE FUNCTION validate_rwanda_phone(
    p_phone IN VARCHAR2
) RETURN VARCHAR2
IS
    v_clean_phone VARCHAR2(20);
    v_carrier VARCHAR2(50);
BEGIN
    -- Remove spaces and special characters
    v_clean_phone := REGEXP_REPLACE(p_phone, '[^0-9]', '');
    
    -- Check length and format
    IF LENGTH(v_clean_phone) NOT IN (9, 10) THEN
        RETURN 'ERROR: Invalid length';
    END IF;
    
    -- Check Rwanda prefixes
    IF NOT REGEXP_LIKE(v_clean_phone, '^(07|78|79|72|73)') THEN
        RETURN 'ERROR: Invalid Rwanda prefix';
    END IF;
    
    -- Detect carrier
    CASE 
        WHEN v_clean_phone LIKE '07%' OR v_clean_phone LIKE '78%' THEN
            v_carrier := 'MTN Rwanda';
        WHEN v_clean_phone LIKE '072%' OR v_clean_phone LIKE '073%' THEN
            v_carrier := 'Airtel Rwanda';
        WHEN v_clean_phone LIKE '079%' THEN
            v_carrier := 'Liquid Telecom';
        ELSE
            v_carrier := 'Unknown Carrier';
    END CASE;
    
    RETURN 'VALID: ' || v_carrier || ' (' || v_clean_phone || ')';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: Validation failed';
END;
/

-- FUNCTION 5: Calculate Carbon Footprint Savings
-- INNOVATION: Sustainability metric for farmers
CREATE OR REPLACE FUNCTION calculate_carbon_savings(
    p_farmer_id IN NUMBER,
    p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
) RETURN NUMBER
IS
    v_total_weight NUMBER;
    v_carbon_per_kg CONSTANT NUMBER := 0.5; -- kg CO2 saved per kg coffee
    v_trees_equivalent NUMBER;
BEGIN
    -- Get total coffee delivered in year
    SELECT COALESCE(SUM(weight_kg), 0)
    INTO v_total_weight
    FROM deliveries
    WHERE farmer_id = p_farmer_id
      AND EXTRACT(YEAR FROM delivery_date) = p_year;
    
    -- Calculate CO2 savings
    v_trees_equivalent := (v_total_weight * v_carbon_per_kg) / 21.77;
    -- 1 tree absorbs ~21.77 kg CO2 per year
    
    RETURN ROUND(v_trees_equivalent, 2); -- Equivalent number of trees
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
/
