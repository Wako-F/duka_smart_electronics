
-- Q1: Retrieve all customer records.
SELECT *
FROM customers;

-- Q2: Display customer names, cities, and segments.
SELECT customer_name, city, customer_segment
FROM customers
ORDER BY customer_name, customer_id;

-- Q3: Find customers living in Nairobi.
SELECT *
FROM customers
WHERE city = 'Nairobi'
ORDER BY customer_name, customer_id;

-- Q4: Find customers registered after January 1, 2025.
SELECT *
FROM customers
WHERE registration_date > DATE '2025-01-01'
ORDER BY registration_date, customer_id;

-- Q5: Display all unique customer cities.
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- Q6: Retrieve the 10 most recent orders; order_id resolves same-date ties.
SELECT *
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 10;

-- Q7: Find orders with unit prices above KSh 10,000.
SELECT *
FROM orders
WHERE unit_price > 10000
ORDER BY unit_price DESC, order_id;

-- Q8: Find customers whose names start with A.
SELECT *
FROM customers
WHERE customer_name LIKE 'A%'
ORDER BY customer_name, customer_id;

-- Q9: Retrieve orders with quantities between 2 and 5, inclusive.
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5
ORDER BY order_id;

-- Q10: Find orders paid through M-Pesa.
SELECT *
FROM orders
WHERE payment_method = 'M-Pesa'
ORDER BY order_date, order_id;

-- Q11: Count all registered customers.
SELECT COUNT(*) AS customer_count
FROM customers;

-- Q12: Count all orders, including every status.
SELECT COUNT(*) AS order_count
FROM orders;

-- Q13: Completed-order net revenue; aggregate first and round only for display.
SELECT ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_net_revenue
FROM orders
WHERE order_status = 'Completed';

-- Q14: Average completed-order value (one net order value per order).
SELECT ROUND(AVG(quantity * unit_price * (1 - discount / 100)), 2) AS average_completed_order_value
FROM orders
WHERE order_status = 'Completed';

-- Q15: Highest and lowest observed unit prices across all order rows/statuses.
SELECT MAX(unit_price) AS highest_observed_unit_price,
       MIN(unit_price) AS lowest_observed_unit_price
FROM orders;

-- Q16: Completed net revenue by product category.
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_net_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY completed_net_revenue DESC, product_category;

-- Q17: Count registered customers by city.
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC, city;

-- Q18: Units sold by product; pending and cancelled orders are not sales.
SELECT product_name, SUM(quantity) AS completed_units_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY completed_units_sold DESC, product_name;

-- Q19: Categories generating more than KSh 100,000 in completed net revenue.
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_net_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100)) > 100000
ORDER BY completed_net_revenue DESC, product_category;

-- Q20: Cancelled orders as a percentage of all orders.
SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE order_status = 'Cancelled') / NULLIF(COUNT(*), 0), 2)
           AS cancelled_order_percentage
FROM orders;

-- Q21: Display orders with customer names and cities.
SELECT o.order_id, o.order_date, c.customer_name, c.city,
       o.product_name, o.product_category, o.quantity, o.order_status
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
ORDER BY o.order_date, o.order_id;

-- Q22: Completed net spending by every customer, including zero-spend customers.
SELECT c.customer_id, c.customer_name,
       ROUND(COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100))
                      FILTER (WHERE o.order_status = 'Completed'), 0), 2) AS completed_spending
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY completed_spending DESC, c.customer_id;

-- Q23: Identify customers who have never placed any order, whatever its status.
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- Q24: The 10 highest-spending customers by completed net revenue.
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS completed_spending
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) DESC, c.customer_id
LIMIT 10;

-- Q25: Completed net revenue by customer city.
SELECT c.city,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS completed_net_revenue
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY completed_net_revenue DESC, c.city;

-- Q26: Customers with more than five orders; order counts include all statuses.
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS all_status_order_count
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY all_status_order_count DESC, c.customer_id;

-- Q27: Average customer spending by segment. Average includes every registered
-- customer in the segment, assigning zero to customers with no completed orders.
SELECT c.customer_segment,
       ROUND(AVG(COALESCE(spending.completed_spending, 0)), 2) AS average_customer_spending
FROM customers AS c
LEFT JOIN (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS completed_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
) AS spending ON spending.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY c.customer_segment;

-- Q28: VIP category popularity means number of orders across all statuses.
-- Return every category tied for the largest count.
WITH category_counts AS (
    SELECT o.product_category, COUNT(*) AS all_status_order_count
    FROM orders AS o
    JOIN customers AS c ON c.customer_id = o.customer_id
    WHERE c.customer_segment = 'VIP'
    GROUP BY o.product_category
), ranked_categories AS (
    SELECT product_category, all_status_order_count,
           DENSE_RANK() OVER (ORDER BY all_status_order_count DESC) AS popularity_rank
    FROM category_counts
)
SELECT product_category, all_status_order_count
FROM ranked_categories
WHERE popularity_rank = 1
ORDER BY product_category;

-- Q29: Purchasing means at least one Completed order. Compare each purchaser's
-- completed net spend with the average total among purchasing customers only.
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS completed_spending
    FROM customers AS c
    JOIN orders AS o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(completed_spending, 2) AS completed_spending
FROM customer_totals
WHERE completed_spending > (SELECT AVG(completed_spending) FROM customer_totals)
ORDER BY completed_spending DESC, customer_id;

-- Q30: Product prices are catalogue observations recorded on order lines,
-- including every status. Compare each product's average observed unit price
-- with the average unit_price across all order-line observations.
SELECT product_name, product_category, ROUND(AVG(unit_price), 2) AS average_observed_unit_price
FROM orders
GROUP BY product_name, product_category
HAVING AVG(unit_price) > (SELECT AVG(unit_price) FROM orders)
ORDER BY average_observed_unit_price DESC, product_category, product_name;

-- Q31: Three highest-revenue months. Include every month appearing in orders;
-- months with no Completed orders have zero completed revenue.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
                    FILTER (WHERE order_status = 'Completed'), 0) AS completed_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month, ROUND(completed_revenue, 2) AS completed_revenue
FROM monthly
ORDER BY completed_revenue DESC, sales_month
LIMIT 3;

-- Q32: Completed-order customers with purchases in at least three categories.
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.product_category) AS completed_category_count
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY completed_category_count DESC, c.customer_id;

-- Q33: Completed net revenue, cost, gross profit, and gross profit margin by category.
WITH category_totals AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100)) AS net_revenue,
           SUM(quantity * cost_price) AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(net_revenue, 2) AS net_revenue,
       ROUND(cost, 2) AS cost,
       ROUND(net_revenue - cost, 2) AS gross_profit,
       ROUND(100.0 * (net_revenue - cost) / NULLIF(net_revenue, 0), 2) AS gross_profit_margin_pct
FROM category_totals
ORDER BY net_revenue DESC, product_category;

-- Q34: Among prior Completed purchasers, find those whose last Completed order
-- is strictly more than 90 days before the latest date of any order. Customers
-- with no Completed purchases are excluded here and should be reported separately
-- as never-buyers (they have no completed-order date to age).
WITH latest_dataset_order AS (
    SELECT MAX(order_date) AS latest_order_date FROM orders
), purchaser_last_order AS (
    SELECT customer_id, MAX(order_date) AS latest_completed_order_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, p.latest_completed_order_date,
       d.latest_order_date,
       d.latest_order_date - p.latest_completed_order_date AS days_since_completed_order
FROM purchaser_last_order AS p
JOIN customers AS c ON c.customer_id = p.customer_id
CROSS JOIN latest_dataset_order AS d
WHERE d.latest_order_date - p.latest_completed_order_date > 90
ORDER BY days_since_completed_order DESC, c.customer_id;

-- Q35: Rank all customers by completed net spending; non-purchasers have zero.
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100))
                    FILTER (WHERE o.order_status = 'Completed'), 0) AS completed_spending
    FROM customers AS c
    LEFT JOIN orders AS o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(completed_spending, 2) AS completed_spending,
       RANK() OVER (ORDER BY completed_spending DESC) AS spending_rank
FROM customer_totals
ORDER BY spending_rank, customer_id;

-- Q36: Number each customer's orders by recency; all statuses count.
SELECT customer_id, order_id, order_date, order_status,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) AS recency_number
FROM orders
ORDER BY customer_id, recency_number;

-- Q37: Dense-rank products within category by completed net revenue.
WITH product_revenue AS (
    SELECT product_category, product_name,
           SUM(quantity * unit_price * (1 - discount / 100)) AS completed_net_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT product_category, product_name, ROUND(completed_net_revenue, 2) AS completed_net_revenue,
       DENSE_RANK() OVER (PARTITION BY product_category ORDER BY completed_net_revenue DESC) AS category_revenue_rank
FROM product_revenue
ORDER BY product_category, category_revenue_rank, product_name;

-- Q38: Cumulative completed net revenue by month, retaining every month in orders.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
                    FILTER (WHERE order_status = 'Completed'), 0) AS completed_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month, ROUND(completed_revenue, 2) AS completed_revenue,
       ROUND(SUM(completed_revenue) OVER (ORDER BY sales_month), 2) AS cumulative_completed_revenue
FROM monthly
ORDER BY sales_month;

-- Q39: Compare each month's completed net revenue with the previous month.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
                    FILTER (WHERE order_status = 'Completed'), 0) AS completed_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month, ROUND(completed_revenue, 2) AS completed_revenue,
       ROUND(LAG(completed_revenue) OVER (ORDER BY sales_month), 2) AS previous_month_revenue
FROM monthly
ORDER BY sales_month;

-- Q40: Month-over-month percentage change; zero or missing prior revenue yields NULL.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
                    FILTER (WHERE order_status = 'Completed'), 0) AS completed_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
), monthly_with_previous AS (
    SELECT sales_month, completed_revenue,
           LAG(completed_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM monthly
)
SELECT sales_month, ROUND(completed_revenue, 2) AS completed_revenue,
       ROUND(100.0 * (completed_revenue - previous_month_revenue)
             / NULLIF(previous_month_revenue, 0), 2) AS month_over_month_growth_pct
FROM monthly_with_previous
ORDER BY sales_month;

-- Q41: Four spending groups across all customers, including zero spenders.
-- Equal spend values may be split between NTILE groups; customer_id makes the
-- ordering deterministic and bands balance customer counts as closely as possible.
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100))
                    FILTER (WHERE o.order_status = 'Completed'), 0) AS completed_spending
    FROM customers AS c
    LEFT JOIN orders AS o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(completed_spending, 2) AS completed_spending,
       NTILE(4) OVER (ORDER BY completed_spending, customer_id) AS spending_quartile
FROM customer_totals
ORDER BY spending_quartile, customer_id;

-- Q42: Each category's share of all completed net revenue, with unrounded sums.
WITH category_revenue AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100)) AS completed_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category, ROUND(completed_revenue, 2) AS completed_revenue,
       ROUND(100.0 * completed_revenue / NULLIF(SUM(completed_revenue) OVER (), 0), 2) AS revenue_share_pct
FROM category_revenue
ORDER BY completed_revenue DESC, product_category;

-- Q43: Monthly view. Orders counts all statuses; revenue/cost/profit use
-- Completed orders only. Months with orders remain visible even if none completed.
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(*) AS orders,
       COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
                FILTER (WHERE order_status = 'Completed'), 0) AS revenue,
       COALESCE(SUM(quantity * cost_price) FILTER (WHERE order_status = 'Completed'), 0) AS cost,
       COALESCE(SUM(quantity * (unit_price * (1 - discount / 100) - cost_price))
                FILTER (WHERE order_status = 'Completed'), 0) AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

SELECT month AS sales_month, orders AS all_status_orders,
       ROUND(revenue, 2) AS completed_net_revenue,
       ROUND(cost, 2) AS completed_cost,
       ROUND(profit, 2) AS completed_gross_profit
FROM monthly_sales_summary
ORDER BY month;

-- Q44: Return completed net revenue for one customer, or zero for no match.
CREATE OR REPLACE FUNCTION customer_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_revenue NUMERIC;
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price * (1 - discount / 100)), 0)
    INTO v_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';

    RETURN COALESCE(v_revenue, 0);
END;
$$;

-- Demonstrate using an actual registered customer selected from the table.
SELECT c.customer_id, c.customer_name,
       ROUND(customer_revenue(c.customer_id), 2) AS completed_net_revenue
FROM customers AS c
ORDER BY c.customer_id
LIMIT 1;

-- Demonstrate a nonexistent ID; function result is zero, not NULL.
SELECT -1 AS missing_customer_id, customer_revenue(-1) AS completed_net_revenue;

-- Q45: Data-driven value bands use discrete 25th and 75th percentile cutoffs of
-- completed customer spending across ALL registered customers, including zero spenders.
-- Each cutoff is an observed customer total; high is >= p75, medium is >= p25
-- but below p75, and low is below p25.
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100))
                    FILTER (WHERE o.order_status = 'Completed'), 0) AS completed_spending
    FROM customers AS c
    LEFT JOIN orders AS o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
), thresholds AS (
    SELECT percentile_disc(0.25) WITHIN GROUP (ORDER BY completed_spending) AS p25_spending,
           percentile_disc(0.75) WITHIN GROUP (ORDER BY completed_spending) AS p75_spending
    FROM customer_totals
)
SELECT c.customer_id, c.customer_name, ROUND(c.completed_spending, 2) AS completed_spending,
       ROUND(t.p25_spending, 2) AS low_medium_cutoff,
       ROUND(t.p75_spending, 2) AS medium_high_cutoff,
       CASE
           WHEN c.completed_spending >= t.p75_spending THEN 'High'
           WHEN c.completed_spending >= t.p25_spending THEN 'Medium'
           ELSE 'Low'
       END AS customer_value_segment
FROM customer_totals AS c
CROSS JOIN thresholds AS t
ORDER BY c.completed_spending DESC, c.customer_id;

-- Q46: Four management result sets follow. Top-five cutoffs use exact row limits;
-- identifiers resolve ties deterministically. Category/month returns one row,
-- breaking equal gross profit/revenue by category name/month date.

-- Result set 1: five customers by completed net revenue.
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS completed_net_revenue
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) DESC, c.customer_id
LIMIT 5;

-- Result set 2: five products by completed net revenue, including gross profit.
SELECT product_category, product_name,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_net_revenue,
       ROUND(SUM(quantity * (unit_price * (1 - discount / 100) - cost_price)), 2) AS gross_profit
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category, product_name
ORDER BY SUM(quantity * unit_price * (1 - discount / 100)) DESC, product_category, product_name
LIMIT 5;

-- Result set 3: category with the highest completed gross profit.
SELECT product_category,
       ROUND(SUM(quantity * (unit_price * (1 - discount / 100) - cost_price)), 2) AS completed_gross_profit
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY SUM(quantity * (unit_price * (1 - discount / 100) - cost_price)) DESC, product_category
LIMIT 1;

-- Result set 4: lowest completed-revenue month among all months appearing in orders.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
                    FILTER (WHERE order_status = 'Completed'), 0) AS completed_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month, ROUND(completed_revenue, 2) AS completed_revenue
FROM monthly
ORDER BY completed_revenue, sales_month
LIMIT 1;
