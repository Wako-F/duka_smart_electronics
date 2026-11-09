-- Alternative standalone copy of scripts/02_create_tables.sql.
-- Run while connected to retail_analytics. IF NOT EXISTS preserves existing tables/data.
--
-- Constraints:
-- * Primary keys make customer_id and order_id unique and non-null.
-- * orders.customer_id is required and must reference a registered customer.
-- * CHECK constraints limit gender, customer segment, payment method and status;
--   they reject nonpositive quantities, negative prices and discounts outside 0..100.
-- * As in the supplied schema, most descriptive fields remain nullable. CHECK
--   alone does not reject NULL; city and product category have no domain CHECK.
-- * discount defaults to zero when an insert omits it.
-- Indexes support the frequent customer joins and date filtering in this project.

CREATE TABLE IF NOT EXISTS customers (
    customer_id        INTEGER      PRIMARY KEY,
    customer_name      VARCHAR(100) NOT NULL,
    gender             VARCHAR(10)  CHECK (gender IN ('Male', 'Female')),
    city               VARCHAR(50),
    registration_date  DATE,
    customer_segment   VARCHAR(20)  CHECK (customer_segment IN ('Retail', 'Corporate', 'VIP'))
);

CREATE TABLE IF NOT EXISTS orders (
    order_id          INTEGER       PRIMARY KEY,
    customer_id       INTEGER       NOT NULL REFERENCES customers (customer_id),
    order_date        DATE          NOT NULL,
    product_name      VARCHAR(100),
    product_category  VARCHAR(50),
    quantity          INTEGER       CHECK (quantity > 0),
    unit_price        NUMERIC(12,2) CHECK (unit_price >= 0),
    cost_price        NUMERIC(12,2) CHECK (cost_price >= 0),
    discount          NUMERIC(5,2)  DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
    payment_method    VARCHAR(30)   CHECK (payment_method IN ('M-Pesa', 'Cash', 'Card', 'Bank Transfer')),
    order_status      VARCHAR(20)   CHECK (order_status IN ('Completed', 'Pending', 'Cancelled'))
);

CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders (customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders (order_date);
