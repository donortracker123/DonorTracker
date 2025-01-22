WITH base AS (
        SELECT 
            "Donor_1" AS donor,
            "Year" AS year,
            "Aid type" AS aid_type,
            "VALUE" AS value
        FROM "{{dac1_file}}""
        WHERE 1=1
        AND year BETWEEN 2019 AND 2023
        AND "Amount type" = 'Constant Prices (2022 USD millions)'
        AND "Fund flows" = 'Grant equivalents'
        AND "Aid type" IN (
            'I. Official Development Assistance (ODA) (I.A + I.B)',
            'I.B. Multilateral Official Development Assistance (capital subscriptions are included with grants)',
            'I.A. Memo: ODA channelled through multilateral organisations',
            'I.A. Bilateral Official Development Assistance by types of aid (1+2+3+4+5+6+7+8+9+10)'
        )
    ), 

    filtered AS (  
        SELECT
            donor,
            year AS "Year",
            SUM(CASE 
                WHEN aid_type = 'I.A. Bilateral Official Development Assistance by types of aid (1+2+3+4+5+6+7+8+9+10)' THEN "value" 
                ELSE 0
            END)  AS "Bilateral funding",
            SUM(CASE 
                WHEN aid_type = 'I.B. Multilateral Official Development Assistance (capital subscriptions are included with grants)' THEN "value" 
                ELSE 0
                END) AS "Multilateral as core contributions to organizations",
            SUM(CASE 
                WHEN aid_type = 'I. Official Development Assistance (ODA) (I.A + I.B)' THEN "value" 
                ELSE 0
                END) AS "Total ODA"
        FROM base
        GROUP BY 1,2
    )
    SELECT
        donor,
        "Year",
        "Total ODA",
        coalesce("Bilateral funding", 0) AS "Bilateral funding",
        coalesce("Multilateral as core contributions to organizations", 0) AS "Multilateral as core contributions to organizations", 
        round( 100 * coalesce("Bilateral funding", 0) / "Total ODA")::INT || '%'  AS "Bilateral",
        round( 100 * coalesce("Multilateral as core contributions to organizations", 0) / "Total ODA")::INT || '%' AS "Multilateral"
    FROM filtered
    ORDER BY "Year"