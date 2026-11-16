CREATE OR REPLACE VIEW gold.vw_churn_features_base AS

SELECT
    LOWER(TRIM(f.shop_domain)) AS merchant_id,
    f.date_t_eom,
    DATE_TRUNC('month', f.date_t_eom)::DATE AS snapshot_month,

    -- Finance features
    f.tenure_in_months,
    f.bom_mrr,
    f.eom_mrr,
    f.churn_mrr,

    -- GMV features
    g.gmv_growth_1m,
    g.gmv_growth_2m,

    -- Search features
    s.searches_1m,
    s.searches_2m,
    s.searches_growth_1m,
    s.searches_growth_2m,
    
    --addd 2 col gmv
    g.gmv_1m,
	g.gmv_2m

FROM silver.vw_finance_cube_data f

LEFT JOIN gold.vw_gmv_monthly_features g
    ON LOWER(TRIM(f.shop_domain)) = g.merchant_id
    AND f.date_t_eom = g.date_t_eom

LEFT JOIN gold.vw_search_monthly_features s
    ON LOWER(TRIM(f.shop_domain)) = s.merchant_id
    AND f.date_t_eom = s.date_t_eom;

