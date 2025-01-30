WITH base AS (
    SELECT
        crs.donor_name,
        crs.channel_name,
        crs.usd_disbursement_defl,
        coalesce(dcf."DT_channel_name", 'None') AS channel_name_mapped
    FROM "{{crs_file}}" crs
    LEFT JOIN "{{dt_channels_file}}" dcf ON dcf."CRS_channel_name" = crs.channel_name
    WHERE year = ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
),

transformed AS (
    SELECT 
        donor_name,
        sum(
            CASE
                WHEN channel_name_mapped = 'NGOs & Civil Society' THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS csos,
        sum(
            CASE
                WHEN channel_name_mapped != 'NGOs & Civil Society' THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS other_channels,
        sum(usd_disbursement_defl) AS total
    FROM base
    GROUP BY 1
)

SELECT 
    t.donor_name AS donor,
    (t.csos / t.total) AS "CSOs",
    (t.other_channels / t.total) AS "Other Channels"
FROM transformed t

UNION ALL 

SELECT 
    'DAC Average',
    sum(t.csos) / sum(t.total) AS "CSOs",
    sum(t.other_channels) / sum(t.total) AS "Other Channels"
FROM transformed t
