WITH base AS (
    SELECT
        donor_name,
        year,
        --TODO: map names
        incomegroup_name,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
), 

deflated AS (
    SELECT 
        b.donor_name AS donor,
        b.year,
        b.incomegroup_name,
        b.usd_disbursement_defl,
        dfl.deflator
    FROM base b
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
)

SELECT
    donor,
    year,
    incomegroup_name,
    sum(usd_disbursement_defl) AS "total_oda", 
    sum(usd_disbursement_defl) * 100 / sum(sum(usd_disbursement_defl)) OVER (PARTITION BY donor, year) AS share
FROM deflated
GROUP BY 1,2,3
ORDER BY 1, 2 DESC, 4 DESC