WITH base AS (
    SELECT
        crs.donor_name,
        crs.recipient_name,
        crs.year,
        --TODO: map names
        -- wb.income_group,
        crs.incomegroup_name,
        crs.usd_disbursement_defl
    FROM "{{crs_file}}" crs
    -- LEFT JOIN "{{dt_world_bank_income_file}}" wb ON wb.economy = crs.recipient_name
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND incomegroup_name IS NOT NULL 
), 

deflated AS (
    SELECT 
        b.donor_name AS donor,
        b.year,
        b.incomegroup_name,
        b.usd_disbursement_defl * dfl.deflator / 100 AS oda,
    FROM base b
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
)

SELECT
    year,
    incomegroup_name,
    round(sum(oda), 2) AS "total_oda", 
    round(sum(oda) * 100 / sum(sum(oda)) OVER (PARTITION BY donor, year), 2) AS "Share",
    donor,
FROM deflated
GROUP BY donor, year, incomegroup_name
ORDER BY donor, year DESC, "total_oda" DESC