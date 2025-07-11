WITH base AS (
    SELECT
        crs.donor_name,
        crs.year,
        crs.channel_name,
        crs.parent_channel_code,
        crs.usd_disbursement_defl,
        crs.purpose_code,
        purpose_name,
        crs.sector_code,
    FROM "{{crs_file}}" crs
    WHERE year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
),

transformed AS (
    SELECT 
        donor_name,
        year,
        sum(
            CASE
                WHEN parent_channel_code IN ('40000', '41000', '41100', '41300', '41400', '41500', '41600', '42000', '43000', '44000', '45000', '46000', '47000') THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS earmarked,
        sum(usd_disbursement_defl) 
        - 
        sum(
            CASE
                WHEN parent_channel_code IN ('40000', '41000', '41100', '41300', '41400', '41500', '41600', '42000', '43000', '44000', '45000', '46000', '47000') THEN usd_disbursement_defl
                ELSE 0
            END
        )AS bilateral 
    FROM base b
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = b.purpose_code
    WHERE dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2
), 

one_campaign_totals AS (
    SELECT 
        imf.donor_name,
        imf.year,
        sum(coalesce(nullif(value, 'nan'), 0)) AS sector_multilateral_oda
    FROM "{{imputed_multilateral_file}}" imf
    -- LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.sector_code --Inconsistencies in AG mapping TODO: Decision to be made on purpose/sector
    LEFT JOIN "{{dt_sector_file}}" dsf ON dsf.sector_code = imf.purpose_code
    WHERE imf.year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND dsf.sector_renamed = '{{sector}}'
    GROUP BY 1,2
), 

dac1_totals AS (
    SELECT 
        "Donor_1" AS donor_name,
        "Year" AS year,
        sum("VALUE") AS total_oda
    FROM "{{dac1_file}}"
    WHERE 1=1
    AND year BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND "Amount type" = 'Constant Prices ({{latest_year}} USD millions)'
    AND "Fund flows" = 'Gross Disbursements'
    AND "Donor_1" IN {{dac_countries}}
    AND "Aid type" = 'I. Official Development Assistance (ODA) (I.A + I.B)'
    GROUP BY 1,2
), 

deflated AS (
    SELECT 
        t.year,
        {% if deflate %}
            sum(t.earmarked * dfl.deflator / 100) AS earmarked,
            sum(t.bilateral * dfl.deflator / 100) AS bilateral,
            sum(oct.sector_multilateral_oda * dfl.deflator / 100) AS sector_multilateral_oda,
            sum(d1t.total_oda * coalesce(dfl.deflator, 1) / 100) AS total_oda
        {% else %}
            sum(t.earmarked) AS earmarked,
            sum(t.bilateral) AS bilateral,
            sum(oct.sector_multilateral_oda) AS sector_multilateral_oda,
            sum(d1t.total_oda) AS total_oda
        {% endif %}
    FROM transformed t 
    LEFT JOIN one_campaign_totals oct USING(donor_name, year)
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = t.donor_name AND dfl.year = {{latest_year}}
    LEFT JOIN dac1_totals d1t USING(donor_name, year)
    GROUP BY 1
)

SELECT 
    year AS "Year",
    round((earmarked + bilateral + sector_multilateral_oda) * 100 / total_oda, 2) AS "ODA to {{sector}} as % of Total ODA",
    round(bilateral, 2) AS "Bilateral funding",
    round(earmarked, 2) AS "Bilateral as earmarked funding through multilaterals",
    round(sector_multilateral_oda, 2) AS "Multilateral as core contributions to organizations",
    round(earmarked * 100 / (earmarked + bilateral + sector_multilateral_oda), 2) AS "Earmarked",
    round(bilateral * 100 / (earmarked + bilateral + sector_multilateral_oda), 2) AS "Bilateral",
    round(sector_multilateral_oda * 100 / (earmarked + bilateral + sector_multilateral_oda), 2) AS "Multilateral",
FROM deflated
ORDER BY year
