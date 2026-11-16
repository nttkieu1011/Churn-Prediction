CREATE OR REPLACE VIEW gold.churn_training_set AS

SELECT
    LOWER(TRIM(l.shop_domain)) AS shop_key,
    f.snapshot_month,

    -- Finance features
    f.tenure_in_months,
    f.bom_mrr,
    f.eom_mrr,

    -- GMV features
    f.gmv_growth_1m,
    f.gmv_growth_2m,


    -- Search features
    f.searches_1m,
    f.searches_2m,
    f.searches_growth_1m,
    f.searches_growth_2m,

    -- Label
    l.churn_next_30d,

    -- Data split
    CASE
        WHEN f.snapshot_month IN (
            DATE '2026-06-01',
            DATE '2026-07-01'
        ) THEN 'train'
        WHEN f.snapshot_month = DATE '2026-08-01'
            THEN 'test'
    END AS split,
        
    --addd 2 col gmv
    f.gmv_1m,
	f.gmv_2m

FROM gold.churn_labels l

INNER JOIN gold.vw_churn_features_base f
    ON LOWER(TRIM(l.shop_domain)) = f.merchant_id
    AND DATE_TRUNC('month', l.snapshot_month)::DATE
        = f.snapshot_month;
