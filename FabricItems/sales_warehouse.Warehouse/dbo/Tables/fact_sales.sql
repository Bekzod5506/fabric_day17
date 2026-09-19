CREATE TABLE [dbo].[fact_sales] (
    [sale_key]     INT             NULL,
    [customer_key] INT             NULL,
    [product_key]  INT             NULL,
    [date_key]     INT             NULL,
    [quantity]     INT             NULL,
    [total_amount] DECIMAL (10, 2) NULL,
    [order_id]     INT             NULL
);


GO