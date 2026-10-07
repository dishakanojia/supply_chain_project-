-- FILE 00 - CREATE THE TABLES AND LOAD THE CLEAN DATA

-- The data was already cleaned in Python (notebooks/01_data_cleaning.ipynb).
-- This file just puts the two clean CSV files into MySQL:
    -- orders       -> one row per order        (62,897 rows)
    -- order_lines  -> one row per product line (172,765 rows)


CREATE DATABASE IF NOT EXISTS supply_chain;
USE supply_chain;


-- Table 1: orders (one row per shipped order)

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id          INT PRIMARY KEY,
    order_date        DATETIME,
    shipping_mode     VARCHAR(20),     -- Standard Class / Second Class / First Class / Same Day
    promised_days     INT,             -- days DataCo promised
    actual_days       INT,             -- days it really took
    days_vs_promise   INT,             -- actual - promised (+ = late, - = early)
    delivery_status   VARCHAR(30),     -- Late delivery / Shipping on time / Advance shipping
    is_late           INT,             -- 1 = late, 0 = not late
    market            VARCHAR(20),
    order_region      VARCHAR(30),
    order_country     VARCHAR(60),
    customer_segment  VARCHAR(20),
    order_lines       INT,             -- number of products in the order
    units             INT,
    revenue           DECIMAL(12,2),   -- what the customer paid
    profit            DECIMAL(12,2)
);
-- Table 2: order_lines (one row per product in an order)

DROP TABLE IF EXISTS order_lines;

CREATE TABLE order_lines (
    order_item_id     INT PRIMARY KEY,
    order_id          INT,
    department_name   VARCHAR(40),
    category_name     VARCHAR(60),
    product_name      VARCHAR(80),
    quantity          INT,
    revenue           DECIMAL(12,2),
    profit            DECIMAL(12,2),
    is_late           INT
);


-- Load the CSV files.
-- Copy both files into the MySQL upload folder first. To see the folder:
--     SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders_clean.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_lines_clean.csv'
INTO TABLE order_lines
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Check: should be 62897 and 172765
SELECT COUNT(*) AS orders_loaded      FROM orders;
SELECT COUNT(*) AS order_lines_loaded FROM order_lines;
