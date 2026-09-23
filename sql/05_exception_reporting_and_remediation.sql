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




-- 33. Assign a recommended remediation action
-- to each staging record

SELECT
    spu.staging_id,
    spu.source_product_id,
    spu.source_product_name,
    spu.therapeutic_area,
    spu.country_code,
    spu.source_status,

    CASE
        -- Missing or invalid reference data
        WHEN spu.source_product_id IS NULL
          OR spu.source_product_name IS NULL
          OR spu.therapeutic_area IS NULL
          OR spu.country_code IS NULL
          OR spu.source_status IS NULL
          OR p.product_id IS NULL
          OR c.country_code IS NULL
        THEN 'MANUAL REVIEW'

        -- Product name differs from the master value
        WHEN CAST(TRIM(spu.source_product_name) AS BINARY)
             <> CAST(p.product_name AS BINARY)
        THEN 'STANDARDIZE'

        -- Therapeutic area differs from the master value
        WHEN CAST(TRIM(spu.therapeutic_area) AS BINARY)
             <> CAST(p.therapeutic_area AS BINARY)
        THEN 'STANDARDIZE'

        -- Status has spaces or inconsistent casing
        WHEN CAST(spu.source_status AS BINARY)
             <> CAST(
                    CONCAT(
                        UPPER(LEFT(TRIM(spu.source_status), 1)),
                        LOWER(SUBSTRING(TRIM(spu.source_status), 2))
                    )
                    AS BINARY
                )
        THEN 'STANDARDIZE'

        ELSE 'ACCEPT'
    END AS remediation_action

FROM staging_product_updates AS spu

LEFT JOIN products AS p
    ON spu.source_product_id = p.product_id

LEFT JOIN countries AS c
    ON spu.country_code = c.country_code

ORDER BY spu.staging_id;
	




-- 34. Summarize the number and percentage
-- of records assigned to each remediation action

WITH remediation_results AS (

    SELECT
        spu.staging_id,

        CASE
            -- Missing or invalid reference data
            WHEN spu.source_product_id IS NULL
              OR spu.source_product_name IS NULL
              OR spu.therapeutic_area IS NULL
              OR spu.country_code IS NULL
              OR spu.source_status IS NULL
              OR p.product_id IS NULL
              OR c.country_code IS NULL
            THEN 'MANUAL REVIEW'

            -- Product name differs from master
            WHEN CAST(TRIM(spu.source_product_name) AS BINARY)
                 <> CAST(p.product_name AS BINARY)
            THEN 'STANDARDIZE'

            -- Therapeutic area differs from master
            WHEN CAST(TRIM(spu.therapeutic_area) AS BINARY)
                 <> CAST(p.therapeutic_area AS BINARY)
            THEN 'STANDARDIZE'

            -- Status contains spaces or inconsistent casing
            WHEN CAST(spu.source_status AS BINARY)
                 <> CAST(
                        CONCAT(
                            UPPER(
                                LEFT(
                                    TRIM(spu.source_status),
                                    1
                                )
                            ),
                            LOWER(
                                SUBSTRING(
                                    TRIM(spu.source_status),
                                    2
                                )
                            )
                        )
                        AS BINARY
                    )
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
