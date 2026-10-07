-- ============================================================
-- Pharmaceutical Data Quality Analysis with SQL
-- Section 5: Advanced SQL Challenges
-- Dataset: Synthetic Pharmaceutical Data
-- ============================================================


-- ============================================================
-- SELECT DATABASE
-- ============================================================

USE pharma_steward_practice;


-- ============================================================
-- 29. Find the highest-revenue active Rx product by country
-- ============================================================

WITH product_revenue AS (
    SELECT
        c.country_code,
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS total_revenue

    FROM sales_orders AS so

    INNER JOIN customers AS c
        ON so.customer_id = c.customer_id

    INNER JOIN order_items AS oi
        ON so.order_id = oi.order_id

    INNER JOIN products AS p
        ON oi.product_id = p.product_id

    WHERE YEAR(so.order_date) = 2025
      AND p.rx_otc = 'Rx'
      AND p.product_status = 'Active'

    GROUP BY
        c.country_code,
        p.product_id,
        p.product_name
),

ranked_products AS (
    SELECT
        country_code,
        product_id,
        product_name,
        total_revenue,

        RANK() OVER (
            PARTITION BY country_code
            ORDER BY total_revenue DESC
        ) AS revenue_rank

    FROM product_revenue
)

SELECT
    country_code,
    product_id,
    product_name,
    ROUND(total_revenue, 2) AS total_revenue,
    revenue_rank
FROM ranked_products
WHERE revenue_rank = 1
ORDER BY
    country_code,
    product_name;


-- ============================================================
-- 30. Create a consolidated data-quality exception report
-- ============================================================

WITH unapproved_sales AS (
    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        so.customer_id,
        cu.country_code,
        pr.registration_status
    FROM order_items AS oi

    INNER JOIN sales_orders AS so
        ON oi.order_id = so.order_id

    INNER JOIN customers AS cu
        ON so.customer_id = cu.customer_id

    LEFT JOIN product_registrations AS pr
        ON oi.product_id = pr.product_id
        AND cu.country_code = pr.country_code

    WHERE pr.registration_status != 'Approved'
       OR pr.registration_status IS NULL
),

unsafe_batch_usage AS (
    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.batch_id,
        b.batch_status
    FROM order_items AS oi

    INNER JOIN batches AS b
        ON oi.batch_id = b.batch_id

    WHERE b.batch_status IN ('Recalled', 'Quarantined')
),

inactive_customer_orders AS (
    SELECT
        so.order_id,
        so.customer_id,
        c.customer_name,
        c.customer_status
    FROM sales_orders AS so

    INNER JOIN customers AS c
        ON so.customer_id = c.customer_id

    WHERE c.customer_status = 'Inactive'
),

delivered_orders_missing_date AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        delivery_date
    FROM sales_orders

    WHERE order_status = 'Delivered'
      AND delivery_date IS NULL
)

SELECT
    'UNAPPROVED SALE' AS issue_type,

    uas.order_item_id AS record_id,

    CONCAT(
        'Product ',
        uas.product_id,
        ' was sold in ',
        uas.country_code,
        ' with registration status: ',
        COALESCE(uas.registration_status, 'Missing')
    ) AS detail

FROM unapproved_sales AS uas

UNION ALL

SELECT
    'RECALLED OR QUARANTINED BATCH' AS issue_type,

    ubu.order_item_id AS record_id,

    CONCAT(
        'Batch ',
        ubu.batch_id,
        ' with status ',
        ubu.batch_status,
        ' was used for product ',
        ubu.product_id,
        ' in order ',
        ubu.order_id
    ) AS detail

FROM unsafe_batch_usage AS ubu

UNION ALL

SELECT
    'INACTIVE CUSTOMER ORDER' AS issue_type,

    ico.order_id AS record_id,

    CONCAT(
        'Order ',
        ico.order_id,
        ' was placed by inactive customer ',
        ico.customer_id,
        ' - ',
        ico.customer_name
    ) AS detail

FROM inactive_customer_orders AS ico

UNION ALL

SELECT
    'MISSING DELIVERY DATE' AS issue_type,

    dod.order_id AS record_id,

    CONCAT(
        'Order ',
        dod.order_id,
        ' is marked as Delivered but has no delivery date'
    ) AS detail

FROM delivered_orders_missing_date AS dod

ORDER BY
    issue_type,
    record_id;


-- ============================================================
-- 31. Create a cleaned preview of the staging data
--     by standardizing whitespace and letter casing
--     without changing the original table
-- ============================================================

SELECT
    staging_id,

    source_product_id AS original_product_id,
    TRIM(source_product_id) AS cleaned_product_id,

    source_product_name AS original_product_name,
    CONCAT(
        UPPER(LEFT(TRIM(source_product_name), 1)),
        LOWER(SUBSTRING(TRIM(source_product_name), 2))
    ) AS cleaned_product_name,

    therapeutic_area AS original_therapeutic_area,
    CONCAT(
        UPPER(LEFT(TRIM(therapeutic_area), 1)),
        LOWER(SUBSTRING(TRIM(therapeutic_area), 2))
    ) AS cleaned_therapeutic_area,

    country_code AS original_country_code,
    UPPER(TRIM(country_code)) AS cleaned_country_code,

    source_status AS original_status,
    CONCAT(
        UPPER(LEFT(TRIM(source_status), 1)),
        LOWER(SUBSTRING(TRIM(source_status), 2))
    ) AS cleaned_status,

    loaded_at

FROM staging_product_updates

ORDER BY staging_id;


-- ============================================================
-- 32. Create master-data suggestions for matched staging products
-- ============================================================

SELECT
    spu.staging_id,
    spu.source_product_id,
    p.product_id AS master_product_id,

    spu.source_product_name AS staging_product_name,
    p.product_name AS master_product_name,

    CASE
        WHEN p.product_id IS NOT NULL
            THEN p.product_name
        ELSE NULL
    END AS suggested_product_name,

    spu.therapeutic_area AS staging_therapeutic_area,
    p.therapeutic_area AS master_therapeutic_area,

    CASE
        WHEN p.product_id IS NOT NULL
            THEN p.therapeutic_area
        ELSE NULL
    END AS suggested_therapeutic_area,

    spu.source_status AS staging_status,
    p.product_status AS master_product_status,

    CASE
        WHEN p.product_id IS NOT NULL
            THEN p.product_status
        ELSE NULL
    END AS suggested_product_status

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

ORDER BY spu.staging_id;


-- ============================================================
-- 33. Assign a remediation action to each staging record
-- ============================================================

SELECT
    spu.staging_id,
    spu.source_product_id,
    spu.source_product_name,
    spu.therapeutic_area,
    spu.country_code,
    spu.source_status,

    CASE
        WHEN spu.source_product_id IS NULL
          OR spu.source_product_name IS NULL
          OR spu.therapeutic_area IS NULL
          OR spu.country_code IS NULL
          OR spu.source_status IS NULL
          OR p.product_id IS NULL
          OR c.country_code IS NULL
            THEN 'MANUAL REVIEW'

        WHEN CAST(spu.source_product_name AS BINARY)
             <> CAST(p.product_name AS BINARY)

          OR CAST(spu.therapeutic_area AS BINARY)
             <> CAST(p.therapeutic_area AS BINARY)

          OR CAST(spu.source_status AS BINARY)
             <> CAST(p.product_status AS BINARY)

          OR CAST(spu.country_code AS BINARY)
             <> CAST(c.country_code AS BINARY)
            THEN 'STANDARDIZE'

        ELSE 'ACCEPT'
    END AS remediation_action

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

LEFT JOIN countries AS c
    ON spu.country_code = c.country_code

ORDER BY spu.staging_id;
	

-- ============================================================
-- 34. Summarize remediation actions by count and percentage
-- ============================================================

WITH remediation_results AS (
    SELECT
        spu.staging_id,

        CASE
            WHEN spu.source_product_id IS NULL
              OR spu.source_product_name IS NULL
              OR spu.therapeutic_area IS NULL
              OR spu.country_code IS NULL
              OR spu.source_status IS NULL
              OR p.product_id IS NULL
              OR c.country_code IS NULL
                THEN 'MANUAL REVIEW'

            WHEN CAST(spu.source_product_name AS BINARY)
                 <> CAST(p.product_name AS BINARY)

              OR CAST(spu.therapeutic_area AS BINARY)
                 <> CAST(p.therapeutic_area AS BINARY)

              OR CAST(spu.source_status AS BINARY)
                 <> CAST(p.product_status AS BINARY)

              OR CAST(spu.country_code AS BINARY)
                 <> CAST(c.country_code AS BINARY)
                THEN 'STANDARDIZE'

            ELSE 'ACCEPT'
        END AS remediation_action

    FROM staging_product_updates AS spu

    LEFT JOIN products AS p
        ON spu.source_product_id = p.product_id

    LEFT JOIN countries AS c
        ON spu.country_code = c.country_code
)

SELECT
    remediation_action,

    COUNT(*) AS record_count,

    ROUND(
        COUNT(*) * 100.0
        / (
            SELECT COUNT(*)
            FROM remediation_results
        ),
        2
    ) AS percentage

FROM remediation_results

GROUP BY remediation_action

ORDER BY record_count DESC;


-- ============================================================
-- 35. Create the final data remediation report
-- ============================================================

WITH remediation_report AS (

    SELECT
        spu.staging_id,
        spu.source_product_id,

        spu.source_product_name AS staging_product_name,
        p.product_name AS master_product_name,

        spu.therapeutic_area AS staging_therapeutic_area,
        p.therapeutic_area AS master_therapeutic_area,

        spu.country_code AS staging_country_code,
        c.country_code AS master_country_code,
        c.country_name AS master_country_name,

        spu.source_status AS staging_status,
        p.product_status AS master_product_status,

        -- Combine all detected issues into one column
        COALESCE(
            NULLIF(
                CONCAT_WS(
                    ', ',

                    CASE
                        WHEN spu.source_product_id IS NULL
                        THEN 'Missing product ID'
                    END,

                    CASE
                        WHEN spu.source_product_name IS NULL
                        THEN 'Missing product name'
                    END,

                    CASE
                        WHEN spu.therapeutic_area IS NULL
                        THEN 'Missing therapeutic area'
                    END,

                    CASE
                        WHEN spu.country_code IS NULL
                        THEN 'Missing country code'
                    END,

                    CASE
                        WHEN spu.source_status IS NULL
                        THEN 'Missing product status'
                    END,

                    CASE
                        WHEN spu.source_product_id IS NOT NULL
                         AND p.product_id IS NULL
                        THEN 'Unknown product ID'
                    END,

                    CASE
                        WHEN spu.country_code IS NOT NULL
                         AND c.country_code IS NULL
                        THEN 'Invalid country code'
                    END,

                    CASE
                        WHEN p.product_id IS NOT NULL
                         AND spu.source_product_name IS NOT NULL
                         AND CAST(spu.source_product_name AS BINARY)
                             <> CAST(p.product_name AS BINARY)
                        THEN 'Product name differs from master'
                    END,

                    CASE
                        WHEN p.product_id IS NOT NULL
                         AND spu.therapeutic_area IS NOT NULL
                         AND CAST(spu.therapeutic_area AS BINARY)
                             <> CAST(p.therapeutic_area AS BINARY)
                        THEN 'Therapeutic area differs from master'
                    END,

                    CASE
                        WHEN p.product_id IS NOT NULL
                         AND spu.source_status IS NOT NULL
                         AND CAST(spu.source_status AS BINARY)
                             <> CAST(p.product_status AS BINARY)
                        THEN 'Product status differs from master'
                    END
                ),
                ''
            ),
            'No issue'
        ) AS data_quality_issues,

        -- Assign the recommended remediation action
        CASE
            WHEN spu.source_product_id IS NULL
              OR spu.source_product_name IS NULL
              OR spu.therapeutic_area IS NULL
              OR spu.country_code IS NULL
              OR spu.source_status IS NULL
              OR p.product_id IS NULL
              OR c.country_code IS NULL
            THEN 'MANUAL REVIEW'

            WHEN CAST(spu.source_product_name AS BINARY)
                     <> CAST(p.product_name AS BINARY)
              OR CAST(spu.therapeutic_area AS BINARY)
                     <> CAST(p.therapeutic_area AS BINARY)
              OR CAST(spu.source_status AS BINARY)
                     <> CAST(p.product_status AS BINARY)
            THEN 'STANDARDIZE'

            ELSE 'ACCEPT'
        END AS remediation_action

    FROM staging_product_updates AS spu

    LEFT JOIN products AS p
        ON spu.source_product_id = p.product_id

    LEFT JOIN countries AS c
        ON spu.country_code = c.country_code
)

SELECT
    staging_id,
    source_product_id,

    staging_product_name,
    master_product_name,

    staging_therapeutic_area,
    master_therapeutic_area,

    staging_country_code,
    master_country_code,
    master_country_name,

    staging_status,
    master_product_status,

    data_quality_issues,
    remediation_action

FROM remediation_report

ORDER BY staging_id;
    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
