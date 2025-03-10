WITH base AS (
    SELECT
        donor_name,
        year,
        drf."DT_region" AS region_name,
        coalesce(sum(usd_disbursement_defl), 0) AS bilateral_oda,
        coalesce(sum(usd_disbursement_defl), 0) * 100 / sum(sum(usd_disbursement_defl)) OVER (PARTITION BY donor_name, year) AS share
    FROM "{{crs_file}}" crs
    LEFT JOIN "{{dt_regions_file}}" drf ON drf."microdata_region" = crs.region_name
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND region_name IS NOT NULL 
    GROUP BY 1,2,3
)

SELECT 
    b.year AS year,
    b.region_name AS "Region",
    round(b.bilateral_oda * (dfl.deflator / 100), 2) AS "Bilateral ODA",
    round(b.share,1) || '%' AS "Share",
    b.donor_name AS donor,
FROM base b
LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
ORDER BY donor_name, year DESC, "Bilateral ODA" DESC