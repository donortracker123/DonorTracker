WITH one_campaign_totals AS (
    SELECT 
        imf.donor_name AS donor,
        imf.mapped_name,
        dmf.abbreviation,
        imf.year,
        sum(coalesce(nullif(value, 'nan'), 0)) AS oda,
        sum(coalesce(nullif(value, 'nan'), 0)) / sum(sum(coalesce(nullif(value, 'nan'), 0))) OVER (PARTITION BY donor_name, year) AS share
    FROM "{{imputed_multilateral_file}}" imf
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    LEFT JOIN "{{dt_multilaterals_file}}" dmf ON dmf.multilateral_name = imf.mapped_name
    WHERE imf.year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2,3,4
)

SELECT
    year AS "Year",
    abbreviation AS "Multi_short",
    oda AS "ODA",
    share AS "Share",
    mapped_name AS "Full Name",
    donor
FROM one_campaign_totals
ORDER BY donor, "Multi_short", "Year"