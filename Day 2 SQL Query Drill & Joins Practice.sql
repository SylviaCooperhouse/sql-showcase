-- Day 2: SQL Practice Questions Only

-- 1. Basic SELECT & Filtering
-- Retrieve all customers who signed up in the last 6 months, sorted by signup_date (newest first).
-- Retrieve all orders where total_amount is greater than $500, sorted by highest order amount.

SELECT customer_id, name, signup_date 
FROM customers 
WHERE signup_date >= NOW() - INTERVAL '6 months' 
ORDER BY signup_date DESC;

SELECT order_id, customer_id, total_amount 
FROM orders 
WHERE total_amount > 500 
ORDER BY total_amount DESC;

-- 2. Joins & Aggregations
-- Calculate total revenue per customer.
-- Retrieve product_id, name, and total quantity sold across all orders, sorted by most popular products.

SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_revenue 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.name 
ORDER BY total_revenue DESC;

SELECT p.product_id, p.name, SUM(oi.quantity) AS total_sold 
FROM products p 
JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.product_id, p.name 
ORDER BY total_sold DESC;


-- 3. Window Functions
-- Rank customers by total spending, assigning the highest spender a rank of 1.
-- Retrieve the most recent order per customer, including customer_id, order_id, and total_amount.

SELECT customer_id, name, SUM(total_amount) AS total_spent, 
       RANK() OVER (ORDER BY SUM(total_amount) DESC) AS spending_rank 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY customer_id, name;

SELECT customer_id, order_id, total_amount, order_date, 
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS recent_order_rank 
FROM orders;

-- 4. CTEs & Subqueries
-- Find customers who have placed at least 2 orders with total_amount > $500.
-- Get top 3 spenders in each region using a window function.

WITH high_value_orders AS (
    SELECT customer_id 
    FROM orders 
    WHERE total_amount > 500 
    GROUP BY customer_id 
    HAVING COUNT(order_id) >= 2
)
SELECT c.customer_id, c.name 
FROM customers c 
JOIN high_value_orders hvo ON c.customer_id = hvo.customer_id;

WITH ranked_customers AS (
    SELECT c.customer_id, c.name, c.region, SUM(o.total_amount) AS total_spent, 
           RANK() OVER (PARTITION BY c.region ORDER BY SUM(o.total_amount) DESC) AS rank 
    FROM customers c 
    JOIN orders o ON c.customer_id = o.customer_id 
    GROUP BY c.customer_id, c.name, c.region
)
SELECT * FROM ranked_customers WHERE rank <= 3;