/* 
   FILE 03 - SAVE THE WHAT-IF RESULTS FOR POWER BI

   Power BI reads three tables from MySQL:
     orders, order_lines (from file 00) and what_if (made here).
   what_if stores the 3 scenario results from file 02 so Power BI can
   draw them as a chart.
 */

USE supply_chain;

DROP TABLE IF EXISTS what_if;

CREATE TABLE what_if (
    sort_order   INT,
    scenario     VARCHAR(60),
    late_orders  INT,
    late_pct     DECIMAL(4,1)
);

-- Today
INSERT INTO what_if
SELECT 1, 'Today',
       COUNT(*),
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1)
FROM orders
WHERE is_late = 1;

-- Fix A
INSERT INTO what_if
SELECT 2, 'Fix A: First Class 2 days, Same Day 1 day',
       COUNT(*),
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1)
FROM orders
WHERE actual_days > CASE WHEN shipping_mode = 'First Class' THEN 2
                         WHEN shipping_mode = 'Same Day'    THEN 1
                         ELSE promised_days
                    END;

-- Fix B
INSERT INTO what_if
SELECT 3, 'Fix B: Fix A + Second Class 4 days',
       COUNT(*),
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1)
FROM orders
WHERE actual_days > CASE WHEN shipping_mode = 'First Class'  THEN 2
                         WHEN shipping_mode = 'Same Day'     THEN 1
                         WHEN shipping_mode = 'Second Class' THEN 4
                         ELSE promised_days
                    END;

-- Check: 36048 / 24798 / 19903
SELECT * FROM what_if ORDER BY sort_order;
