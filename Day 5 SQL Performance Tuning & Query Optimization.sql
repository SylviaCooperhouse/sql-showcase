-- Day 5: SQL Performance Tuning & Query Optimization

-- 1. Query Performance Analysis
-- Identify slow queries using EXPLAIN ANALYZE.
-- Optimize query performance by adding proper indexes.

EXPLAIN ANALYZE SELECT * FROM orders WHERE total_amount > 500;

CREATE INDEX idx_orders_total_amount ON orders(total_amount);

-- 2. Indexing Strategies
-- Compare performance before and after indexing.

-- Without index:
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 12345;

-- Adding index for optimization:
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Checking performance after indexing:
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 12345;

-- 3. Partitioning Large Tables
-- Implement table partitioning for faster data retrieval.

-- Creating partitioned table based on order date:
CREATE TABLE orders_partitioned (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    total_amount DECIMAL(10,2),
    order_date DATE
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_2023 PARTITION OF orders_partitioned FOR VALUES FROM ('2023-01-01') TO ('2023-12-31');

CREATE TABLE orders_2024 PARTITION OF orders_partitioned FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');

-- 4. Optimizing Joins
-- Improve JOIN performance using indexing and efficient query structuring.

EXPLAIN ANALYZE 
SELECT c.name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- Adding index for optimization:
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 5. Avoiding Unnecessary Queries
-- Use EXISTS instead of COUNT(*) when checking for the existence of records.

-- Inefficient way (Counts all matching rows even if not needed):
SELECT COUNT(*) FROM orders WHERE customer_id = 12345;
-- Example output: 5 (if there are 5 matching orders)

-- Efficient way (Stops at first matching row, faster for large datasets):
SELECT EXISTS (SELECT 1 FROM orders WHERE customer_id = 12345);
-- Example output: true (if at least one order exists), false (if none exist)

-- 6. Caching Strategies
-- Use materialized views to cache results for faster access.

CREATE MATERIALIZED VIEW customer_order_summary AS
SELECT customer_id, COUNT(order_id) AS order_count, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;

-- Refresh materialized view periodically:
REFRESH MATERIALIZED VIEW customer_order_summary;

-- Materialized views store the query results, unlike regular views which recompute results every time.
-- Refreshing updates the stored results, so queries run against precomputed data.

-- 7. Optimizing Aggregations
-- Use indexes to speed up GROUP BY and HAVING operations.

EXPLAIN ANALYZE
SELECT customer_id, SUM(total_amount) 
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 1000;

-- Adding index for optimization:
CREATE INDEX idx_orders_total_amount ON orders(total_amount);

-- 8. Handling Large Datasets
-- Implement proper pagination using LIMIT and OFFSET.

-- Inefficient way (can slow down with large offsets):
SELECT * FROM orders ORDER BY order_date DESC LIMIT 10 OFFSET 1000;
-- Large OFFSET values make queries slow because SQL must read all skipped rows first.

-- More efficient approach using keyset pagination:
SELECT * FROM orders
WHERE order_date < (SELECT order_date FROM orders ORDER BY order_date DESC LIMIT 1 OFFSET 1000)
ORDER BY order_date DESC LIMIT 10;
