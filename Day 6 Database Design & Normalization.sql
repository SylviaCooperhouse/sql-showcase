-- Day 6: Database Design & Normalization

-- 1. Understanding Normal Forms
-- Convert an unnormalized table to 3rd Normal Form (3NF).

-- Unnormalized Table:
CREATE TABLE orders_unnormalized (
    order_id SERIAL PRIMARY KEY,
    customer_name TEXT,
    product_details TEXT,  -- Contains product name and quantity combined
    total_amount DECIMAL(10,2)
);

-- First Normal Form (1NF):
CREATE TABLE orders_1NF (
    order_id SERIAL PRIMARY KEY,
    customer_name TEXT,
    total_amount DECIMAL(10,2)
);

CREATE TABLE order_items_1NF (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders_1NF(order_id),
    product_name TEXT,
    quantity INT
);

-- Second Normal Form (2NF):
CREATE TABLE customers_2NF (
    customer_id SERIAL PRIMARY KEY,
    customer_name TEXT UNIQUE
);

CREATE TABLE orders_2NF (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers_2NF(customer_id),
    total_amount DECIMAL(10,2)
);

CREATE TABLE order_items_2NF (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders_2NF(order_id),
    product_id INT,
    quantity INT
);

CREATE TABLE products_2NF (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT UNIQUE
);

-- Third Normal Form (3NF):
CREATE TABLE customers_3NF (
    customer_id SERIAL PRIMARY KEY,
    customer_name TEXT UNIQUE
);

CREATE TABLE orders_3NF (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers_3NF(customer_id),
    total_amount DECIMAL(10,2)
);

CREATE TABLE order_items_3NF (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders_3NF(order_id),
    product_id INT REFERENCES products_3NF(product_id),
    quantity INT
);

CREATE TABLE products_3NF (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT UNIQUE,
    category_id INT REFERENCES categories_3NF(category_id)
);

CREATE TABLE categories_3NF (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT UNIQUE
);

-- 2. Handling Many-to-Many Relationships
-- Create a many-to-many relationship between products and suppliers.

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name TEXT UNIQUE
);

CREATE TABLE product_suppliers (
    product_id INT REFERENCES products_3NF(product_id),
    supplier_id INT REFERENCES suppliers(supplier_id),
    PRIMARY KEY (product_id, supplier_id)
);

-- 3. Using Constraints for Data Integrity
-- Ensure referential integrity with constraints.

ALTER TABLE orders_3NF ADD CONSTRAINT chk_total_amount CHECK (total_amount >= 0);

ALTER TABLE order_items_3NF ADD CONSTRAINT chk_quantity CHECK (quantity > 0);

-- 4. Implementing Indexes for Faster Lookups
CREATE INDEX idx_orders_customer_id ON orders_3NF(customer_id);
CREATE INDEX idx_order_items_product_id ON order_items_3NF(product_id);

-- 5. Denormalization for Performance Optimization
-- Creating a materialized view for reporting.

CREATE MATERIALIZED VIEW order_summary AS
SELECT c.customer_name, SUM(o.total_amount) AS total_spent, COUNT(o.order_id) AS order_count
FROM customers_3NF c
JOIN orders_3NF o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

-- Refresh the materialized view periodically.
REFRESH MATERIALIZED VIEW order_summary;
