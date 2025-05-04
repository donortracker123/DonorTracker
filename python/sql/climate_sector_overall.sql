-- WITH base AS (
--     SELECT
--         "donornameE" AS donor_name,
--         "Year" AS year,
--         greatest(coalesce("climateMitigation", -1), coalesce("climateAdaptation", -1)) AS climate_total,
--         purposecode,
--         usd_commitment_defl
--     FROM read_csv_auto("{{climate_riomarkers_file}}", delim='|', header=True)
--     WHERE "Year" BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
--     AND donor_name IN {{dac_countries}}
--     AND "Markers" = 20
-- ), 
WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code AS purposecode,
        greatest(climate_mitigation, climate_adaptation) climate_total, 
        usd_commitment_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND aid_t IN {{allocable_aid_categories}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
),

rio_totals AS (
    SELECT 
        b.year,
        dsf.sector_renamed,
        sum(coalesce(b.usd_commitment_defl, 0) / 100 * dfl.deflator) AS bilateral_oda,
        sum(sum(coalesce(b.usd_commitment_defl, 0) / 100 * dfl.deflator)) OVER (PARTITION BY b.year) AS allocable_oda
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purposecode
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE b.climate_total IN (1,2)
    GROUP BY 1,2
)

SELECT 
    year,
    sector_renamed AS Sector,
    round(bilateral_oda,2) AS "Climate-related ODA to",
    round(100 * (bilateral_oda / allocable_oda), 1) || '%' AS "Share",
FROM rio_totals
ORDER BY year, "Climate-related ODA to" DESC