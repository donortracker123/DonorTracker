WITH base AS (
    SELECT
        "donornameE" AS donor_name,
        "Year" AS year,
        greatest(coalesce("climateMitigation", -1), coalesce("climateAdaptation", -1)) AS climate_total,
        purposecode,
        usd_commitment_defl
    FROM read_csv_auto("{{climate_riomarkers_file}}", delim='|', header=True)
    WHERE "Year" BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND donor_name != 'EU Institutions'
    AND "Markers" = 20
), 

rio_totals AS (
    SELECT 
        b.donor_name,
        b.year,
        {% if deflate %}
            sum(coalesce(usd_commitment_defl, 0) / 100 * dfl.deflator) AS bilateral_oda
        {% else %}
            sum(coalesce(usd_commitment_defl, 0)) AS bilateral_oda
        {% endif %}
    FROM base b 
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE b.climate_total IN (1,2)
    GROUP BY 1,2
),

ranked AS (
    SELECT 
        donor_name AS donor,
        year,
        sum(bilateral_oda) AS total_oda,
        row_number() OVER (PARTITION BY year ORDER BY sum(bilateral_oda) DESC) AS rn
    FROM rio_totals
    GROUP BY 1,2
)

SELECT 
    donor "Donor", 
    round(total_oda, 2) "ODA towards Climate",
    Year, 
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Ranking"
FROM ranked
