WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year = ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
    AND gender IN (1,2) --Marker for Gender-related
), 

crs_totals AS (
    SELECT 
        b.donor_name AS donor,
        b.year,
        sum(coalesce(usd_disbursement_defl, 0) / 100 * dfl.deflator) AS total_oda
    FROM base b 
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    GROUP BY 1,2
),

ranked AS (
    SELECT 
        donor,
        year,
        sum(total_oda) AS total_oda,
        row_number() OVER (ORDER BY sum(total_oda) DESC) AS rn
    FROM crs_totals
    GROUP BY 1,2
)

SELECT 
    donor "Donor", 
    Year, 
    total_oda "ODA towards Gender",
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Ranking"
FROM ranked