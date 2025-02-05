WITH base AS (
    SELECT
        donor_name,
        year,
        region_name,
        coalesce(sum(usd_disbursement_defl), 0) AS bilateral_oda,
        coalesce(sum(usd_disbursement_defl), 0) * 100 / sum(sum(usd_disbursement_defl)) OVER (PARTITION BY donor_name, year) AS share
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    GROUP BY 1,2,3
)

SELECT 
    b.donor_name AS donor,
    b.year,
    b.region_name AS "Region",
    round(b.share,1) || '%' AS share,
    b.bilateral_oda * dfl.deflator AS "Bilateral ODA"
FROM base b
LEFT JOIN "{{deflator_file}}" dfl ON dfl.year = b.year AND dfl.donor = b.donor_name
ORDER BY 1, 2 DESC, 5 DESC