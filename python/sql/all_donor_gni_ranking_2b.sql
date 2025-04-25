WITH base AS (
        SELECT 
            "Donor_1" AS donor,
            "Year" AS year,
            "Aid type" AS aid_type,
            "VALUE" AS value
        FROM "{{dac1_file}}"
        WHERE 1=1
        AND year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
        AND "Amount type" = 'Current Prices (USD millions)'
        AND "Fund flows" = 'Grant equivalents'
        AND "Donor_1" IN {{dac_countries}}
        AND "Aid type" = 'ODA grant equivalent as percent of GNI'
        AND "Donor_1" != 'EU Institutions'
    ),

    ranked AS (  
        SELECT
            donor,
            year,
            round(value, 2) || '%' AS "ODA as % GNI", 
            row_number() OVER (PARTITION BY year ORDER BY value DESC) AS rn
        FROM base
    )

    SELECT
        year AS "Year",
        donor AS "Donor",
        "ODA as % GNI", 
        CASE 
            WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
            WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
            WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
            ELSE rn || 'th'
        END AS "Ranking"
    FROM ranked
    ORDER BY year, rn
