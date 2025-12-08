

-- 1. Year-over-Year Growth Analysis
WITH monthly_stats AS (
    SELECT 
        EXTRACT(YEAR FROM delivery_date) AS year,
        EXTRACT(MONTH FROM delivery_date) AS month,
        COUNT(delivery_id) AS deliveries,
        SUM(weight_kg) AS weight_kg,
        SUM(amount_paid) AS revenue
    FROM deliveries d
    LEFT JOIN payments p ON d.delivery_id = p.delivery_id
    GROUP BY EXTRACT(YEAR FROM delivery_date), EXTRACT(MONTH FROM delivery_date)
)
SELECT 
    year,
    month,
    deliveries,
    weight_kg,
    revenue,
    LAG(deliveries) OVER (ORDER BY year, month) AS prev_month_deliveries,
    ROUND(((deliveries - LAG(deliveries) OVER (ORDER BY year, month)) / 
           LAG(deliveries) OVER (ORDER BY year, month)) * 100, 2) AS delivery_growth_pct
FROM monthly_stats
ORDER BY year DESC, month DESC;

-- 2. Farmer Performance Segmentation
WITH farmer_performance AS (
    SELECT 
        f.farmer_id,
        f.full_name,
        SUM(d.weight_kg) AS total_weight,
        SUM(p.amount_paid) AS total_revenue,
        COUNT(d.delivery_id) AS delivery_count,
        ROUND(AVG(d.weight_kg), 2) AS avg_delivery_weight
    FROM farmers f
    LEFT JOIN deliveries d ON f.farmer_id = d.farmer_id
    LEFT JOIN payments p ON d.delivery_id = p.delivery_id
    GROUP BY f.farmer_id, f.full_name
)
SELECT 
    farmer_id,
    full_name,
    total_weight,
    total_revenue,
    delivery_count,
    avg_delivery_weight,
    CASE 
        WHEN total_revenue >= 1000 THEN 'PLATINUM'
        WHEN total_revenue >= 500 THEN 'GOLD'
        WHEN total_revenue >= 200 THEN 'SILVER'
        WHEN total_revenue > 0 THEN 'BRONZE'
        ELSE 'NEW'
    END AS farmer_tier,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
FROM farmer_performance
ORDER BY total_revenue DESC;

-- 3. Seasonal Analysis
SELECT 
    EXTRACT(MONTH FROM delivery_date) AS month_num,
    TO_CHAR(delivery_date, 'Month') AS month_name,
    CASE 
        WHEN EXTRACT(MONTH FROM delivery_date) IN (3,4,5) THEN 'HARVEST SEASON'
        WHEN EXTRACT(MONTH FROM delivery_date) IN (6,7,8) THEN 'LOW SEASON'
        WHEN EXTRACT(MONTH FROM delivery_date) IN (9,10,11) THEN 'POST-HARVEST'
        ELSE 'OFF-SEASON'
    END AS season,
    COUNT(delivery_id) AS deliveries,
    SUM(weight_kg) AS total_weight,
    ROUND(AVG(weight_kg), 2) AS avg_weight,
    SUM(amount_paid) AS total_revenue
FROM deliveries d
LEFT JOIN payments p ON d.delivery_id = p.delivery_id
GROUP BY EXTRACT(MONTH FROM delivery_date), TO_CHAR(delivery_date, 'Month')
ORDER BY month_num;

-- 4. Quality Revenue Analysis
SELECT 
    cq.quality_name,
    cq.price_per_kg,
    COUNT(d.delivery_id) AS deliveries,
    SUM(d.weight_kg) AS total_weight,
    SUM(p.amount_paid) AS total_revenue,
    ROUND(SUM(p.amount_paid) / NULLIF(SUM(d.weight_kg), 0), 2) AS actual_price_per_kg,
    ROUND((SUM(p.amount_paid) / NULLIF(SUM(d.weight_kg), 0) - cq.price_per_kg) / cq.price_per_kg * 100, 2) AS price_variance_pct
FROM coffee_quality cq
LEFT JOIN deliveries d ON cq.quality_id = d.quality_id
LEFT JOIN payments p ON d.delivery_id = p.delivery_id
GROUP BY cq.quality_id, cq.quality_name, cq.price_per_kg
ORDER BY total_revenue DESC;

-- 5. Delivery Time Analysis
WITH delivery_intervals AS (
    SELECT 
        f.farmer_id,
        f.full_name,
        d.delivery_date,
        LAG(d.delivery_date) OVER (PARTITION BY f.farmer_id ORDER BY d.delivery_date) AS prev_delivery_date,
        d.delivery_date - LAG(d.delivery_date) OVER (PARTITION BY f.farmer_id ORDER BY d.delivery_date) AS days_between
    FROM farmers f
    JOIN deliveries d ON f.farmer_id = d.farmer_id
)
SELECT 
    farmer_id,
    full_name,
    COUNT(*) AS deliveries,
    ROUND(AVG(days_between), 2) AS avg_days_between_deliveries,
    ROUND(STDDEV(days_between), 2) AS stddev_days_between,
    CASE 
        WHEN AVG(days_between) <= 7 THEN 'WEEKLY'
        WHEN AVG(days_between) <= 14 THEN 'BI-WEEKLY'
        WHEN AVG(days_between) <= 30 THEN 'MONTHLY'
        ELSE 'IRREGULAR'
    END AS delivery_frequency
FROM delivery_intervals
WHERE days_between IS NOT NULL
GROUP BY farmer_id, full_name
HAVING COUNT(*) > 1
ORDER BY avg_days_between_deliveries;
