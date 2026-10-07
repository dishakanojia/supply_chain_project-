/*
   FILE 02 - ROOT CAUSE AND WHAT-IF
 
   File 01 showed that only SHIPPING MODE changes the late rate.
   This file shows WHY (the promise doesn't match reality) and tests
   what happens if the promises are made realistic.
*/

USE supply_chain;

-- PART A: ROOT CAUSE


-- A1. Promise vs reality: how many days does each mode really take?
SELECT shipping_mode,
       promised_days,
       actual_days,
       COUNT(*) AS orders
FROM orders
GROUP BY shipping_mode, promised_days, actual_days
ORDER BY shipping_mode, actual_days;
-- First Class: promised 1 day, EVERY order took 2 days      -> 100% late
-- Second Class: promised 2 days, takes 2 to 6 days evenly   -> 80% late
-- Standard Class: promised 4 days, also takes 2 to 6 days   -> 40% late

-- A2. Does paying for Second Class buy speed compared with Standard?
SELECT shipping_mode,
       ROUND(AVG(actual_days), 2) AS avg_actual_days,
       ROUND(100 * AVG(CASE WHEN actual_days <= 2 THEN 1 ELSE 0 END), 1) AS pct_within_2_days
FROM orders
WHERE shipping_mode IN ('Second Class', 'Standard Class')
GROUP BY shipping_mode;
-- Both take 4.0 days on average: Second Class is no faster.

-- A3. How late are the late orders?
SELECT days_vs_promise AS days_late,
       COUNT(*)        AS late_orders
FROM orders
WHERE is_late = 1
GROUP BY days_vs_promise
ORDER BY days_late;

-- A4. Revenue delivered late, by shipping mode
SELECT shipping_mode,
       ROUND(SUM(revenue), 0) AS revenue,
       ROUND(SUM(CASE WHEN is_late = 1 THEN revenue ELSE 0 END), 0) AS revenue_late
FROM orders
GROUP BY shipping_mode
ORDER BY revenue_late DESC;

-- PART B: WHAT-IF - change only the promise, keep the real delivery days
--   Fix A (no cost): First Class 1 -> 2 days, Same Day 0 -> 1 day
--   Fix B: Fix A + Second Class 2 -> 4 days (same as Standard)
-- An order is still late if actual_days > the NEW promise.


-- B1. Today
SELECT COUNT(*) AS late_orders,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS late_pct
FROM orders
WHERE is_late = 1;

-- B2. Fix A
SELECT COUNT(*) AS late_orders_fix_a,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS late_pct_fix_a
FROM orders
WHERE actual_days > CASE WHEN shipping_mode = 'First Class' THEN 2
                         WHEN shipping_mode = 'Same Day'    THEN 1
                         ELSE promised_days
                    END;

-- B3. Fix B
SELECT COUNT(*) AS late_orders_fix_b,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS late_pct_fix_b
FROM orders
WHERE actual_days > CASE WHEN shipping_mode = 'First Class'  THEN 2
                         WHEN shipping_mode = 'Same Day'     THEN 1
                         WHEN shipping_mode = 'Second Class' THEN 4
                         ELSE promised_days
                    END;
