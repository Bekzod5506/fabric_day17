CREATE TABLE [dbo].[dim_date] (
    [date_key]   INT          NULL,
    [full_date]  DATE         NULL,
    [year]       INT          NULL,
    [month]      INT          NULL,
    [day]        INT          NULL,
    [quarter]    INT          NULL,
    [month_name] VARCHAR (20) NULL
);


GO