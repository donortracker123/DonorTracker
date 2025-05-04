WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_name,
        purpose_code,
        gender,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}}) --NOTE: Flourish only has one year
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND "Aid_T" IN ('A02', 'B01', 'B03', 'B031', 'B032', 'B033','B04', 'C01', 'D01', 'D02', 'E01')
), 

crs_totals AS (
    SELECT 
        b.year,
        dsf.sector_renamed,
        sum(coalesce(b.usd_disbursement_defl, 0) / 100 * dfl.deflator) AS bilateral_oda,
        sum(sum(coalesce(b.usd_disbursement_defl, 0) / 100 * dfl.deflator)) OVER (PARTITION BY b.year) AS total_oda,
        row_number() OVER (PARTITION BY b.year ORDER BY bilateral_oda DESC) AS rn
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE b.gender IN (1,2)
    GROUP BY 1,2
)

SELECT 
    year,
    sector_renamed AS Sector,
    round(bilateral_oda, 2) AS "Gender-related ODA to",
    round(100 * (bilateral_oda / total_oda)) || '%' AS "Share",
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Ranking"
FROM crs_totals ct 
ORDER BY 1, 3 DESC