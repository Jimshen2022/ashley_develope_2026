with firmplusplan AS 
(
SELECT [ReportDate]
      ,[Warehouse]
      ,[Invoicing]
      ,[Closed BOL not Invoiced]
      ,[Closed No BOL]
      ,[Scanning in Process]
      ,[Grand Total]
      ,[Trip Assign No Scan Mfg Date]
	  ,DATEADD(DAY, 7 - DATEPART(WEEKDAY, [ReportDate]), CAST([ReportDate] AS DATE)) AS [Week End Date]
	  ,CASE WHEN DATEADD(DAY, 7 - DATEPART(WEEKDAY, [ReportDate]), CAST([ReportDate] AS DATE)) < GETDATE() THEN 'Last Week' ELSE 'This Week' END AS [Week Assignment]
FROM [PowerBI_ADS].[FirmPlusPlan]
WHERE DATEDIFF(DAY, reportdate, GETDATE()) IN (0, 7)
  AND [trip assign no scan mfg date] = 'True'
  AND [warehouse] IN ('1', '17', '15', '5', 'ECR', '42', '28', '335')
  ),
  invoicing AS 
  (
SELECT
    --[SISInvoiceDate] AS [Invoice Date],
	DATEADD(DAY, 7 - DATEPART(WEEKDAY, [SISInvoiceDate]), CAST([SISInvoiceDate] AS DATE)) AS [Week Ending Date]
    ,[SISWarehouse] AS [Warehouse]
    ,SUM(ISNULL([SISInvoiceAmount], 0)) AS [Amount]
FROM [PowerBI_Distribution].[SAS_InvoiceSummary] SAS
WHERE CAST([SISInvoiceDate] AS DATE) BETWEEN DATEADD(DAY, -20, GETDATE()) AND DATEADD(DAY, -1, GETDATE())
GROUP BY --[SISInvoiceDate], [SISWarehouse]
 DATEADD(DAY, 7 - DATEPART(WEEKDAY, [SISInvoiceDate]), CAST([SISInvoiceDate] AS DATE)), [siswarehouse]
)
SELECT
    firmplusplan.reportdate AS [Report Date]
    ,firmplusplan.warehouse AS [Warehouse]
    ,firmplusplan.[Invoicing]
    ,firmplusplan.[Closed BOL not Invoiced]
    ,firmplusplan.[Closed No BOL]
    ,firmplusplan.[Scanning in Process]
    ,firmplusplan.[Grand Total]
    ,firmplusplan.[Trip Assign No Scan Mfg Date]
	,firmplusplan.[Week End Date]
	,firmplusplan.[Week Assignment]
	,invoicing.amount AS [Weekly Invoicing]
FROM firmplusplan firmplusplan
LEFT JOIN invoicing invoicing
    ON Invoicing.[Warehouse] = firmplusplan.[Warehouse]
    AND invoicing.[week ending date] = firmplusplan.[week end date];