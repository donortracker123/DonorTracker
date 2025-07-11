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
--     AND donor_name != 'EU Institutions'
--     AND "Markers" = 20
-- ), 
WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code,
        climate_adaptation, 
        climate_mitigation,
        greatest(climate_mitigation, climate_adaptation) climate_total, 
        usd_commitment_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND aid_t IN {{allocable_aid_categories}}
    AND category = 10
    AND donor_name != 'EU Institutions'
),

rio_totals AS (
    SELECT 
        b.donor_name,
        year,
        sum(coalesce(usd_commitment_defl, 0)) AS sector_bilateral_oda
    FROM base b 
    WHERE climate_total IN (1,2) --Marker for climate-related
    GROUP BY 1,2
), 

-- allocable_totals AS (
--     SELECT
--         "donornameE" AS donor_name,
--         "Year" AS year,
--         sum(usd_commitment_defl) AS total_oda
--     FROM read_csv_auto("{{climate_riomarkers_file}}", delim='|', header=True)
--     WHERE "Year" BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
--     AND donor_name IN {{dac_countries}}
--     AND donor_name != 'EU Institutions'
--     AND "Allocable" = 2
--     AND "Markers" = 20
--     GROUP BY 1,2
-- ),

allocable_totals AS (
    SELECT
        donor_name,
        year,
        sum(usd_commitment_defl) AS total_oda
    FROM "{{crs_file}}"
    WHERE "Year" BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND donor_name != 'EU Institutions' --Exclude EUI in rankings
    AND aid_t IN {{allocable_aid_categories}} --Marker for allocable ODA
    AND category = 10
    GROUP BY 1,2
),

joined AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        at.total_oda AS allocable_oda,
        (ct.sector_bilateral_oda * 100) / at.total_oda AS sector_percentage
    FROM rio_totals ct 
    LEFT JOIN allocable_totals at USING(donor_name, year)
), 

ranked AS (
    SELECT 
        donor,
        year,
        allocable_oda,
        round(sector_percentage,1) AS sector_percentage,
        row_number() OVER (PARTITION BY year ORDER BY sector_percentage DESC) AS rn
    FROM joined
)

SELECT 
    donor AS "Donor", 
    sector_percentage || '%' "perc",
    year "Year", 
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Ranking"
FROM ranked