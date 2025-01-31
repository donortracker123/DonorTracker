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
        sum(
            CASE 
                WHEN coalesce(sector_renamed, 'None') = '{{sector}}' THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS sector_bilateral_oda,
        sum(coalesce(usd_disbursement_defl, 0)) AS total_bilateral_oda
    FROM base b 
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    GROUP BY 1,2
), 

one_campaign_totals AS (
    SELECT 
        imf.donor_name,
        imf.year,
        sum(
            CASE 
                WHEN coalesce(sector_renamed, 'None') = '{{sector}}' THEN coalesce(nullif(value, 'nan'), 0)
                ELSE 0
            END
        ) AS sector_multilateral_oda,
        sum(coalesce(nullif(value, 'nan'), 0)) AS total_multilateral_oda, --ONE CAMPAIGN SAVED VALUES AS 'nan'
    FROM "{{imputed_multilateral_file}}" imf
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    GROUP BY 1,2
), 

joined AS (
    SELECT 
        ct.donor_name AS donor,
        ct.year,
        (ct.sector_bilateral_oda + oct.sector_multilateral_oda) AS "Sector ODA",
        (ct.total_bilateral_oda + oct.total_multilateral_oda) AS "Total ODA",
        (ct.sector_bilateral_oda + oct.sector_multilateral_oda) / (ct.total_bilateral_oda + oct.total_multilateral_oda) AS "Sector Percentage"
    FROM crs_totals ct 
    LEFT JOIN one_campaign_totals oct USING(donor_name, year)
), 

ranked AS (
    SELECT 
        donor,
        year,
        "Sector ODA",
        "Total ODA",
        "Sector Percentage",
        row_number() OVER (ORDER BY "Sector Percentage" DESC) AS rn
    FROM joined
)

SELECT 
    donor, 
    Year, 
    "Total ODA",
    "Sector Percentage",
    CASE 
        WHEN rn::TEXT LIKE '%1' AND rn != 11 THEN rn || 'st'
        WHEN rn::TEXT LIKE '%2' AND rn != 12 THEN rn || 'nd'
        WHEN rn::TEXT LIKE '%3' AND rn != 13 THEN rn || 'rd'
        ELSE rn || 'th'
    END AS "Rank"
FROM ranked