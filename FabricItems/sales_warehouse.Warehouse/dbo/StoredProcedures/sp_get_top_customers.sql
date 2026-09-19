CREATE PROCEDURE sp_get_top_customers @top_n INT
AS
SELECT TOP(@top_n) name,
       SUM(total_amount) AS total_spent
FROM vw_sales_analysis
GROUP BY name
ORDER BY total_spent DESC;

GO