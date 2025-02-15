WITH base AS (
    SELECT
        donor_name,
        year,
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

dac1_totals AS (
    SELECT 
        "Donor_1" AS donor_name,
        "Year" AS year,
        sum("VALUE") AS total_oda
    FROM "{{dac1_file}}"
    WHERE 1=1
    AND year = ({{latest_year}})
    AND "Amount type" = 'Constant Prices (2022 USD millions)'
    --TODO: Change fund flow here for total
    AND "Fund flows" = 'Gross Disbursements'
    AND "Donor_1" IN {{dac_countries}}
    AND "Donor_1" != 'EU Institutions'
    AND "Aid type" = 'I. Official Development Assistance (ODA) (I.A + I.B)'
    GROUP BY 1,2
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

joined AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        d1t.total_oda AS total_oda_dac1,
        (ct.sector_bilateral_oda * 100) / d1t.total_oda AS sector_percentage
    FROM crs_totals ct 
    LEFT JOIN dac1_totals d1t USING(donor_name, year)
), 

ranked AS (
    SELECT 
        donor,
        year,
        total_oda_dac1,
        round(sector_percentage,1) AS sector_percentage,
        row_number() OVER (ORDER BY sector_percentage DESC) AS rn
    FROM joined
)

SELECT 
    donor, 
    year "Year", 
    total_oda_dac1 "Total ODA (DAC1)",
    sector_percentage || '%' "ODA to Climate as % of Total ODA",
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Rank"
FROM ranked