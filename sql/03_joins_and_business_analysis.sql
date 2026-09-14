-- ==========================================================
-- Pharmaceutical Data Quality Analysis
-- Section 3: JOINs and Business Questions
-- ==========================================================

USE pharma_steward_practice;



-- 9. List each customer with its country name and region
SELECT
    c.customer_name,
    co.country_name,
    co.region
FROM customers AS c
LEFT JOIN countries AS co
    ON c.country_code = co.country_code;



-- 10. Show each product and the number of countries
-- in which it is approved
SELECT
    p.product_id,
    p.product_name,
    COUNT(DISTINCT pr.country_code) AS approved_country_count
FROM products AS p
LEFT JOIN product_registrations AS pr
    ON p.product_id = pr.product_id
   AND pr.registration_status = 'Approved'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY p.product_name;



-- 11. Find products with no approved registration in the Netherlands
SELECT
    p.product_id,
    p.product_name
FROM products AS p
LEFT JOIN product_registrations AS pr
    ON p.product_id = pr.product_id
    AND pr.country_code = 'NL'
    AND pr.registration_status = 'Approved'
WHERE pr.registration_id IS NULL;



-- 12. Calculate the gross value of each order item
SELECT
    order_item_id,
    quantity,
    unit_price,
    quantity * unit_price AS gross_line_value
FROM order_items;



-- 13. Calculate net revenue after discount for each product
SELECT
    p.product_id,
    p.product_name,
    COALESCE(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)),
        0
    ) AS net_revenue
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORD,
ER BY
    p.product_name;



-- 14. Calculate total 2025 delivered revenue by country
SELECT
    c.country_code,
    SUM(
        oi.quantity
        * oi.unit_price
        * (1 - oi.discount_pct / 100.0)
    ) AS total_delivered_revenue
FROM customers AS c
INNER JOIN sales_orders AS so
    ON c.customer_id = so.customer_id
INNER JOIN order_items AS oi
    ON so.order_id = oi.order_id
WHERE so.order_status = 'Delivered'
  AND YEAR(so.order_date) = 2025
GROUP BY
    c.country_code
ORDER BY
    total_delivered_revenue DESC;



-- 15. Find the top three customers by delivered net revenue
SELECT
    so.customer_id,
    c.customer_name,
    SUM(
        oi.quantity
        * oi.unit_price
        * (1 - oi.discount_pct / 100.0)
    ) AS net_revenue
FROM sales_orders AS so
INNER JOIN order_items AS oi
    ON so.order_id = oi.order_id
INNER JOIN customers AS c
    ON so.customer_id = c.customer_id
WHERE so.order_status = 'Delivered'
GROUP BY
    so.customer_id,
    c.customer_name
ORDER BY
    net_revenue DESC
LIMIT 3;



-- 16. Compare monthly order counts for 2024 and 2025
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS order_count
FROM sales_orders
WHERE YEAR(order_date) IN (2024, 2025)
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;



-- 17. Find products sold in a country without an approved registration
SELECT DISTINCT
    oi.product_id,
    c.country_code,
    pr.registration_status
FROM order_items AS oi
INNER JOIN sales_orders AS so
    ON oi.order_id = so.order_id
INNER JOIN customers AS c
    ON so.customer_id = c.customer_id
INNER JOIN product_registrations AS pr
    ON oi.product_id = pr.product_id
    AND c.country_code = pr.country_code
WHERE pr.registration_status != 'Approved';



-- 18. Find order items whose batch belongs to a different product
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.batch_id,
    oi.product_id AS ordered_product_id,
    b.product_id AS batch_product_id
FROM order_items AS oi
INNER JOIN batches AS b
    ON oi.batch_id = b.batch_id
WHERE oi.product_id != b.product_id;
	