WITH base AS (
    SELECT
        donor_name,
        year,
        sector_code,
        trim(sector_name) AS sector_name,
        flow_name,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
), 

mapped_sectors AS (
    SELECT 
        b.donor_name,
        year,
        b.sector_name,
        b.usd_disbursement_defl,
        dsf.sector_renamed
    FROM base b 
    INNER JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.sector_code
), 

deflated AS (
    SELECT 
        ms.donor_name,
        ms.year,
        ms.sector_renamed,
        ms.usd_disbursement_defl * dfl.deflator AS total_oda
    FROM mapped_sectors ms
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = ms.donor_name AND dfl.year = {{latest_year}}

)

SELECT
    donor_name AS donor,
    year AS "Year",
    sector_renamed AS "Sector",
    sum(total_oda) AS "Bilateral ODA for", 
    sum(total_oda) * 100 / sum(sum(total_oda)) OVER (PARTITION BY donor_name, year) AS share
FROM deflated
GROUP BY 1,2,3
ORDER BY 1, 2 DESC, 4 DESC