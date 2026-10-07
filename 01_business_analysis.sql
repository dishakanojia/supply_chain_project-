/*
   FILE 01 - BUSINESS ANALYSIS: how big is the problem, and where is it?

   Method: work out the late rate for every group of every dimension.
   - If one dimension shows big differences, it is a likely cause.
   - If the late rate is the same everywhere, it is NOT the cause.

   Trick used everywhere: is_late is 1 or 0, so AVG(is_late) is the share
   of late orders. 100 * AVG(is_late) = late %.
 */

USE supply_chain;


-- PART A: HOW BIG IS THE PROBLEM?


-- A1. How many orders are late?
SELECT COUNT(*)                     AS total_orders,
       SUM(is_late)                 AS late_orders,
       ROUND(100 * AVG(is_late), 1) AS late_pct
FROM orders;

-- A2. How much revenue is delivered late, and how late?
SELECT ROUND(SUM(revenue), 0)        AS revenue_delivered_late,
       ROUND(AVG(days_vs_promise), 2) AS avg_days_late
FROM orders
WHERE is_late = 1;

-- A3. Total revenue (to compare with A2)
SELECT ROUND(SUM(revenue), 0) AS total_revenue
FROM orders;

-- A4. Late, on time or early?
SELECT delivery_status,
       COUNT(*) AS orders,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS pct_of_orders
FROM orders
GROUP BY delivery_status
ORDER BY orders DESC;

-- 
-- PART B: WHERE IS IT? Late rate by each dimension
-- 

-- B1. By SHIPPING MODE  <-- big differences here
SELECT shipping_mode,
       COUNT(*)                     AS orders,
       ROUND(100 * AVG(is_late), 1) AS late_pct,
       MIN(promised_days)           AS promised_days,
       ROUND(AVG(actual_days), 2)   AS avg_actual_days,
       MIN(actual_days)             AS fastest,
       MAX(actual_days)             AS slowest
FROM orders
GROUP BY shipping_mode
ORDER BY late_pct DESC;

-- B2. By MARKET
SELECT market,
       COUNT(*)                     AS orders,
       ROUND(100 * AVG(is_late), 1) AS late_pct
FROM orders
GROUP BY market
ORDER BY late_pct DESC;

-- B3. By REGION (23 regions)
SELECT order_region,
       COUNT(*)                     AS orders,
       ROUND(100 * AVG(is_late), 1) AS late_pct
FROM orders
GROUP BY order_region
ORDER BY late_pct DESC;

-- B4. By CUSTOMER SEGMENT
SELECT customer_segment,
       COUNT(*)                     AS orders,
       ROUND(100 * AVG(is_late), 1) AS late_pct
FROM orders
GROUP BY customer_segment
ORDER BY late_pct DESC;

-- B5. By PRODUCT DEPARTMENT (uses the order_lines table)
SELECT department_name,
       COUNT(*)                     AS order_lines,
       ROUND(100 * AVG(is_late), 1) AS late_pct
FROM order_lines
GROUP BY department_name
ORDER BY late_pct DESC;

-- B6. Over TIME: by year and quarter
SELECT YEAR(order_date)             AS order_year,
       QUARTER(order_date)          AS order_quarter,
       COUNT(*)                     AS orders,
       ROUND(100 * AVG(is_late), 1) AS late_pct
FROM orders
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY order_year, order_quarter;


-- PART C: WHICH DIMENSION MATTERS MOST?
-- Gap = worst group's late % minus best group's late %.
-- A big gap means the dimension drives lateness.


-- C1. Gap between shipping modes
SELECT ROUND(MAX(late_pct) - MIN(late_pct), 1) AS shipping_mode_gap
FROM (SELECT shipping_mode, 100 * AVG(is_late) AS late_pct
      FROM orders GROUP BY shipping_mode) AS t;

-- C2. Gap between regions
SELECT ROUND(MAX(late_pct) - MIN(late_pct), 1) AS region_gap
FROM (SELECT order_region, 100 * AVG(is_late) AS late_pct
      FROM orders GROUP BY order_region) AS t;

-- C3. Gap between markets
SELECT ROUND(MAX(late_pct) - MIN(late_pct), 1) AS market_gap
FROM (SELECT market, 100 * AVG(is_late) AS late_pct
      FROM orders GROUP BY market) AS t;

-- C4. Gap between customer segments
SELECT ROUND(MAX(late_pct) - MIN(late_pct), 1) AS segment_gap
FROM (SELECT customer_segment, 100 * AVG(is_late) AS late_pct
      FROM orders GROUP BY customer_segment) AS t;
