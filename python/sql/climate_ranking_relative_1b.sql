WITH base AS (
    SELECT
        donor_name,
        year,
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
        year,
        sum(coalesce(usd_commitment_defl, 0)) AS sector_bilateral_oda
    FROM base b 
    WHERE climate_total IN (1,2) --Marker for climate-related
    GROUP BY 1,2
), 

allocable_totals AS (
    SELECT 
        "Donor_1" AS donor_name,
        "TIME_PERIOD" AS year,
        sum("OBS_VALUE") AS total_oda
    FROM "{{riomarkers_file}}"
    WHERE 1=1
    AND year = ({{latest_year}})
    AND "Donor_1" IN {{dac_countries}}
    AND "Donor_1" != 'EU Institutions'
    GROUP BY 1,2
),

joined AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        at.total_oda AS allocable_oda,
        (ct.sector_bilateral_oda * 100) / at.total_oda AS sector_percentage
    FROM crs_totals ct 
    LEFT JOIN allocable_totals at USING(donor_name, year)
), 

ranked AS (
    SELECT 
        donor,
        year,
        allocable_oda,
        round(sector_percentage,1) AS sector_percentage,
        row_number() OVER (ORDER BY sector_percentage DESC) AS rn
    FROM joined
)

SELECT 
    donor, 
    sector_percentage || '%' "perc",
    year "Year", 
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Rank"
FROM ranked