-- Day 3: SQL Advanced Querying & Optimization

-- 1. Indexing & Performance Optimization
-- Identify slow queries in a large dataset and suggest an indexing strategy.
-- Write a query to analyze the execution plan of a query using EXPLAIN ANALYZE.

EXPLAIN ANALYZE SELECT * FROM orders WHERE total_amount > 500;

CREATE INDEX idx_orders_total_amount ON orders(total_amount);

-- 2. Recursive Queries (Common Table Expressions - CTEs)
-- Write a recursive query to display a category hierarchy (parent-child relationship).
-- Find all employees reporting to a specific manager using a recursive CTE.

WITH RECURSIVE category_hierarchy AS (
    SELECT category_id, parent_category_id, name
    FROM categories
    WHERE parent_category_id IS NULL
    UNION ALL
    SELECT c.category_id, c.parent_category_id, c.name
    FROM categories c
    JOIN category_hierarchy ch ON c.parent_category_id = ch.category_id
)
SELECT * FROM category_hierarchy;

WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, manager_id, name
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy;

-- 3. Advanced Window Functions
-- Calculate the running total of total_amount per customer over time.
-- Find the difference in spending between consecutive orders for each customer.

SELECT customer_id, order_id, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS running_total
FROM orders;

SELECT customer_id, order_id, total_amount,
       total_amount - LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS spending_difference
FROM orders;

-- 4. JSON & Complex Data Handling
-- Query a JSON column to extract nested data (assuming products table has a JSON field with specifications).
-- Aggregate order details stored in a JSON column.

SELECT product_id, name, specifications->>'color' AS color
FROM products;

SELECT order_id, SUM((json_array_elements(order_details)->>'price')::numeric) AS total_price
FROM orders
GROUP BY order_id;

-- 5. Transactions & Error Handling
-- Demonstrate how to use BEGIN, COMMIT, and ROLLBACK in SQL transactions.
-- Implement error handling in a stored procedure.

BEGIN;
UPDATE customers SET balance = balance - 100 WHERE customer_id = 1;
UPDATE customers SET balance = balance + 100 WHERE customer_id = 2;
COMMIT;

CREATE PROCEDURE safe_transfer()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;
    COMMIT;
END;