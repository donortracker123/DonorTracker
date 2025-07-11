WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code,
        purpose_name,
        sector_name,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
), 

transformed AS (
    SELECT 
        b.donor_name,
        b.year,
        b.purpose_name,
        {% if deflate %}
            b.usd_disbursement_defl / 100 * dfl.deflator AS bilateral_oda
        {% else %}
            b.usd_disbursement_defl AS bilateral_oda
        {% endif %}
    FROM base b 
    INNER JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE dsf.sector_renamed = '{{sector}}'
)

SELECT 
    year,
    purpose_name AS Sector,
    'DAC Countries' AS donor,
    sum(bilateral_oda) AS "Bilateral ODA for",
    sum(bilateral_oda) * 100 / sum(sum(bilateral_oda)) OVER (PARTITION BY year) AS share
FROM transformed
WHERE year = 2022
GROUP BY 1,2
ORDER BY 1 DESC, 4 DESC