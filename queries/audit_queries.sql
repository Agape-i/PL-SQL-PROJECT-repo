
-- AUDIT AND COMPLIANCE QUERIES
-- Monitoring and compliance reporting
-- 1. Audit Log Summary by User
SELECT 
    username,
    COUNT(*) AS total_operations,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed_ops,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_ops,
    MIN(log_timestamp) AS first_operation,
    MAX(log_timestamp) AS last_operation,
    ROUND(AVG(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) * 100, 2) AS denial_rate_pct
FROM audit_log
GROUP BY username
ORDER BY total_operations DESC;

-- 2. Compliance Report: Weekday/Holiday Attempts
SELECT 
    TO_CHAR(log_timestamp, 'YYYY-MM-DD') AS date,
    TO_CHAR(log_timestamp, 'DAY') AS day_of_week,
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_attempts,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed_attempts,
    STRING_AGG(DISTINCT object_name, ', ') AS objects_affected
FROM audit_log
WHERE reason LIKE '%weekday%' OR reason LIKE '%holiday%'
GROUP BY TO_CHAR(log_timestamp, 'YYYY-MM-DD'), TO_CHAR(log_timestamp, 'DAY')
ORDER BY date DESC;

-- 3. Operation Analysis by Object
SELECT 
    object_name,
    operation,
    COUNT(*) AS operation_count,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed_count,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_count,
    ROUND(SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS denial_rate_pct
FROM audit_log
GROUP BY object_name, operation
ORDER BY operation_count DESC;

-- 4. Anomaly Detection Report
SELECT 
    TO_CHAR(a.alert_date, 'YYYY-MM-DD') AS alert_date,
    a.alert_type,
    COUNT(*) AS alert_count,
    STRING_AGG(DISTINCT f.full_name, ', ') AS affected_farmers,
    STRING_AGG(DISTINCT a.description, ' | ') AS descriptions
FROM alerts a
JOIN deliveries d ON a.delivery_id = d.delivery_id
JOIN farmers f ON d.farmer_id = f.farmer_id
GROUP BY TO_CHAR(a.alert_date, 'YYYY-MM-DD'), a.alert_type
ORDER BY alert_date DESC, alert_count DESC;

-- 5. User Activity Timeline
SELECT 
    username,
    TO_CHAR(log_timestamp, 'YYYY-MM-DD HH24') AS hour,
    COUNT(*) AS operations,
    LISTAGG(operation || ' on ' || object_name || ' (' || operation_status || ')', ', ') 
        WITHIN GROUP (ORDER BY log_timestamp) AS activity_details
FROM audit_log
WHERE log_timestamp >= SYSDATE - 7
GROUP BY username, TO_CHAR(log_timestamp, 'YYYY-MM-DD HH24')
ORDER BY username, hour DESC;
