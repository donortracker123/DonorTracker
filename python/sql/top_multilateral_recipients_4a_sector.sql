WITH one_campaign_totals AS (
    SELECT 
        imf.donor_name AS donor,
        imf.mapped_name,
        dmf.abbreviation,
        imf.year,
        sum(coalesce(nullif(value, 'nan'), 0)) AS oda,
        sum(sum(coalesce(nullif(value, 'nan'), 0))) OVER (PARTITION BY donor_name, year) AS total_multilateral_oda
    FROM "{{imputed_multilateral_file}}" imf
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    LEFT JOIN "{{dt_multilaterals_file}}" dmf ON dmf.multilateral_name = imf.mapped_name
    WHERE imf.year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2,3,4
), 

crs_totals AS (
    SELECT
        b.donor_name,
        b.year,
        {% if deflate %}
            sum((b.usd_disbursement_defl * dfl.deflator) / 100) AS total_bilateral_oda
        {% else %}
            sum(b.usd_disbursement_defl) AS total_bilateral_oda
        {% endif %}
    FROM "{{crs_file}}" b
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE b.year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2
)

SELECT
    oct.year AS "Year",
    oct.abbreviation AS "Multi_short",
    round(oct.oda, 2) AS "ODA",
    100 * round((oct.oda) / (crt.total_bilateral_oda + oct.total_multilateral_oda), 2) || '%' AS "Share",
    oct.mapped_name AS "Full Name",
    oct.donor
FROM one_campaign_totals oct
LEFT JOIN crs_totals crt ON crt.donor_name = oct.donor AND crt.year = oct.year
ORDER BY donor, "Multi_short", "Year"
