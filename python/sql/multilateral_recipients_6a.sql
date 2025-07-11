WITH base AS (
    SELECT 
        coalesce(dmf.abbreviation, mf."ChannelNameE") AS multi_short,
        mf."ChannelNameE" AS full_name,
        mf."Year" AS year,
        "DonorNameE" AS donor_name,
        "Amount" AS amount,
    FROM read_csv_auto("{{multisystem_file}}", delim='|', header=True) mf
    LEFT JOIN "{{dt_multilaterals_file}}" dmf ON trim(dmf.multilateral_name) = trim(lower(mf."ChannelNameE"))
    WHERE 1=1 
    AND "Year" BETWEEN ({{latest_year}} - 4) AND ({{latest_year}})
    AND "FlowType" = 'Disbursements'
    AND "FlowName_e" IN (
        'ODA Loans','Equity Investment','ODA Grants'
    )
    AND "AidToOrThru" = 'Core contributions to'
    AND "AmountType" = 'Constant prices'
), 

deflated AS (
    SELECT 
        b.donor_name AS donor,
        b.year,
        b.multi_short,
        b.full_name,
        {% if deflate %}
            b.amount * dfl.deflator / 100 AS oda,
        {% else %}
            b.amount AS oda,
        {% endif %}

    FROM base b
    INNER JOIN "{{deflator_file}}" dfl ON dfl.donor = b.donor_name AND dfl.year = {{latest_year}}
)

SELECT 
    year AS "Year",
    multi_short AS "Multi_short",
    round(sum(oda), 2) AS "ODA",
    round( 100 * sum(oda) / sum(sum(oda)) OVER (PARTITION BY year), 2) || '%' AS "Share",
    full_name AS "Full Name",
    donor
FROM deflated
GROUP BY 1, 2, 5, 6
ORDER BY year, "ODA" DESC