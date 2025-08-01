WITH base AS (
    SELECT
        donor_name,
        year,
        sector_code,
        purpose_code,
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
    INNER JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code --SEEK maps to renamed sectors by purpose code in the CRS
), 

deflated AS (
    SELECT 
        ms.donor_name,
        ms.year,
        ms.sector_renamed,
        {% if deflate %}
            ms.usd_disbursement_defl * dfl.deflator / 100 AS total_oda
        {% else %}           
            ms.usd_disbursement_defl AS total_oda
        {% endif %}
    FROM mapped_sectors ms
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = ms.donor_name AND dfl.year = {{latest_year}}
)

SELECT
    year AS "Year",
    sector_renamed AS "Sector",
    round(sum(total_oda),2) AS "Bilateral ODA for", 
    round(sum(total_oda) * 100 / sum(sum(total_oda)) OVER (PARTITION BY donor_name, year), 2) || '%' AS "Share",
    donor_name AS donor,
FROM deflated
GROUP BY year, sector_renamed, donor_name
ORDER BY donor, year DESC, 3 DESC
