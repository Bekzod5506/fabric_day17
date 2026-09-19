CREATE VIEW vw_sales_analysis AS
SELECT c.name, c.country, p.product_name, p.category,
       d.full_date, d.year, d.quarter,
       f.quantity, f.total_amount
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key;

GO