-- ==========================================================
-- Pharmaceutical Data Quality Analysis
-- Section 4: Data Quality Validation
-- ==========================================================


-- ============================================================
-- SELECT DATABASE
-- ============================================================

USE pharma_steward_practice;


-- ============================================================
-- 19. Find exact duplicate staging rows
-- ============================================================

SELECT
    source_product_id,
    source_product_name,
    therapeutic_area,
    country_code,
    source_status,
    loaded_at,
    COUNT(*) AS duplicate_count
FROM staging_product_updates
GROUP BY
    source_product_id,
    source_product_name,
    therapeutic_area,
    country_code,
    source_status,
    loaded_at
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 20. Find staging rows with missing required values
-- ============================================================

SELECT
    staging_id,
    source_product_id,
    therapeutic_area,
    source_status
FROM staging_product_updates
WHERE source_product_id IS NULL
   OR therapeutic_area IS NULL
   OR source_status IS NULL
ORDER BY staging_id;


-- ============================================================
-- 21. Find source product IDs missing from the product master
-- ============================================================

SELECT DISTINCT
    spu.source_product_id
FROM staging_product_updates AS spu
LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id
WHERE spu.source_product_id IS NOT NULL
  AND p.product_id IS NULL
ORDER BY spu.source_product_id;


-- ============================================================
-- 22. Find invalid country codes in staging data
-- ============================================================

SELECT
    spu.staging_id,
    spu.country_code AS staging_country_code,
    c.country_code AS matched_country_code
FROM staging_product_updates AS spu
LEFT JOIN countries AS c
    ON spu.country_code = c.country_code
WHERE spu.country_code IS NOT NULL
  AND c.country_code IS NULL
ORDER BY spu.staging_id;


-- ============================================================
-- 23. Find inconsistent casing or surrounding spaces
-- ============================================================

SELECT
    staging_id,
    source_product_name,

    CASE
        WHEN CAST(source_product_name AS BINARY)
             <> CAST(TRIM(source_product_name) AS BINARY)
            THEN 'SURROUNDING SPACES'

        WHEN CAST(source_product_name AS BINARY)
             <> CAST(
                    CONCAT(
                        UPPER(LEFT(TRIM(source_product_name), 1)),
                        LOWER(SUBSTRING(TRIM(source_product_name), 2))
                    ) AS BINARY
                )
            THEN 'CASING ISSUE'

        ELSE 'OK'
    END AS product_name_quality,

    source_status,

    CASE
        WHEN CAST(source_status AS BINARY)
             <> CAST(TRIM(source_status) AS BINARY)
            THEN 'SURROUNDING SPACES'

        WHEN CAST(source_status AS BINARY)
             <> CAST(
                    CONCAT(
                        UPPER(LEFT(TRIM(source_status), 1)),
                        LOWER(SUBSTRING(TRIM(source_status), 2))
                    ) AS BINARY
                )
            THEN 'CASING ISSUE'

        ELSE 'OK'
    END AS status_quality

FROM staging_product_updates

WHERE CAST(source_product_name AS BINARY)
          <> CAST(TRIM(source_product_name) AS BINARY)

   OR CAST(source_product_name AS BINARY)
          <> CAST(
                 CONCAT(
                     UPPER(LEFT(TRIM(source_product_name), 1)),
                     LOWER(SUBSTRING(TRIM(source_product_name), 2))
                 ) AS BINARY
             )

   OR CAST(source_status AS BINARY)
          <> CAST(TRIM(source_status) AS BINARY)

   OR CAST(source_status AS BINARY)
          <> CAST(
                 CONCAT(
                     UPPER(LEFT(TRIM(source_status), 1)),
                     LOWER(SUBSTRING(TRIM(source_status), 2))
                 ) AS BINARY
             )

ORDER BY staging_id;


-- ============================================================
-- 24. Compare staging and master product names
-- ============================================================

SELECT
    spu.staging_id,
    spu.source_product_id,
    spu.source_product_name AS staging_product_name,
    p.product_name AS master_product_name,

    CASE
        WHEN p.product_id IS NULL
            THEN 'NO MASTER MATCH'

        WHEN LOWER(TRIM(spu.source_product_name))
             = LOWER(TRIM(p.product_name))
            THEN 'MATCH'

        ELSE 'MISMATCH'
    END AS name_comparison

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

ORDER BY spu.staging_id;


-- ============================================================
-- 25. Find active staging products discontinued in the master
-- ============================================================

SELECT
    spu.staging_id,
    spu.source_product_id,
    p.product_name,
    spu.source_status AS staging_status,
    p.product_status AS master_status
FROM staging_product_updates AS spu
INNER JOIN products AS p
    ON spu.source_product_id = p.product_id
WHERE LOWER(TRIM(spu.source_status)) = 'active'
  AND p.product_status = 'Discontinued'
ORDER BY spu.staging_id;


-- ============================================================
-- 26. Summarize staging data-quality issues
-- ============================================================

WITH duplicate_groups AS (
    SELECT
        COUNT(*) AS duplicate_count
    FROM staging_product_updates
    GROUP BY
        source_product_id,
        source_product_name,
        therapeutic_area,
        country_code,
        source_status,
        loaded_at
    HAVING COUNT(*) > 1
)

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN spu.source_product_id IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_ids,

    SUM(
        CASE
            WHEN spu.country_code IS NOT NULL
             AND c.country_code IS NULL
                THEN 1
            ELSE 0
        END
    ) AS invalid_countries,

    SUM(
        CASE
            WHEN spu.source_product_id IS NOT NULL
             AND p.product_id IS NULL
                THEN 1
            ELSE 0
        END
    ) AS unknown_products,

    COALESCE(
        (
            SELECT SUM(duplicate_count - 1)
            FROM duplicate_groups
        ),
        0
    ) AS duplicate_records

FROM staging_product_updates AS spu

LEFT JOIN countries AS c
    ON spu.country_code = c.country_code

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id;













-- 27. Calculate completeness percentage
-- for each nullable staging field
SELECT
    ROUND(
COUNT(source_product_id) * 100.0 / COUNT(*),
        2
    ) AS product_id_completeness,

    ROUND(
        COUNT(source_product_name) * 100.0 / COUNT(*),
        2
    ) AS product_name_completeness,

    ROUND(
        COUNT(therapeutic_area) * 100.0 / COUNT(*),
        2
    ) AS therapeutic_area_completeness,

    ROUND(
        COUNT(country_code) * 100.0 / COUNT(*),
        2
    ) AS country_code_completeness,

    ROUND(
        COUNT(source_status) * 100.0 / COUNT(*),
        2
    ) AS status_completeness

FROM staging_product_updates;




-- 28. Assign each staging row a quality status of PASS or FAIL
SELECT
    spu.staging_id,
    spu.source_product_id,
    spu.source_product_name,
    spu.therapeutic_area,
    spu.country_code,
    spu.source_status,

    CASE
        WHEN spu.source_product_id IS NULL
          OR spu.therapeutic_area IS NULL
          OR spu.country_code IS NULL
          OR spu.source_status IS NULL
          OR p.product_id IS NULL
          OR c.country_code IS NULL
        THEN 'FAIL'
        ELSE 'PASS'
    END AS quality_status

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

LEFT JOIN countries AS c
    ON spu.country_code = c.country_code

ORDER BY spu.staging_id;




-- 29. Create an exception report
-- showing each failed row and its failure reason

SELECT
    spu.staging_id,
    spu.source_product_id,
    spu.source_product_name,
    spu.therapeutic_area,
    spu.country_code,
    spu.source_status,

    'FAIL' AS quality_status,

    CASE
        WHEN spu.source_product_id IS NULL
            THEN 'Missing product ID'

        WHEN spu.therapeutic_area IS NULL
            THEN 'Missing therapeutic area'

        WHEN spu.country_code IS NULL
            THEN 'Missing country code'

        WHEN spu.source_status IS NULL
            THEN 'Missing source status'

        WHEN p.product_id IS NULL
            THEN 'Unknown product ID'

        WHEN c.country_code IS NULL
            THEN 'Invalid country code'
    END AS failure_reason

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

LEFT JOIN countries AS c
    ON spu.country_code = c.country_code

WHERE spu.source_product_id IS NULL
   OR spu.therapeutic_area IS NULL
   OR spu.country_code IS NULL
   OR spu.source_status IS NULL
   OR p.product_id IS NULL
   OR c.country_code IS NULL

ORDER BY spu.staging_id;




-- 30. Create a detailed exception report
-- showing multiple failure reasons for each staging row

SELECT
    spu.staging_id,
    spu.source_product_id,
    spu.source_product_name,
    spu.therapeutic_area,
    spu.country_code,
    spu.source_status,

    'FAIL' AS quality_status,

    CONCAT_WS(
        ', ',

        CASE
            WHEN spu.source_product_id IS NULL
            THEN 'Missing product ID'
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
            THEN 'Missing source status'
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
        END

    ) AS failure_reasons

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

LEFT JOIN countries AS c
    ON spu.country_code = c.country_code

WHERE spu.source_product_id IS NULL
   OR spu.therapeutic_area IS NULL
   OR spu.country_code IS NULL
   OR spu.source_status IS NULL
   OR (
        spu.source_product_id IS NOT NULL
        AND p.product_id IS NULL
   )
   OR (
        spu.country_code IS NOT NULL
        AND c.country_code IS NULL
   )

ORDER BY spu.staging_id;
   