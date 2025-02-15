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
        b.donor_name,
        b.year,
        sum(coalesce(usd_disbursement_defl, 0) * dfl.deflator) AS bilateral_oda
    FROM base b 
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    GROUP BY 1,2
)

SELECT * 
FROM crs_totals