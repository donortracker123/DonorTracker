WITH base AS (
    SELECT
        crs.donor_name,
        crs.recipient_name,
        crs.year,
        coalesce(crs.incomegroup_name, '') AS incomegroup_name,
        crs.usd_disbursement_defl
    FROM "{{crs_file}}" crs
    -- LEFT JOIN "{{dt_world_bank_income_file}}" wb ON wb.economy = crs.recipient_name
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name IN {{dac_countries}}
), 

deflated AS (
    SELECT 
        b.donor_name AS donor,
        b.year,
        CASE
            WHEN incomegroup_name = 'LMICs' THEN 'Lower-middle income countries'
            WHEN incomegroup_name = 'LDCs' THEN 'Least developed countries'
            WHEN incomegroup_name = 'UMICs' THEN 'Upper-middle income countries'
            WHEN incomegroup_name = 'Other LICs' THEN 'Other low income countries'
            WHEN incomegroup_name = 'MADCTs' THEN 'More advanced developed countries and territories'
            ELSE 'Countries unallocated by income'
        END AS mapped_income_group,
        {% if deflate %}
            b.usd_disbursement_defl * dfl.deflator / 100 AS oda,
        {% else %}
            b.usd_disbursement_defl AS oda,
        {% endif %}

    FROM base b
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
)

SELECT
    year,
    mapped_income_group AS incomegroup_name,
    round(coalesce(sum(oda), 0), 2) AS "total_oda", 
    coalesce(round(coalesce(sum(oda), 0) * 100 / sum(sum(oda)) OVER (PARTITION BY donor, year), 2), 0) AS "Share",
    donor,
FROM deflated
GROUP BY donor, year, incomegroup_name
ORDER BY donor, year DESC, "total_oda" DESC
