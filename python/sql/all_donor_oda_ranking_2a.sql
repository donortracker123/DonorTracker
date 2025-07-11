WITH base AS (
        SELECT 
            "Donor_1" AS donor,
            "Year" AS year,
            "Aid type" AS aid_type,
            "VALUE" AS value
        FROM "{{dac1_file}}"
        WHERE 1=1
        AND year BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
        AND "Amount type" = 'Constant Prices (2023 USD millions)'
        AND "Fund flows" = 'Grant equivalents'
        AND "Donor_1" IN {{dac_countries}}
        AND "Aid type" = 'Official Development Assistance, grant equivalent measure'
        AND "Donor_1" != 'EU Institutions'
    ), 

    --NOTE: In April, don't deflate
    ranked AS (  
        SELECT
            b.donor,
            b.year,
            {% if deflate %}
                value * (dfl.deflator / 100) / 1000 
            {% else %}
                value / 1000
            {% endif %} AS "Total ODA", 
            row_number() OVER (PARTITION BY b.year ORDER BY value DESC) AS rn
        FROM base b
        LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor AND dfl.year = {{latest_year}}
    )

    SELECT
        year AS "Year",
        donor AS "Donor",
        round("Total ODA", 3) AS "Total ODA", 
        CASE 
            WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
            WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
            WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
            ELSE rn || 'th'
        END AS "Ranking"
    FROM ranked
    ORDER BY year, rn