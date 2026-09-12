-- ============================================================
-- Pharmaceutical Data Quality & SQL Analysis
-- Section 1: Database Exploration
-- Dataset: Synthetic Pharmaceutical Data
-- ============================================================


-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

USE pharma_steward_practice;


-- ============================================================
-- 2. DATABASE OVERVIEW
-- ============================================================

-- 2.1 List all tables
SHOW TABLES;


-- 2.2 Create a row-count inventory for all tables
SELECT 'products' AS table_name, COUNT(*) AS row_count
FROM products

UNION ALL

SELECT 'countries', COUNT(*)
FROM countries

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'sales_orders', COUNT(*)
FROM sales_orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'batches', COUNT(*)
FROM batches

UNION ALL

SELECT 'product_registrations', COUNT(*)
FROM product_registrations

UNION ALL

SELECT 'staging_product_updates', COUNT(*)
FROM staging_product_updates;


-- ============================================================
-- 3. PRODUCTS TABLE
-- ============================================================

-- 3.1 Inspect the structure of the products table
DESCRIBE products;


-- 3.2 Preview sample product records
SELECT *
FROM products
LIMIT 10;


-- 3.3 Count the total number of products
SELECT COUNT(*) AS total_products
FROM products;


-- ============================================================
-- 4. COUNTRIES TABLE
-- ============================================================

-- 4.1 Inspect the structure of the countries table
DESCRIBE countries;


-- 4.2 Review all countries covered by the dataset
SELECT *
FROM countries
LIMIT 10;


-- 4.3 Count the number of distinct regions
SELECT COUNT(DISTINCT region) AS distinct_region_count
FROM countries;


-- ============================================================
-- 5. CUSTOMERS TABLE
-- ============================================================

-- 5.1 Inspect the structure of the customers table
DESCRIBE customers;


-- 5.2 Preview sample customer records
SELECT *
FROM customers
LIMIT 10;


-- ============================================================
-- 6. SALES ORDERS TABLE
-- ============================================================

-- 6.1 Inspect the structure of the sales_orders table
DESCRIBE sales_orders;


-- 6.2 Preview sample sales order records
SELECT * 
FROM sales_orders 
LIMIT 10;


-- ============================================================
-- 7. ORDER ITEMS TABLE
-- ============================================================

-- 7.1 Inspect the structure of the order_items table
DESCRIBE order_items;


-- 7.2 Preview sample order item records
SELECT * 
FROM order_items 
LIMIT 10;


-- ==========================================================
-- 8. BATCHES TABLE
-- ==========================================================

-- 8.1 Inspect the structure of the batches table
DESCRIBE batches;


-- 8.2 Preview sample batches records
SELECT * 
FROM batches 
LIMIT 10;


-- ==========================================================
-- 9. PRODUCT REGISTRATIONS TABLE
-- ==========================================================

-- 9.1 Inspect the structure of the product_registrations table
DESCRIBE product_registrations;


-- 9.2 Preview sample product_registrations records
SELECT * 
FROM product_registrations 
LIMIT 10;


-- ==========================================================
-- 10. STAGING PRODUCT UPDATES TABLE
-- ==========================================================

-- 10.1 Inspect the structure of the staging_product_updates table
DESCRIBE staging_product_updates;


-- 10.2 Preview sample staging_product_updates records
SELECT * 
FROM staging_product_updates
LIMIT 10;
