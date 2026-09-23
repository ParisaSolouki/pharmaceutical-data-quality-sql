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