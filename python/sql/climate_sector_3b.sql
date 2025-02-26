WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_name,
        purpose_code,
        greatest(climate_mitigation, climate_adaptation) climate_total, 
        usd_commitment_defl
    FROM "{{crs_file}}"
    WHERE year = ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
), 

crs_totals AS (
    SELECT 
        b.donor_name,
        b.year,
        dsf.sector_renamed,
        sum(coalesce(b.usd_commitment_defl, 0) / 100 * dfl.deflator) AS bilateral_oda,
        sum(sum(coalesce(b.usd_commitment_defl, 0) / 100 * dfl.deflator)) OVER (PARTITION BY b.donor_name, b.year) AS allocable_oda
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE b.climate_total IN (1,2)
    GROUP BY 1,2,3
)

SELECT 
    sector_renamed AS Sector,
    bilateral_oda AS "Climate-related ODA to",
    round(100 * (bilateral_oda / allocable_oda)) || '%' AS "Share",
    donor_name AS donor,
FROM crs_totals ct 
ORDER BY 4, 2 DESC