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
)


SELECT 
    t.year,
    round((t.earmarked + t.bilateral + oct.sector_multilateral_oda) * 100 / d1t.total_oda, 2) AS "ODA to {{sector}} as % of Total ODA",
    {% if deflate %}
        round((t.bilateral * dfl.deflator) / 100, 2) AS "Bilateral funding",
        round((t.earmarked * dfl.deflator) / 100, 2) AS "Bilateral as earmarked funding through multilaterals",
    {% else %}
        round(t.bilateral, 2) AS "Bilateral funding",
        round(t.earmarked, 2) AS "Bilateral as earmarked funding through multilaterals",
    {% endif %}
    round(oct.sector_multilateral_oda, 2) AS "Multilateral as core contributions to organizations",
    round(t.earmarked * 100 / (t.earmarked + t.bilateral + oct.sector_multilateral_oda), 2) AS "Earmarked",
    round(t.bilateral * 100 / (t.earmarked + t.bilateral + oct.sector_multilateral_oda), 2) AS "Bilateral",
    round(oct.sector_multilateral_oda * 100 / (t.earmarked + t.bilateral + oct.sector_multilateral_oda), 2) AS "Multilateral",
    t.donor_name AS donor,
FROM transformed t 
LEFT JOIN one_campaign_totals oct USING(donor_name, year)
LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = t.donor_name AND dfl.year = {{latest_year}}
LEFT JOIN dac1_totals d1t USING(donor_name, year)
ORDER BY donor, year
