-- Day 7: SQL System Design & Architecture

-- 1. Database Sharding
-- Sharding splits large tables into smaller, more manageable ones, improving performance.
-- It can be done by dividing data across multiple servers or databases.
-- This helps distribute load and allows horizontal scaling.

-- Example of horizontal sharding by customer_id (Splitting customers by region)
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

-- Query to retrieve customer details from the correct shard
SELECT * FROM customers_shard_1 WHERE customer_id = 1001;
SELECT * FROM customers_shard_2 WHERE customer_id = 2055;

-- 2. Database Replication
-- Replication creates one or more copies (replicas) of a database for better performance and reliability.
-- Read replicas handle SELECT queries, reducing load on the primary database.
-- Failover replication allows automatic recovery in case the primary database crashes.

-- Setting up read replicas to improve performance
-- `CREATE PUBLICATION` on the primary database marks tables for replication.
CREATE PUBLICATION customer_data_pub FOR TABLE customers;

-- `CREATE SUBSCRIPTION` on the replica database subscribes to changes from the primary.
CREATE SUBSCRIPTION customer_data_sub CONNECTION 'host=replica_server dbname=mydb' PUBLICATION customer_data_pub;

-- Querying from a read replica (read-only replica usage)
SELECT * FROM customers WHERE customer_id = 12345;
-- Read queries are typically directed to replicas to balance database load.

-- 3. Query Caching
-- Caching speeds up queries by storing results instead of recomputing them every time.
-- Materialized Views store query results for faster retrieval, reducing expensive computations.

CREATE MATERIALIZED VIEW top_customers AS
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC LIMIT 100;

-- Refresh materialized view periodically to keep data up to date
REFRESH MATERIALIZED VIEW top_customers;

-- 4. Handling Large-Scale Data with Partitioning
-- Partitioning splits large tables into smaller partitions to improve query performance.
-- Queries only scan relevant partitions, reducing execution time.

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
-- High availability ensures databases remain operational even during failures.
-- Failover strategies involve having standby replicas that can take over when the primary fails.

CREATE PUBLICATION failover_pub FOR ALL TABLES;
CREATE SUBSCRIPTION failover_sub CONNECTION 'host=failover_server dbname=mydb' PUBLICATION failover_pub;

-- 6. Load Balancing Queries
-- Load balancing distributes queries across multiple replicas to improve performance.
-- Applications typically route SELECT queries to read replicas automatically.
-- Load balancing is done at the **database connection level**, not within SQL itself.

-- Simulated example of a load-balanced query
SELECT * FROM customers WHERE customer_id = 7890;
-- In a production setting, this query would be routed to a read replica by a database proxy.
-- AWS RDS Proxy, PgBouncer, or application-level logic handles this routing.

-- Load balancing helps prevent database overload and improves scalability.
