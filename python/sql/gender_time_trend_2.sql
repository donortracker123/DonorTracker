WITH base AS (
    SELECT *,
        donor_name,
        year,
        purpose_code,
        gender,
        usd_disbursement_defl
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
                WHEN gender = 2 THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS gender_principal,
        sum(
            CASE
                WHEN gender = 1 THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS gender_significant,
        sum(
            CASE
                WHEN gender = 0 THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS not_targeted,
        sum(
            CASE
                WHEN gender IS NULL THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS not_screened,
        sum(usd_disbursement_defl) AS total
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
    ct.donor_name AS donor,
    ct.year AS "Year",
    100 * (ct.gender_principal + ct.gender_significant) / (alt.allocable_oda) AS "Gender funding as % of bilateral allocable ODA",
    gender_principal * (100 / dfl.deflator) AS "Funding for projects with gender equality as a principal objective",
    gender_significant * (100 / dfl.deflator) AS "Funding for projects with gender equality as a significant objective",
    100 * gender_principal / alt.allocable_oda AS "Principal",
    100 * gender_significant / alt.allocable_oda AS "Significant",
    100 - ("Principal" + "Significant") AS "Not targeted or screened"
FROM crs_totals ct
LEFT JOIN allocable_totals alt USING (donor_name, year)
LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = ct.donor_name AND dfl.year = {{latest_year}}
ORDER BY 1,2
