-- ==========================================================
-- Pharmaceutical Data Quality Analysis
-- Section 4: Data Quality Validation
-- ==========================================================

USE pharma_steward_practice;



-- 19. Find exact duplicate staging rows, excluding staging_id
SELECT
    source_product_id,
    source_product_name,
    therapeutic_area,
    country_code,
    source_status,
    COUNT(*) AS duplicate_count
FROM staging_product_updates
GROUP BY
    source_product_id,
    source_product_name,
    therapeutic_area,
    country_code,
    source_status
HAVING COUNT(*) > 1;



-- 20. Find staging rows with a missing product ID, therapeutic area, or status
SELECT
    staging_id,
    source_product_id,
    therapeutic_area,
    source_status
FROM staging_product_updates
WHERE source_product_id IS NULL
   OR therapeutic_area IS NULL
   OR source_status IS NULL;



-- 21. Find source product IDs missing from the product master
SELECT DISTINCT
    p.product_id,
    spu.source_product_id
FROM staging_product_updates AS spu
LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id
WHERE spu.source_product_id IS NOT NULL
  AND p.product_id IS NULL;



-- 22. Find invalid country codes in staging data
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


