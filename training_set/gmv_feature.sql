
CREATE OR REPLACE VIEW gold.vw_gmv_monthly_features AS

WITH finance_base AS (
    SELECT DISTINCT
        LOWER(TRIM(shop_domain)) AS merchant_id,
        date_t_eom,
        DATE_TRUNC('month', date_t_eom)::DATE AS snapshot_month
    FROM silver.vw_finance_cube_data
),

-- Tổng hợp GMV USD theo merchant và tháng
gmv_monthly AS (
    SELECT
        LOWER(TRIM(tenant_id)) AS merchant_id,
        DATE_TRUNC('month', order_month)::DATE AS order_month,
        SUM(total_gmv) AS total_gmv_usd
    FROM silver.vw_gmv_base_month
    GROUP BY
        LOWER(TRIM(tenant_id)),
        DATE_TRUNC('month', order_month)::DATE
),

-- Ghép GMV của 4 tháng liên tiếp với snapshot finance
gmv_period AS (
    SELECT
        f.merchant_id,
        f.date_t_eom,
        f.snapshot_month,

        COALESCE(g0.total_gmv_usd, 0) AS gmv_t,
        COALESCE(g1.total_gmv_usd, 0) AS gmv_t1,
        COALESCE(g2.total_gmv_usd, 0) AS gmv_t2,
        COALESCE(g3.total_gmv_usd, 0) AS gmv_t3

    FROM finance_base f

    LEFT JOIN gmv_monthly g0
        ON f.merchant_id = g0.merchant_id
       AND f.snapshot_month = g0.order_month

    LEFT JOIN gmv_monthly g1
        ON f.merchant_id = g1.merchant_id
       AND f.snapshot_month - INTERVAL '1 month' = g1.order_month

    LEFT JOIN gmv_monthly g2
        ON f.merchant_id = g2.merchant_id
       AND f.snapshot_month - INTERVAL '2 months' = g2.order_month

    LEFT JOIN gmv_monthly g3
        ON f.merchant_id = g3.merchant_id
       AND f.snapshot_month - INTERVAL '3 months' = g3.order_month
)

SELECT
    merchant_id,
    date_t_eom,

    CASE
        WHEN gmv_t1 > 0
        THEN gmv_t / gmv_t1 - 1
        ELSE NULL
    END AS gmv_growth_1m,

    CASE
        WHEN gmv_t2 + gmv_t3 > 0
        THEN (gmv_t + gmv_t1) / (gmv_t2 + gmv_t3) - 1
        ELSE NULL
    END AS gmv_growth_2m,
    
    gmv_t AS gmv_1m,
	gmv_t + gmv_t1 AS gmv_2m

FROM gmv_period;
