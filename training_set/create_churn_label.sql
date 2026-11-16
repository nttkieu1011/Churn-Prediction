
-- 1. Active merchants
CREATE OR REPLACE VIEW gold.active_merchants AS

SELECT
    shop_domain,
    date_t_eom AS snapshot_month
FROM silver.vw_finance_cube_data
WHERE eom_mrr <> 0
  AND churn_mrr = 0;


-- 2. Churn merchants
CREATE OR REPLACE VIEW gold.churn_merchants AS

SELECT
    shop_domain,
    date_t_eom AS snapshot_month
FROM silver.vw_finance_cube_data
WHERE churn_mrr <> 0;


-- 3. Churn labels
CREATE OR REPLACE VIEW gold.churn_labels AS

SELECT
    a.shop_domain,
    a.snapshot_month,

    CASE
        WHEN c.shop_domain IS NOT NULL THEN 1
        ELSE 0
    END AS churn_next_30d

FROM gold.active_merchants a

LEFT JOIN gold.churn_merchants c
    ON a.shop_domain = c.shop_domain
   AND DATE_TRUNC('month', c.snapshot_month)
       = DATE_TRUNC('month', a.snapshot_month)
         + INTERVAL '1 month'

-- Chỉ lấy snapshot có dữ liệu tháng tiếp theo
WHERE EXISTS (
    SELECT 1
    FROM silver.vw_finance_cube_data f
    WHERE DATE_TRUNC('month', f.date_t_eom)
          = DATE_TRUNC('month', a.snapshot_month)
            + INTERVAL '1 month'
);
