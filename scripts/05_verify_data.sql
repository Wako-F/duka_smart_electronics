-- 05_verify_data.sql
-- Run after 01–04, connected to retail_analytics. Every line of output should say what it says
-- here; if one does not, re-run the scripts in order (see README.md).
--
--   psql -U postgres -d retail_analytics -f 05_verify_data.sql

SELECT 'customers'                         AS check_name, COUNT(*)::text AS result, '150' AS expected FROM customers
UNION ALL SELECT 'orders',                   COUNT(*)::text, '800' FROM orders
UNION ALL SELECT 'orders with no customer',  COUNT(*)::text, '0'   FROM orders o LEFT JOIN customers c USING (customer_id) WHERE c.customer_id IS NULL
UNION ALL SELECT 'first order date',         MIN(order_date)::text, '2025-01-..' FROM orders
UNION ALL SELECT 'last order date',          MAX(order_date)::text, '2026-09-..' FROM orders
UNION ALL SELECT 'customers with no orders', COUNT(*)::text, 'more than 0' FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
UNION ALL SELECT 'customers with 2+ orders', COUNT(*)::text, 'more than 0' FROM (SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*) >= 2) t
UNION ALL SELECT 'customers with 6+ orders', COUNT(*)::text, 'more than 0' FROM (SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*) > 5) t
UNION ALL SELECT 'categories',               COUNT(DISTINCT product_category)::text, '5' FROM orders
UNION ALL SELECT 'statuses',                 string_agg(DISTINCT order_status, ', '), 'Cancelled, Completed, Pending' FROM orders
UNION ALL SELECT 'orders before registration', COUNT(*)::text, '0' FROM orders o JOIN customers c USING (customer_id) WHERE o.order_date < c.registration_date;

-- Completed-order revenue, cost and profit (see "Business rules" in README.md).
SELECT
    ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_revenue,
    ROUND(SUM(quantity * cost_price), 2)                         AS completed_cost,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100)) - SUM(quantity * cost_price), 2) AS completed_profit
FROM orders
WHERE order_status = 'Completed';
