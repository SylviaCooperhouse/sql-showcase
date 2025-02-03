-- Day 4: SQL Business Intelligence & Real-World Queries

-- 1. Customer Retention Analysis
-- Find the number of returning customers vs. new customers in the last 12 months.
-- Identify customers who made a second purchase within 60 days of their first order.

SELECT
    COUNT(DISTINCT CASE WHEN order_count = 1 THEN customer_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) AS returning_customers
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    WHERE order_date >= NOW() - INTERVAL '12 months'
    GROUP BY customer_id
) customer_orders;

WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_purchase_date
    FROM orders
    GROUP BY customer_id
)
SELECT o.customer_id, o.order_id, o.order_date, f.first_purchase_date,
       o.order_date - f.first_purchase_date AS days_since_first_order
FROM orders o
JOIN first_order f ON o.customer_id = f.customer_id
WHERE o.order_date > f.first_purchase_date
AND o.order_date <= f.first_purchase_date + INTERVAL '60 days';

-- 2. Sales & Revenue Insights
-- Calculate the average order value (AOV) per month.
-- Find the top 5 products by revenue in the last 6 months.

SELECT DATE_TRUNC('month', order_date) AS month, AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY month
ORDER BY month;

SELECT p.product_id, p.name, SUM(oi.quantity * oi.subtotal) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= NOW() - INTERVAL '6 months'
GROUP BY p.product_id, p.name
ORDER BY total_revenue DESC
LIMIT 5;

-- 3. Customer Segmentation
-- Categorize customers into tiers based on total spending: High, Medium, Low.

SELECT customer_id, name, total_spent,
       CASE
           WHEN total_spent > 5000 THEN 'High'
           WHEN total_spent BETWEEN 1000 AND 5000 THEN 'Medium'
           ELSE 'Low'
       END AS spending_tier
FROM (
    SELECT customer_id, name, SUM(total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY customer_id, name
) customer_spending;

-- 4. Inventory Management
-- Find products that have not been ordered in the last 6 months.
-- Determine the stock turnover rate for each product.

SELECT p.product_id, p.name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date IS NULL OR o.order_date < NOW() - INTERVAL '6 months';

SELECT p.product_id, p.name, SUM(oi.quantity) / p.stock_quantity AS turnover_rate
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.stock_quantity
ORDER BY turnover_rate DESC;
