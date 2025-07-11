WITH base AS (
    SELECT
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
    AND "Aid_T" IN ('A02', 'B01', 'B03', 'B031', 'B032', 'B033','B04', 'C01', 'D01', 'D02', 'E01')
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

--NOTE: As of April 2025, this CTE did not include values for EUI
allocable_totals AS (
    SELECT 
        "Donor_1" AS donor_name,
        "TIME_PERIOD" AS year,
        sum("OBS_VALUE") AS allocable_oda
    FROM "{{allocable_gender_file}}"
    WHERE 1=1
    AND year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND "Donor_1" IN {{dac_countries}}
    GROUP BY 1,2
), 

deflated AS (
    SELECT
        ct.year,
        {% if deflate %}
            sum(ct.gender_principal * (dfl.deflator/100)) AS gender_principal,
            sum(ct.gender_significant * (dfl.deflator/100)) AS gender_significant,
            sum((ct.gender_principal + ct.gender_significant) * (dfl.deflator/100)) AS gender_funding,
            sum(alt.allocable_oda * (dfl.deflator/100)) AS allocable_oda 
        {% else %}
            sum(ct.gender_principal) AS gender_principal,
            sum(ct.gender_significant) AS gender_significant,
            sum((ct.gender_principal + ct.gender_significant)) AS gender_funding,
            sum(alt.allocable_oda) AS allocable_oda
        {% endif %}
    FROM crs_totals ct
    LEFT JOIN allocable_totals alt USING (donor_name, year)
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = ct.donor_name AND dfl.year = {{latest_year}}
    GROUP BY 1
)

SELECT 
    year AS "Year",
    round(100 * (gender_principal + gender_significant) / (allocable_oda), 2) AS "Gender funding as % of bilateral allocable ODA",
    round(gender_principal, 2) AS "Funding for projects with gender equality as a principal objective",
    round(gender_significant, 2) AS "Funding for projects with gender equality as a significant objective",
    round(100 * gender_principal / allocable_oda, 2) AS "Principal",
    round(100 * gender_significant / allocable_oda, 2) AS "Significant",
    100 - ("Principal" + "Significant") AS "Not targeted or screened",
FROM deflated
ORDER BY 1
