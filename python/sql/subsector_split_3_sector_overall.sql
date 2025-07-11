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
            (b.usd_disbursement_defl * dfl.deflator) / 100 AS bilateral_oda
        {% else %}
            b.usd_disbursement_defl AS bilateral_oda
        {% endif %}
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE dsf.sector_renamed = '{{sector}}'
)

SELECT 
    year,
    purpose_name AS "Sub-Sector",
    round(sum(bilateral_oda), 2) AS "Bilateral ODA for",
    round(sum(bilateral_oda) * 100 / sum(sum(bilateral_oda)) OVER (PARTITION BY year), 1) || '%' AS "Share",
FROM transformed
GROUP BY year, purpose_name
ORDER BY year DESC, "Bilateral ODA for" DESC