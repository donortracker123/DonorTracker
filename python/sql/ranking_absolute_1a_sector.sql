WITH base AS (
    SELECT
        donor_name,
        year,
        purpose_code,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year = ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
), 

crs_totals AS (
    SELECT 
        b.donor_name,
        year,
        dsf.sector_renamed,
        b.purpose_code,
        sum(coalesce(usd_disbursement_defl, 0)) AS bilateral_oda
    FROM base b 
    INNER JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    WHERE dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2,3,4
), 

one_campaign_totals AS (
    SELECT 
        imf.year, 
        imf.donor_name,
        imf.purpose_code,
        sum(coalesce(nullif(value, 'nan'), 0)) AS multilateral_oda, --ONE CAMPAIGN SAVED VALUES AS 'nan'
    FROM "{{imputed_multilateral_file}}" imf
    INNER JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    WHERE dsf.sector_renamed = '{{sector}}'    
    GROUP BY 1,2,3
), 

deflated AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        dfl.deflator,
        ct.bilateral_oda * 100 / dfl.deflator AS "Bilateral ODA",
        oct.multilateral_oda * 100 / dfl.deflator AS "Multilateral ODA",
        (ct.bilateral_oda + oct.multilateral_oda) * 100 / dfl.deflator AS "Total ODA"
    FROM crs_totals ct 
    LEFT JOIN one_campaign_totals oct USING(donor_name, year, purpose_code)
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = ct.donor_name AND dfl.year = ct.year
), 

ranked AS (
    SELECT 
        donor,
        year,
        sum("Total ODA") AS "Total ODA",
        row_number() OVER (ORDER BY sum("Total ODA") DESC) AS rn
    FROM deflated
    GROUP BY 1,2
)

SELECT 
    donor, 
    Year, 
    "Total ODA",
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Rank"
FROM ranked