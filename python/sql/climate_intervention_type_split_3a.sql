WITH base AS (
    SELECT
        "donornameE" AS donor_name,
        "Year" AS year,
        "climateMitigation" AS climate_mitigation,
        "climateAdaptation" AS climate_adaptation,
        greatest(coalesce("climateMitigation", -1), coalesce("climateAdaptation", -1)) AS climate_total,
        usd_commitment_defl
    FROM read_csv_auto("{{climate_riomarkers_file}}", delim='|', header=True)
    WHERE "Year" BETWEEN ({{latest_year}} - 1) AND ({{latest_year}})
    AND donor_name IN {{dac_countries}}
    AND "Markers" = 20
), 

adaptation AS (
    SELECT 
        b.donor_name,
        'Adaptation' AS "Rio Marker",
        b.year,
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
    GROUP BY 1,2,3
), 

mitigation AS (
    SELECT 
        b.donor_name,
        'Mitigation' AS "Rio Marker",
        b.year,
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
    GROUP BY 1,2,3
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
    year,
    "Rio Marker",
    round("Cross-cutting", 2) AS "Cross-cutting",
    round("Bilateral ODA", 2) AS "Bilateral ODA",
    "Share" || '%' AS "Share" --Adding || to a column is concatenation. this is adding '%' to the share column
FROM combined
ORDER BY donor_name, year, "Rio Marker"