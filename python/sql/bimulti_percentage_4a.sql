WITH base AS (
        SELECT 
            "Donor_1" AS donor,
            "Year" AS year,
            "Aid type" AS aid_type,
            "VALUE" AS value
        FROM "{{dac1_file}}"
        WHERE 1=1
        AND year = {{latest_year}}
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
                END
            )  
            -
            SUM(CASE 
                WHEN aid_type = 'I.A. Memo: ODA channelled through multilateral organisations' THEN "value" 
                ELSE 0
                END)AS "Bilateral funding",
            SUM(CASE 
                WHEN aid_type = 'I.A. Memo: ODA channelled through multilateral organisations' THEN "value" 
                ELSE 0
                END
            ) AS "Bilateral as earmarked funding through multilaterals",
            SUM(CASE 
                WHEN aid_type = 'I.B. Multilateral Official Development Assistance (capital subscriptions are included with grants)' THEN "value" 
                ELSE 0
                END
            ) AS "Multilateral as core contributions to organizations",
            SUM(CASE 
                WHEN aid_type = 'I. Official Development Assistance (ODA) (I.A + I.B)' THEN "value" 
                ELSE 0
                END
            ) AS "Total ODA"
        FROM base
        GROUP BY 1,2
    )
    SELECT
        donor,
        "Year",
        round( 100 * coalesce("Bilateral as earmarked funding through multilaterals", 0) / "Total ODA")::INT || '%' AS "Earmarked",
        round( 100 * coalesce("Bilateral funding", 0) / "Total ODA")::INT || '%'  AS "Bilateral",
        round( 100 * coalesce("Multilateral as core contributions to organizations", 0) / "Total ODA")::INT || '%' AS "Multilateral"
    FROM filtered

    UNION ALL 

    SELECT
        'DAC Average',
        "Year",
        avg(round( 100 * coalesce("Bilateral as earmarked funding through multilaterals", 0) / "Total ODA")::INT) || '%' AS "Earmarked",
        avg(round( 100 * coalesce("Bilateral funding", 0) / "Total ODA")::INT) || '%'  AS "Bilateral",
        avg(round( 100 * coalesce("Multilateral as core contributions to organizations", 0) / "Total ODA")::INT) || '%' AS "Multilateral"
    FROM filtered
    WHERE donor IN {{dac_countries}}
    GROUP BY 1,2
    ORDER BY "Year"