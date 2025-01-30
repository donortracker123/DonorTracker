WITH base AS (
    SELECT 
        "Donor_1" AS donor,
        "Year" AS year,
        "Aid type" AS aid_type,
        "VALUE" AS value, 
        "Fund flows" AS fund_flows,
        "Amount type" AS amount_type
    FROM "{{dac1_file}}"
    WHERE 1=1
    AND year BETWEEN ({{latest_year}} - 5) AND ({{latest_year}})
    AND "Amount type" IN ('Current Prices (USD millions)', 'Constant Prices (2022 USD millions)')
    AND "Fund flows" = 'Grant equivalents'
    AND "Aid type" IN (
        'Official Development Assistance, grant equivalent measure', 
        'ODA grant equivalent as percent of GNI'
    )
), 

transformed AS (
    SELECT 
        donor, 
        year,
        SUM(
            CASE 
                WHEN aid_type = 'ODA grant equivalent as percent of GNI' AND amount_type = 'Current Prices (USD millions)' THEN round(value, 2)
                ELSE 0
            END 
        )AS "ODA AS % GNI", 
        SUM(
            CASE 
                WHEN aid_type = 'Official Development Assistance, grant equivalent measure' AND amount_type = 'Constant Prices (2022 USD millions)' THEN value
                ELSE 0
            END 
        )AS "Total ODA", 
    FROM base
    GROUP BY 1,2
), 

pre_deflated AS (
    SELECT 
    coalesce(t.donor, proj.donor) AS donor,
    coalesce(t.year, proj.year) AS year,
    coalesce(t."ODA AS % GNI", proj."ODA_GNI_realistic") || '%' AS "ODA AS % GNI",
    coalesce(t."Total ODA", proj."ODA_realistic") AS "Total ODA"
    FROM transformed t
    FULL OUTER JOIN "{{projection_file}}" AS proj
    ON t.donor = proj.donor and t.year = proj.year
    ORDER BY donor, year
), 

deflators AS (
    SELECT 
        donor, 
        deflator
    FROM "{{deflator_file}}"
    WHERE year = {{latest_year}}
), 

deflated AS (
    SELECT 
        pd.donor,
        pd.year AS "Year",
        pd."ODA AS % GNI",
        pd."Total ODA" * (d.deflator / 100) AS "Total ODA"
    FROM pre_deflated pd
    INNER JOIN deflators d USING (donor)
)

SELECT * 
FROM deflated
WHERE year <= ({{latest_year}} +2)
ORDER BY year