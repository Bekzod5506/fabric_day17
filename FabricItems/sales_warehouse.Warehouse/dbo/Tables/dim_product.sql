CREATE TABLE [dbo].[dim_product] (
    [product_key]  INT             NULL,
    [product_id]   INT             NULL,
    [product_name] VARCHAR (100)   NULL,
    [category]     VARCHAR (50)    NULL,
    [price]        DECIMAL (10, 2) NULL
);


GO