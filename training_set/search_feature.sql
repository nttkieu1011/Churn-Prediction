
CREATE OR REPLACE VIEW gold.vw_search_monthly_features AS

WITH finance_base AS (
    SELECT DISTINCT
        LOWER(TRIM(shop_domain)) AS merchant_id,
        date_t_eom,
        DATE_TRUNC('month', date_t_eom)::DATE AS snapshot_month
    from silver.vw_finance_cube_data vfcd 
),

search_monthly AS (
    SELECT
        LOWER(TRIM(tenant_id)) AS merchant_id,
        DATE_TRUNC('month', order_month)::DATE AS order_month,
        SUM(total_searches) AS total_searches
    FROM silver.vw_search_traffic_raw_monthly
    GROUP BY 1, 2
),

monthly_features AS (
    SELECT
        f.merchant_id,
        f.date_t_eom,
        f.snapshot_month,

        COALESCE(s0.total_searches, 0) AS searches_t,
        COALESCE(s1.total_searches, 0) AS searches_t_1,
        COALESCE(s2.total_searches, 0) AS searches_t_2,
        COALESCE(s3.total_searches, 0) AS searches_t_3

    FROM finance_base f

    LEFT JOIN search_monthly s0
        ON f.merchant_id = s0.merchant_id
        AND s0.order_month = f.snapshot_month

    LEFT JOIN search_monthly s1
        ON f.merchant_id = s1.merchant_id
        AND s1.order_month = f.snapshot_month - INTERVAL '1 month'

    LEFT JOIN search_monthly s2
        ON f.merchant_id = s2.merchant_id
        AND s2.order_month = f.snapshot_month - INTERVAL '2 months'

    LEFT JOIN search_monthly s3
        ON f.merchant_id = s3.merchant_id
        AND s3.order_month = f.snapshot_month - INTERVAL '3 months'
)

SELECT
    merchant_id,
    date_t_eom,

    searches_t AS searches_1m,

    searches_t + searches_t_1 AS searches_2m,

    (searches_t - searches_t_1) * 1.0
        / NULLIF(searches_t_1, 0) AS searches_growth_1m,

    (searches_t + searches_t_1) * 1.0
        / NULLIF(searches_t_2 + searches_t_3, 0) - 1
        AS searches_growth_2m

FROM monthly_features;





