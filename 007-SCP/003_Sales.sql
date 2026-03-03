/* Get Sales Data*/
DECLARE @Periods INT 
SET @Periods = -36

SELECT [FSH].[Item SKU]
      ,[FSH].[Warehouse]
	  ,[DD].[FiscalWeekLastDate]
	  ,SUM([FSH].[Quantity Shipped]) AS [Qty]
	  ,SUM([FSH].[Amount Shipped] 
	        - [FSH].[Invoice Discount]
			+ [FSH].[Other Allowances])
			- (ISNULL([Q].[Quality]+[Q].[Returns]+[Q].[Shortage],0))
			AS [NetSales]
--INTO #Sales		
  FROM [AFISales_DW].[FactShippedHistory] AS FSH
  INNER JOIN [Enterprise_DW].[DimDate] AS DD
    ON [FSH].[Invoice date] = [DD].[DateID]
	  AND [DD].[FiscalMonthIndicator] BETWEEN @Periods AND -1

LEFT JOIN ( 
SELECT [FQC].[Item SKU]
      ,[IH].[Warehouse]
	  ,[DD].[FiscalWeekLastDate]
	  ,SUM([FQC].[Quality Credits]) AS [Quality]
	  ,SUM([FQC].[Returns Amount]) AS [Returns]
	  ,SUM([FQC].[Short Ship Amount]) AS [Shortage]
  FROM [AFISales_DW].[FactQualityCosts] AS FQC
  
  LEFT JOIN [Wholesale_SalesHistory_AFI].[InvoiceHeader] AS IH
    ON [FQC].[Original Invoice] = [IH].[InvoiceNumber]
	  AND [FQC].[Original Order] = [IH].[OrderNumber]
  
  INNER JOIN [Enterprise_DW].[DimDate] AS DD
    ON [IH].[InvoiceDate] = [DD].[DateID]
	  AND [DD].[FiscalMonthIndicator] BETWEEN @Periods AND -1
  --WHERE [FQC].[Item SKU] = 'M69731'

  GROUP BY [FQC].[Item SKU]
          ,[IH].[Warehouse]
		  ,[DD].[FiscalWeekLastDate]
) AS Q 
  ON [FSH].[Item SKU] = [Q].[Item SKU]
    AND [FSH].[Warehouse] = [Q].[Warehouse]
	AND [DD].[FiscalWeekLastDate] = [Q].[FiscalWeekLastDate]
  
  WHERE [FSH].[Warehouse]  IN ('335')

GROUP BY [FSH].[Item SKU]
        ,[FSH].[Warehouse]
        ,[DD].[FiscalWeekLastDate]
        ,[Q].[Quality]
        ,[Q].[Returns]
        ,[Q].[Shortage]
ORDER BY FiscalWeekLastDate DESC