-- =========================================================
-- Pharmaceutical Data Quality Analysis
-- Section 5: Exception Reporting and Data Remediation
-- =========================================================

USE pharma_steward_practice;



-- 31. Create a cleaned preview of the staging data
-- without changing the original table

SELECT
    staging_id,

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

    source_status AS original_status,

    CONCAT(
        UPPER(LEFT(TRIM(source_status), 1)),
        LOWER(SUBSTRING(TRIM(source_status), 2))
    ) AS cleaned_status

FROM staging_product_updates

ORDER BY staging_id;




-- 32. Review all staging products and suggest
-- master values where a valid product match exists

SELECT
    spu.staging_id,
    spu.source_product_id,

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
    END AS suggested_therapeutic_area

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

ORDER BY spu.staging_id;