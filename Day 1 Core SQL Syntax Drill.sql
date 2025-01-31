-- Day 1: Core SQL Syntax Drill

-- 1. Basic SELECT & Filtering
-- Retrieve all customers who signed up in 2024, sorted by name
-- Also, retrieve only customers from a specific region (e.g., 'North America')
SELECT customer_id, name, email, signup_date 
FROM customers 
WHERE signup_date >= '2024-01-01' AND region = 'North America' 
ORDER BY name ASC 
LIMIT 10;

-- 2. Joins (INNER JOIN, LEFT JOIN, RIGHT JOIN)
-- Retrieve all orders with customer names (including customers without orders)
SELECT o.order_id, c.name AS customer_name, o.total_amount, o.order_date 
FROM orders o 
LEFT JOIN customers c ON o.customer_id = c.customer_id 
ORDER BY o.order_date DESC;

-- Retrieve product names and their respective order count
SELECT p.name AS product_name, COUNT(oi.order_id) AS order_count 
FROM products p 
LEFT JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.name 
ORDER BY order_count DESC;

-- 3. Aggregations & GROUP BY
-- Find total revenue per customer and filter those who spent more than $1,000
SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_spent 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.name 
HAVING SUM(o.total_amount) > 1000 
ORDER BY total_spent DESC;

-- Count the number of orders per customer
SELECT c.customer_id, c.name, COUNT(o.order_id) AS order_count 
FROM customers c 
LEFT JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.name 
ORDER BY order_count DESC;

-- 4. Window Functions (RANK, DENSE_RANK, ROW_NUMBER)
-- Rank customers by total spending within their region
SELECT customer_id, name, region, SUM(total_amount) AS total_spent,
       RANK() OVER (PARTITION BY region ORDER BY SUM(total_amount) DESC) AS spending_rank 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY customer_id, name, region;

-- Get the most recent orders per customer
SELECT order_id, customer_id, order_date, 
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS recent_order_rank 
FROM orders;

-- 5. CTEs & Subqueries
-- Get top 3 customers in each region based on total spending
WITH customer_spending AS (
    SELECT c.customer_id, c.name, c.region, SUM(o.total_amount) AS total_spent,
           RANK() OVER (PARTITION BY c.region ORDER BY SUM(o.total_amount) DESC) AS rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name, c.region
)
SELECT * FROM customer_spending WHERE rank <= 3;

-- Find products that have been purchased more than once in different orders
SELECT product_id, COUNT(DISTINCT order_id) AS distinct_order_count 
FROM order_items 
GROUP BY product_id 
HAVING COUNT(DISTINCT order_id) > 1 
ORDER BY distinct_order_count DESC;