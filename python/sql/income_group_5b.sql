WITH base AS (
    SELECT
        donor_name,
        year,
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
        b.donor_name,
        b.year,
        b.incomegroup_name,
        b.usd_disbursement_defl,
        dfl.deflator
    FROM base b
    INNER JOIN "{{deflator_file_long}}" dfl ON dfl.year = b.year AND dfl.donor = b.donor_name
)

SELECT
    donor_name,
    year,
    incomegroup_name,
    sum(usd_disbursement_defl) AS "total_oda", 
    sum(usd_disbursement_defl) * 100 / sum(sum(usd_disbursement_defl)) OVER (PARTITION BY donor_name, year) AS share
FROM deflated
GROUP BY 1,2,3
ORDER BY 1, 2 DESC, 4 DESC