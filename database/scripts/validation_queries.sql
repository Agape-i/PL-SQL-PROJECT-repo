-- VALIDATION QUERIES FOR DATA INTEGRITY


-- 1. Row Count Verification
SELECT 'FARMERS' AS table_name, COUNT(*) AS row_count FROM farmers
UNION ALL
SELECT 'COFFEE_QUALITY', COUNT(*) FROM coffee_quality
UNION ALL
SELECT 'DELIVERIES', COUNT(*) FROM deliveries
UNION ALL
SELECT 'PAYMENTS', COUNT(*) FROM payments
UNION ALL
SELECT 'SYSTEM_USERS', COUNT(*) FROM system_users
UNION ALL
SELECT 'HOLIDAYS', COUNT(*) FROM holidays;

-- 2. Payment Calculation Verification
SELECT p.payment_id, d.delivery_id, 
       p.amount_paid AS actual_payment,
       d.weight_kg * cq.price_per_kg AS calculated_payment,
       CASE 
         WHEN p.amount_paid = d.weight_kg * cq.price_per_kg 
         THEN '✓ CORRECT' 
         ELSE '✗ ERROR' 
       END AS status
FROM payments p
JOIN deliveries d ON p.delivery_id = d.delivery_id
JOIN coffee_quality cq ON d.quality_id = cq.quality_id
ORDER BY p.payment_id;

-- 3. Foreign Key Integrity Check
SELECT 'Orphaned deliveries' AS issue_type, COUNT(*) AS issue_count
FROM deliveries d
LEFT JOIN farmers f ON d.farmer_id = f.farmer_id
WHERE f.farmer_id IS NULL
UNION ALL
SELECT 'Orphaned payments', COUNT(*)
FROM payments p
LEFT JOIN deliveries d ON p.delivery_id = d.delivery_id
WHERE d.delivery_id IS NULL;

-- 4. Constraint Validation
SELECT 'Negative weight check' AS test, COUNT(*) AS violations
FROM deliveries WHERE weight_kg <= 0
UNION ALL
SELECT 'Negative price check', COUNT(*)
FROM coffee_quality WHERE price_per_kg <= 0;
