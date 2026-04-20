WITH Query1 AS (
    SELECT
        [SISInvoiceDate] AS [Invoice Date],
        [SISWarehouse] AS [Warehouse],
        SUM(ISNULL([SISInvoiceAmount], 0)) AS [Amount]
    FROM [PowerBI_Distribution].[SAS_InvoiceSummary] SAS
    WHERE CAST([SISInvoiceDate] AS DATE) BETWEEN DATEADD(DAY, -200, GETDATE()) AND DATEADD(DAY, -1, GETDATE())
    GROUP BY [SISInvoiceDate], [SISWarehouse]
),

Query2 AS (
    SELECT
        RTN.[Warehouse],
        CAST(CAST(RTN.[ReportDate] AS VARCHAR(15)) AS DATE) AS [Date Added],
        SUM(RTN.[PriceofItem]) AS [Price]
    FROM [PowerBI_ADS].[RARETNFL] RTN
    WHERE CAST(CAST(RTN.[ReportDate] AS VARCHAR(15)) AS DATE) BETWEEN DATEADD(DAY, -200, GETDATE()) AND DATEADD(DAY, -1, GETDATE())
    GROUP BY RTN.[Warehouse], CAST(CAST(RTN.[ReportDate] AS VARCHAR(15)) AS DATE)
)
-- Left join the two queries on Warehouse and Date
SELECT
    COALESCE(Q1.[Invoice Date], Q2.[Date Added]) AS [Date],
    COALESCE(Q1.[Warehouse], Q2.[Warehouse]) AS [Warehouse],
    Q1.[Amount] AS [Invoicing]
    ,Q2.[Price] AS [RA Dollars]
FROM Query1 Q1
LEFT JOIN Query2 Q2
    ON Q1.[Warehouse] = Q2.[Warehouse]
    AND Q1.[Invoice Date] = Q2.[Date Added];