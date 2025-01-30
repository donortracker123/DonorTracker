WITH base AS (
    SELECT
        donor_name,
        year,
        recipient_name,
        flow_name,
        usd_disbursement_defl
    FROM "{{crs_file}}"
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
        recipient_name,
        sum(
            CASE
                WHEN flow_name IN ('ODA Grants') THEN usd_disbursement_defl
                ELSE 0
            END
        ) AS grants,
        sum(
            CASE
                WHEN flow_name IN ('Equity Investment', 'ODA Loans') THEN usd_disbursement_defl
                ELSE 0
            END    
        ) AS loans,
        coalesce(sum(usd_disbursement_defl), 0) * 100 / sum(sum(usd_disbursement_defl)) OVER (PARTITION BY donor_name, year) AS share
    FROM base
    GROUP BY 1,2,3
)

SELECT 
    t.donor_name AS donor,
    t.year,
    t.recipient_name AS "Recipient country",
    round(t.share,1) || '%' AS share,
    (t.grants / 100) * dfl.deflator AS "ODA Grants",
    (t.loans / 100) * dfl.deflator AS "ODA Loans",
FROM transformed t
LEFT JOIN "{{deflator_file}}" dfl ON dfl.year = t.year AND dfl.donor = t.donor_name
QUALIFY row_number() OVER (PARTITION BY t.donor_name, t.year ORDER BY share DESC) <= 20
ORDER BY 1, 2 DESC, 5 DESC