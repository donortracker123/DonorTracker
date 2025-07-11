WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_name,
        purpose_code,
        gender,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND "Aid_T" IN ('A02', 'B01', 'B03', 'B031', 'B032', 'B033','B04', 'C01', 'D01', 'D02', 'E01')
), 

crs_totals AS (
    SELECT 
        b.donor_name,
        b.year,
        dsf.sector_renamed,
        {% if deflate %}
            sum(coalesce(b.usd_disbursement_defl, 0) / 100 * dfl.deflator) AS bilateral_oda,
            sum(sum(coalesce(b.usd_disbursement_defl, 0) / 100 * dfl.deflator)) OVER (PARTITION BY b.donor_name, b.year) AS total_oda
        {% else %}
            sum(coalesce(b.usd_disbursement_defl, 0)) AS bilateral_oda,
            sum(sum(coalesce(b.usd_disbursement_defl, 0))) OVER (PARTITION BY b.donor_name, b.year) AS total_oda
        {% endif %}
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    WHERE b.gender IN (1,2)
    GROUP BY 1,2,3
)

SELECT 
    year,
    sector_renamed AS Sector,
    round(bilateral_oda, 2) AS "Gender-related ODA to",
    round(100 * (bilateral_oda / total_oda)) || '%' AS "Share",
    donor_name AS donor,
FROM crs_totals ct 
ORDER BY 5, 3 DESC