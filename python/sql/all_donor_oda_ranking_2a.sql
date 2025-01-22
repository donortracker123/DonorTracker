WITH base AS (
        SELECT 
            "Donor_1" AS donor,
            "Year" AS year,
            "Aid type" AS aid_type,
            "VALUE" AS value
        FROM "{{dac1_file}}""
        WHERE 1=1
        AND year BETWEEN 2022 AND 2023
        AND "Amount type" = 'Current Prices (USD millions)'
        AND "Fund flows" = 'Grant equivalents'
        AND "Donor_1" IN {{DAC_COUNTRIES}}
        AND "Aid type" = 'Official Development Assistance, grant equivalent measure'
    ), 

    ranked AS (  
        SELECT
            donor,
            year,
            value / 1000 AS "Total ODA", 
            row_number() OVER (PARTITION BY year ORDER BY value DESC) AS rn
        FROM base
    )

    SELECT
        year AS "Year",
        donor AS "Donor",
        round("Total ODA", 4) AS "Total ODA", 
        CASE 
            WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
            WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
            WHEN rn::TEXT LIKE '%3' AND rn != 13THEN rn || 'rd'
            ELSE rn || 'th'
        END AS "Rank"
    FROM ranked
    ORDER BY year, rn