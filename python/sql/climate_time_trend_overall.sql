-- WITH base AS (
--     SELECT
--         "donornameE" AS donor_name,
--         "Year" AS year,
--         greatest(coalesce("climateMitigation", -1), coalesce("climateAdaptation", -1)) AS climate_total,
--         purposecode,
--         usd_commitment_defl
--     FROM read_csv_auto("{{climate_riomarkers_file}}", delim='|', header=True)
--     WHERE "Year" BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
--     AND donor_name IN {{dac_countries}}
--     AND "Markers" = 20
-- ), 

WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code AS purposecode,
        climate_adaptation, 
        climate_mitigation,
        greatest(climate_mitigation, climate_adaptation) climate_total, 
        usd_commitment_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND aid_t IN {{allocable_aid_categories}}
    AND category = 10
    AND donor_name != 'EU Institutions'
),

crs_totals AS (
    SELECT 
        b.donor_name,
        year,
        sum(
            CASE
                WHEN climate_total = 2 THEN usd_commitment_defl
                ELSE 0
            END
        ) AS climate_principal,
        sum(
            CASE
                WHEN climate_total = 1 THEN usd_commitment_defl
                ELSE 0
            END
        ) AS climate_significant,
        sum(
            CASE
                WHEN coalesce(climate_total, 0) NOT IN (1,2) THEN usd_commitment_defl
                ELSE 0
            END
        ) AS not_targeted_not_screened,
        sum(usd_commitment_defl) AS total
    FROM base b 
    GROUP BY 1,2
), 

-- allocable_totals AS (
--     SELECT
--         "donornameE" AS donor_name,
--         "Year" AS year,
--         sum(usd_commitment_defl) AS allocable_oda
--     FROM read_csv_auto("{{climate_riomarkers_file}}", delim='|', header=True)
--     WHERE "Year" BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
--     AND donor_name IN {{dac_countries}}
--     AND "Markers" = 20
--     AND "Allocable" = 2
--     GROUP BY 1,2
-- ), 

allocable_totals AS (
    SELECT
        donor_name,
        year,
        sum(usd_commitment_defl) AS allocable_oda
    FROM "{{crs_file}}"
    WHERE "Year" BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND aid_t IN {{allocable_aid_categories}}
    AND category = 10
    GROUP BY 1,2
),

deflated AS (
    SELECT 
        ct.year,
        {% if deflate %}
            sum(ct.climate_principal * (dfl.deflator/100)) AS climate_principal,
            sum(ct.climate_significant * (dfl.deflator/100)) AS climate_significant,
            sum((ct.climate_principal + ct.climate_significant) * (dfl.deflator/100)) AS climate_funding,
            sum(alt.allocable_oda * dfl.deflator/100) AS allocable_oda
        {% else %}
            sum(ct.climate_principal) AS climate_principal,
            sum(ct.climate_significant) AS climate_significant,
            sum((ct.climate_principal + ct.climate_significant)) AS climate_funding,
            sum(alt.allocable_oda) AS allocable_oda
        {% endif %}
    FROM crs_totals ct
    LEFT JOIN allocable_totals alt USING (donor_name, year)
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = ct.donor_name AND dfl.year = {{latest_year}}
    GROUP BY 1
)

SELECT 
    year AS "Year",
    round(100 * (climate_funding) / (allocable_oda), 2) AS "Climate Funding as % of bilateral allocable ODA",
    round(climate_principal, 2) AS "Funding for projects with climate change as a principal objective",
    round(climate_significant, 2) AS "Funding for projects with a significant climate change component",
    round(100 * climate_principal / allocable_oda, 2) AS "Principal",
    round(100 * climate_significant / allocable_oda, 2) AS "Significant",
    100 - ("Principal" + "Significant") AS "Not targeted and not screened"
FROM deflated
ORDER BY 1