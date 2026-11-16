
-- Create schema if it does not exist
CREATE SCHEMA IF NOT EXISTS silver;


-- 1. Finance Cube Data
CREATE OR REPLACE VIEW silver.vw_finance_cube_data AS
SELECT
    TO_DATE(date_t_eom, 'YYYY-MM-DD') AS date_t_eom,
    shop_domain,
    tenure_in_months,
    churn_mrr,
    bom_mrr,
    eom_mrr,
    ingestion_at
FROM bronze.finance_cube_data;


-- 2. GMV Base Month
CREATE OR REPLACE VIEW silver.vw_gmv_base_month AS
SELECT
    tenant_id,
    TO_DATE(order_month || '-01', 'YYYY-MM-DD') AS order_month,
    shop_currency_code,
    total_gmv,
    ingestion_at
FROM bronze.gmv_base_month;


-- 3. Search Traffic Raw Monthly
CREATE OR REPLACE VIEW silver.vw_search_traffic_raw_monthly AS
SELECT
    tenant_id,
    TO_DATE(order_month || '-01', 'YYYY-MM-DD') AS order_month,
    total_searches,
    total_product_click,
    total_search_click,
    total_add_carts,
    total_orders,
    total_sales,
    ingestion_at
FROM bronze.search_traffic_raw_monthly;


-- 4. Dimension Plan Name
CREATE OR REPLACE VIEW silver.vw_dim_plan_name AS
SELECT
    tenant_id,
    price_version,
    uninstallation_reason,
    boost_plan_name,
    boost_price_plan,
    ingestion_at
FROM bronze.dim_plan_name;
