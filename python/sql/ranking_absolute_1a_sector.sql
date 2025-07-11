WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
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
        sum(coalesce(usd_disbursement_defl, 0)) AS bilateral_oda
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    WHERE dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2
), 

one_campaign_totals AS (
    SELECT 
        imf.donor_name,
        imf.year, 
        sum(coalesce(nullif(value, 'nan'), 0)) AS multilateral_oda, --ONE CAMPAIGN SAVED VALUES AS 'nan'
    FROM "{{imputed_multilateral_file}}" imf
    INNER JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    WHERE dsf.sector_renamed = '{{sector}}'    
    GROUP BY 1,2
), 

deflated AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        {% if deflate %}
            dfl.deflator,
            ct.bilateral_oda * dfl.deflator / 100 AS bilateral_oda,
            oct.multilateral_oda AS multilateral_oda, --ONE Campaign came pre-deflated
            (ct.bilateral_oda * dfl.deflator / 100) + oct.multilateral_oda AS total_oda --pre-deflated
        {% else %}
            dfl.deflator,
            ct.bilateral_oda AS bilateral_oda,
            oct.multilateral_oda AS multilateral_oda, --ONE Campaign came pre-deflated
            (ct.bilateral_oda) + oct.multilateral_oda AS total_oda --pre-deflated
        {% endif %}
    FROM crs_totals ct 
    INNER JOIN one_campaign_totals oct USING(donor_name, year)
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = ct.donor_name AND dfl.year = {{latest_year}}
), 

ranked AS (
    SELECT 
        donor,
        year,
        sum(total_oda) AS total_oda,
        row_number() OVER (PARTITION BY year ORDER BY sum(total_oda) DESC) AS rn
    FROM deflated
    GROUP BY 1,2
)

SELECT 
    donor "Donor", 
    round(total_oda, 2) "ODA towards {{sector}}",
    Year, 
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Ranking"
FROM ranked
ORDER BY year, total_oda DESC