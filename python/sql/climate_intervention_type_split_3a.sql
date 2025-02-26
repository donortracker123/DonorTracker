WITH base AS (
    SELECT
        donor_name,
        year,
        climate_adaptation, 
        climate_mitigation,
        greatest(climate_mitigation, climate_adaptation) climate_total, 
        usd_commitment_defl
    FROM "{{crs_file}}"
    WHERE year = ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND flow_name IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND donor_name != 'EU Institutions'
), 

adaptation AS (
    SELECT 
        b.donor_name,
        'Adaptation' AS "Rio Marker",
        sum(
            CASE
                WHEN climate_adaptation IN (1,2) AND climate_mitigation NOT IN (1,2) THEN b.usd_commitment_defl / 100 * dfl.deflator
                ELSE 0
            END
        ) AS "Bilateral ODA",
        sum(
            CASE 
                WHEN climate_adaptation IN (1,2) AND climate_mitigation IN (1,2) THEN b.usd_commitment_defl / 100 * dfl.deflator
                ELSE 0
            END 
        ) AS "Cross-cutting",
        sum(
            CASE
                WHEN climate_total IN (1,2) THEN b.usd_commitment_defl / 100 * dfl.deflator
                ELSE 0
            END
        ) AS "Total Climate ODA"
    FROM base b 
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    GROUP BY 1,2
), 

mitigation AS (
    SELECT 
        b.donor_name,
        'Mitigation' AS "Rio Marker",
        sum(
            CASE
                WHEN climate_mitigation IN (1,2) AND climate_adaptation NOT IN (1,2) THEN b.usd_commitment_defl / 100 * dfl.deflator
                ELSE 0
            END
        ) AS "Bilateral ODA",
        sum(
            CASE 
                WHEN climate_adaptation IN (1,2) AND climate_mitigation IN (1,2) THEN b.usd_commitment_defl / 100 * dfl.deflator
                ELSE 0
            END 
        ) AS "Cross-cutting",
        sum(
            CASE
                WHEN climate_total IN (1,2) THEN b.usd_commitment_defl / 100 * dfl.deflator
                ELSE 0
            END
        ) AS "Total Climate ODA"
    FROM base b 
    LEFT JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
    GROUP BY 1,2
), 

combined AS (
    SELECT 
        *, 
        round(100 * ("Bilateral ODA" + "Cross-cutting") / nullif("Total Climate ODA", 0), 1) AS "Share"
    FROM adaptation
    UNION ALL 
    SELECT
        *,
        round(100 * ("Bilateral ODA" + "Cross-cutting") / nullif("Total Climate ODA", 0), 1) AS "Share"
    FROM mitigation
)

SELECT
    donor_name AS donor,
    "Rio Marker",
    "Cross-cutting",
    "Bilateral ODA", 
    "Share" || '%' AS "Share" --Adding || to a column is concatenation. this is adding '%' to the share column
FROM combined
ORDER BY donor_name, "Rio Marker"