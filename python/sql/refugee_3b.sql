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
        AND "Fund flows" = 'Net Disbursements'
        AND "Aid type" IN (
            'I.A.8.2. Refugees in donor countries',
            'I.A. Bilateral Official Development Assistance by types of aid (1+2+3+4+5+6+7+8+9+10)',
            'I.B.1.2. EU institutions',
            'I.B. Multilateral Official Development Assistance (capital subscriptions are included with grants)'
        )
    ), 

    filtered AS (
    SELECT
        donor,
        year,  
        SUM(value * 
        CASE 
            WHEN aid_type = 'I.A. Bilateral Official Development Assistance by types of aid (1+2+3+4+5+6+7+8+9+10)' THEN 1
            WHEN aid_type = 'I.A.8.2. Refugees in donor countries' THEN -1
            WHEN aid_type = 'I.B. Multilateral Official Development Assistance (capital subscriptions are included with grants)' THEN 1
            WHEN aid_type = 'I.B.1.2. EU institutions' THEN -1
            ELSE 0
        END
        ) AS "ODA for Development Priorities", 
        SUM(value *
        CASE 
            WHEN aid_type = 'I.B.1.2. EU institutions' THEN 1
            ELSE 0
        END
        ) AS "Contributions to EUI", 
        SUM(value *
        CASE
            WHEN aid_type = 'I.A.8.2. Refugees in donor countries' THEN 1
            ELSE 0
        END
        ) AS "In-donor Refugee Costs"
    FROM base
    GROUP BY donor, year
    ), 

    deflated AS (
        SELECT 
            f.year,
            {% if deflate %}
                round("ODA for Development Priorities" *  dfl.deflator / 100, 2) AS "ODA for Development Priorities",
                round("Contributions to EUI" * dfl.deflator / 100, 2) AS "Contributions to EUI",
                round("In-donor Refugee Costs" * dfl.deflator / 100, 2) AS "In-donor Refugee Costs",
            {% else %}
                round("ODA for Development Priorities", 2) AS "ODA for Development Priorities",
                round("Contributions to EUI", 2) AS "Contributions to EUI",
                round("In-donor Refugee Costs", 2) AS "In-donor Refugee Costs",
            {% endif %}
            f.donor
        FROM filtered f
        LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = f.donor AND dfl.year = {{latest_year}}
    )

    SELECT
        year AS "Year",
        "ODA for Development Priorities",
        "Contributions to EUI",
        "In-donor Refugee Costs",
        donor,
    FROM deflated d
    ORDER BY donor, year