WITH base AS (
    SELECT
        donor_name,
        year,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
    AND coalesce(gender, 0) IN (1,2) --Marker for Gender-related
    AND "Aid_T" IN ('A02', 'B01', 'B03', 'B031', 'B032', 'B033','B04', 'C01', 'D01', 'D02', 'E01')
), 

allocable_totals AS (
    SELECT 
        "Donor_1" AS donor_name,
        "TIME_PERIOD" AS year,
        sum("OBS_VALUE") AS total_oda
    FROM "{{allocable_gender_file}}"
    WHERE 1=1
    AND year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND "Donor_1" IN {{dac_countries}}
    AND "Donor_1" != 'EU Institutions'
    GROUP BY 1,2
),

crs_totals AS (
    SELECT 
        b.donor_name,
        year,
        sum(coalesce(usd_disbursement_defl, 0)) AS sector_bilateral_oda
    FROM base b 
    GROUP BY 1,2
), 

joined AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        ct.sector_bilateral_oda,
        alt.total_oda AS allocable_oda,
        (ct.sector_bilateral_oda * 100) / alt.total_oda AS sector_percentage
    FROM crs_totals ct 
    LEFT JOIN allocable_totals alt USING(donor_name, year)
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
    donor, 
    sector_percentage || '%' "ODA to Gender as % of Total ODA",
    year "Year", 
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Rank"
FROM ranked
ORDER BY year, sector_percentage DESC