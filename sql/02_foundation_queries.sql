-- ============================================================
-- Pharmaceutical Data Quality Analysis with SQL
-- Section 2: Foundation SQL Queries
-- Dataset: Synthetic Pharmaceutical Data
-- ============================================================


-- ============================================================
-- SELECT DATABASE
-- ============================================================

USE pharma_steward_practice;


-- ============================================================
-- 1. Return all active products, sorted alphabetically
-- ============================================================

SELECT
    product_name,
    product_status
FROM products
WHERE product_status = 'Active'
ORDER BY product_name ASC;


-- ============================================================
-- 2. Show the distinct therapeutic areas
-- ============================================================

SELECT DISTINCT
    therapeutic_area
FROM products
ORDER BY therapeutic_area ASC;


-- ============================================================
-- 3. Count products by Rx/OTC type
-- ============================================================

SELECT
    rx_otc,
    COUNT(*) AS product_count
FROM products
GROUP BY rx_otc
ORDER BY rx_otc ASC;


-- ============================================================
-- 4. Find customers located in the Netherlands or Belgium
-- ============================================================

SELECT
    customer_id,
    customer_name,
    country_code
FROM customers
WHERE country_code IN ('NL', 'BE')
ORDER BY
    country_code,
    customer_name;


-- ============================================================
-- 5. Count orders by order status
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM sales_orders
GROUP BY order_status
ORDER BY order_status ASC;




-- 6. Find delivered orders that took more than 10 days to deliver
SELECT
    order_id,
    order_date,
    delivery_date,
    DATEDIFF(delivery_date, order_date) AS delivery_days
FROM sales_orders
WHERE order_status = 'Delivered'
  AND DATEDIFF(delivery_date, order_date) > 10;



-- 7. Show batches expiring within 180 days after 2026-01-01
SELECT
    batch_id,
    lot_number,
    expiry_date
FROM batches
WHERE expiry_date BETWEEN '2026-01-01'
                      AND DATE_ADD('2026-01-01', INTERVAL 180 DAY)
ORDER BY expiry_date;



-- 8. Return the five most recently launched products
SELECT
    product_id,
    product_name,
    launch_date
FROM products
ORDER BY launch_date DESC
LIMIT 5;
