
-- DATA RETRIEVAL QUERIES
-- 1. Get all active farmers with delivery counts
SELECT 
    f.farmer_id,
    f.full_name,
    f.phone,
    f.sector,
    f.registration_date,
    COUNT(d.delivery_id) AS total_deliveries,
    SUM(d.weight_kg) AS total_weight_kg
FROM farmers f
LEFT JOIN deliveries d ON f.farmer_id = d.farmer_id
GROUP BY f.farmer_id, f.full_name, f.phone, f.sector, f.registration_date
ORDER BY total_deliveries DESC;

-- 2. Get deliveries with payment status
SELECT 
    d.delivery_id,
    f.full_name AS farmer_name,
    d.delivery_date,
    d.weight_kg,
    cq.quality_name,
    cq.price_per_kg,
    CASE 
        WHEN p.payment_id IS NOT NULL THEN 'PAID'
        ELSE 'PENDING'
    END AS payment_status,
    p.amount_paid,
    p.payment_date
FROM deliveries d
JOIN farmers f ON d.farmer_id = f.farmer_id
JOIN coffee_quality cq ON d.quality_id = cq.quality_id
LEFT JOIN payments p ON d.delivery_id = p.delivery_id
ORDER BY d.delivery_date DESC;

-- 3. Get monthly delivery summary
SELECT 
    TO_CHAR(d.delivery_date, 'YYYY-MM') AS month,
    COUNT(d.delivery_id) AS delivery_count,
    SUM(d.weight_kg) AS total_weight_kg,
    ROUND(AVG(d.weight_kg), 2) AS avg_weight_per_delivery,
    SUM(p.amount_paid) AS total_payments
FROM deliveries d
LEFT JOIN payments p ON d.delivery_id = p.delivery_id
GROUP BY TO_CHAR(d.delivery_date, 'YYYY-MM')
ORDER BY month DESC;

-- 4. Get quality distribution
SELECT 
    cq.quality_name,
    COUNT(d.delivery_id) AS delivery_count,
    SUM(d.weight_kg) AS total_weight_kg,
    ROUND(COUNT(d.delivery_id) * 100.0 / (SELECT COUNT(*) FROM deliveries), 2) AS percentage
FROM coffee_quality cq
LEFT JOIN deliveries d ON cq.quality_id = d.quality_id
GROUP BY cq.quality_id, cq.quality_name
ORDER BY cq.quality_id;

-- 5. Get farmer earnings ranking
SELECT 
    f.farmer_id,
    f.full_name,
    f.sector,
    COUNT(d.delivery_id) AS deliveries,
    SUM(d.weight_kg) AS total_weight,
    SUM(p.amount_paid) AS total_earnings,
    ROUND(SUM(p.amount_paid) / NULLIF(SUM(d.weight_kg), 0), 2) AS avg_price_per_kg,
    RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS earnings_rank
FROM farmers f
LEFT JOIN deliveries d ON f.farmer_id = d.farmer_id
LEFT JOIN payments p ON d.delivery_id = p.delivery_id
GROUP BY f.farmer_id, f.full_name, f.sector
ORDER BY total_earnings DESC;
