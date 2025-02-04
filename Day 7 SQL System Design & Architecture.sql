-- Day 7: SQL System Design & Architecture

-- 1. Database Sharding
-- Example of horizontal sharding by customer_id
-- Splitting data across multiple tables based on customer regions

CREATE TABLE customers_shard_1 (
    customer_id SERIAL PRIMARY KEY,
    name TEXT,
    region TEXT CHECK (region = 'North America')
);

CREATE TABLE customers_shard_2 (
    customer_id SERIAL PRIMARY KEY,
    name TEXT,
    region TEXT CHECK (region = 'Europe')
);

-- Query to retrieve customer details based on sharding
SELECT * FROM customers_shard_1 WHERE customer_id = 1001;
SELECT * FROM customers_shard_2 WHERE customer_id = 2055;

-- 2. Database Replication
-- Setting up read replicas to improve performance

-- Creating a read replica (simulated example)
CREATE PUBLICATION customer_data_pub FOR TABLE customers;
CREATE SUBSCRIPTION customer_data_sub CONNECTION 'host=replica_server dbname=mydb' PUBLICATION customer_data_pub;

-- Querying from a read replica (read-only replica usage)
SELECT * FROM customers WHERE customer_id = 12345;

-- 3. Query Caching
-- Using Materialized Views to store computed results for faster retrieval

CREATE MATERIALIZED VIEW top_customers AS
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC LIMIT 100;

-- Refresh materialized view periodically to keep data up to date
REFRESH MATERIALIZED VIEW top_customers;

-- 4. Handling Large-Scale Data with Partitioning
-- Implementing range partitioning to distribute data efficiently

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (transaction_date);

CREATE TABLE transactions_2023 PARTITION OF transactions
    FOR VALUES FROM ('2023-01-01') TO ('2023-12-31');

CREATE TABLE transactions_2024 PARTITION OF transactions
    FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');

-- Querying partitioned tables efficiently
SELECT * FROM transactions WHERE transaction_date BETWEEN '2023-06-01' AND '2023-06-30';

-- 5. High Availability & Failover Strategies
-- Creating a failover replica for automatic recovery

CREATE PUBLICATION failover_pub FOR ALL TABLES;
CREATE SUBSCRIPTION failover_sub CONNECTION 'host=failover_server dbname=mydb' PUBLICATION failover_pub;

-- 6. Load Balancing Queries
-- Using connection pooling to distribute queries across multiple replicas

-- Simulated example of a load-balanced query
SELECT * FROM customers WHERE customer_id = 7890;
-- This query would be directed to a read replica automatically in a production setting
