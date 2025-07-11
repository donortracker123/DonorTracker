WITH base AS (
    SELECT 
        "Donor_1" AS donor,
        "Year" AS year,
        "Aid type" AS aid_type,
        "VALUE" AS value
    FROM "{{dac1_file}}"
    WHERE 1=1
    AND year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND "Amount type" = 'Constant Prices (2023 USD millions)'
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
), 

--NOTE: In April, don't deflate
deflated AS (
    SELECT 
        f.donor,
        f.year,
        {% if deflate %}
            -- Middle of year, don't deflate
            coalesce("Bilateral funding", 0) * dfl.deflator / 100 AS "Bilateral funding",
            coalesce("Bilateral as earmarked funding through multilaterals", 0) * dfl.deflator / 100 AS "Bilateral as earmarked funding through multilaterals",
            coalesce("Multilateral as core contributions to organizations", 0) * dfl.deflator / 100 AS "Multilateral as core contributions to organizations",
            "Total ODA" * dfl.deflator / 100 AS "Total ODA",
        {% else %}
            coalesce("Bilateral funding", 0) AS "Bilateral funding",
            coalesce("Bilateral as earmarked funding through multilaterals", 0) AS "Bilateral as earmarked funding through multilaterals",
            coalesce("Multilateral as core contributions to organizations", 0) AS "Multilateral as core contributions to organizations",
            "Total ODA" AS "Total ODA",
        {% endif %}
    FROM filtered f 
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = f.donor AND dfl.year = {{latest_year}}
)

SELECT
    donor,
    "Year",
    "Total ODA",
    round("Bilateral funding", 2) AS "Bilateral funding",
    round("Multilateral as core contributions to organizations", 2) AS "Multilateral as core contributions to organizations", 
    round("Bilateral as earmarked funding through multilaterals", 2) AS "Bilateral as earmarked funding through multilaterals",
    round( 100 * coalesce("Bilateral as earmarked funding through multilaterals", 0) / "Total ODA")::INT || '%' AS "Earmarked",
    round( 100 * coalesce("Bilateral funding", 0) / "Total ODA")::INT || '%'  AS "Bilateral",
    round( 100 * coalesce("Multilateral as core contributions to organizations", 0) / "Total ODA")::INT || '%' AS "Multilateral"
FROM deflated
ORDER BY "Year"