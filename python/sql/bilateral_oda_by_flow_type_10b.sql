WITH base AS (
    SELECT
        donor_name,
        year,
        flow_name,
        usd_disbursement_defl
    FROM "{{crs_file}}"
    WHERE year = ({{latest_year}})
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
        sum(usd_disbursement_defl) AS total
    FROM base
    GROUP BY 1,2
)

SELECT 
    t.donor_name AS donor,
    round(100*(t.grants / t.total), 2) AS "Grants",
    round(100*(t.loans / t.total), 2) AS "Loans/Equity Investment"
FROM transformed t

UNION ALL 

SELECT 
    'DAC Average',
    round(100*sum(t.grants) / sum(t.total), 2) AS "Grants",
    round(100*sum(t.loans) / sum(t.total), 2) AS "Loans/Equity Investment"
FROM transformed t
