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
        dcc.sector_renamed
    FROM base b 
    INNER JOIN "{{dac_crs_codes}}" dcc ON dcc.sector_code = b.sector_code
), 

deflated AS (
    SELECT 
        ms.donor_name,
        ms.year,
        ms.sector_renamed,
        ms.usd_disbursement_defl,
        dfl.deflator
    FROM mapped_sectors ms
    INNER JOIN "{{deflator_file_long}}" dfl ON dfl.year = ms.year AND dfl.donor = ms.donor_name

)

SELECT
    donor_name,
    year,
    sector_renamed AS sector,
    sum(usd_disbursement_defl) AS "total_oda", 
    sum(usd_disbursement_defl) * 100 / sum(sum(usd_disbursement_defl)) OVER (PARTITION BY donor_name, year) AS share
FROM deflated
GROUP BY 1,2,3
ORDER BY 1, 2 DESC, 4 DESC