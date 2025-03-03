WITH one_campaign_totals AS (
    SELECT 
        imf.donor_name AS donor,
        imf.mapped_name,
        --TODO: CASE statement for short names
        imf.year,
        sum(coalesce(nullif(value, 'nan'), 0)) AS oda,
        sum(coalesce(nullif(value, 'nan'), 0)) / sum(sum(coalesce(nullif(value, 'nan'), 0))) over (PARTITION BY donor_name, year) AS share
    FROM "{{imputed_multilateral_file}}" imf
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    WHERE imf.year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2,3
)

SELECT
    year AS "Year",
    --TODO: Add short names here
    oda AS "ODA",
    share AS "Share",
    mapped_name AS "Full Name",
    donor
FROM one_campaign_totals
ORDER BY donor, year