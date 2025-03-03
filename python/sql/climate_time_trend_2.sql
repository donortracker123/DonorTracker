WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code,
        greatest(climate_mitigation, climate_adaptation) AS climate_total,
        usd_commitment_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
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

allocable_totals AS (
    SELECT 
        "Donor_1" AS donor_name,
        "TIME_PERIOD" AS year,
        sum("OBS_VALUE") AS allocable_oda
    FROM "{{riomarkers_file}}"
    WHERE 1=1
    AND year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND "Donor_1" IN {{dac_countries}}
    AND "Donor_1" != 'EU Institutions'
    GROUP BY 1,2
)

SELECT 
    ct.year AS "Year",
    100 * (ct.climate_principal + ct.climate_significant) / (alt.allocable_oda) AS "Climate Funding as % of bilateral allocable ODA",
    climate_principal * (100 / dfl.deflator) AS "Funding for projects with climate change as a principal objective",
    climate_significant * (100 / dfl.deflator) AS "Funding for projects with a significant climate change component",
    100 * climate_principal / alt.allocable_oda AS "Principal",
    100 * climate_significant / alt.allocable_oda AS "Significant",
    100 - ("Principal" + "Significant") AS "Not targeted and not screened",
    ct.donor_name AS donor,
FROM crs_totals ct
LEFT JOIN allocable_totals alt USING (donor_name, year)
LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = ct.donor_name AND dfl.year = {{latest_year}}
ORDER BY 1,2