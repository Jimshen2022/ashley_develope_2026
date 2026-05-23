// SQL Query Template

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="

/* Inventory Turns */

DECLARE @Periods INT 
SET @Periods = -36

-- Get STD Cost History by Week Ending 
SELECT [MEIR].[FiscalWeekLastDate]
      ,[MEIR].[SiteIdentifier]
	  ,TRIM([MEIR].[ItemNumber]) AS [ItemNumber]
	  ,[MEIR].[StandardCost]
	  --,COALESCE([WM].[Warehouse Code],[IB].[Warehouse]) AS [Warehouse]
	  --,SUM(ISNULL([IB].[OnHandQty],0)) AS [OnHandQty]
	  ,[DD].[FiscalMonthIndicator]
	  ,[DD].[FiscalWeekIndicator]
	  ,[DD].[FiscalMonthLastDate]
	  ,[DD].[FiscalMonthFirstDate]
INTO #STDUC
  FROM [Inventory_Enh_History].[MonthEndItemRevision] AS MEIR

  INNER JOIN [Enterprise_DW].[DimDate] AS DD
    ON [MEIR].[FiscalWeekLastDate] = [DD].[DateID]
	  AND [DD].[FiscalMonthIndicator] BETWEEN @Periods AND -1

  INNER JOIN [Enterprise_DW].[DimItemMaster] AS CPD
    ON  [MEIR].[ItemNumber] = [CPD].[ItemSKU]
	 AND [CPD].[SellableItemFlag] = 'Y'
	 AND [CPD].[MarketIntroducedAt] <> 'Supplier Direct Ship'
     AND [CPD].[ItemClassCode] NOT LIKE 'Z__K'
     AND [CPD].[ItemClassCode] <> 'ZAHM'
     AND [CPD].[ItemClassCode] <> 'ZARP'
     AND [CPD].[ItemSKU] NOT LIKE '%SW'
     AND [CPD].[ItemSKU] NOT LIKE '%CARD'
     AND [CPD].[ItemSKU] NOT LIKE '%UN'
     AND [CPD].[ItemSKU] NOT LIKE '%HIDES'
     AND [CPD].[ItemSKU] NOT LIKE '%VINYL'
 
 WHERE  [MEIR].[SiteIdentifier] = '000' 
    AND LEFT([MEIR].[ChargeNature], 3) = '159'


/* Get Sales Data*/

SELECT [FSH].[Item SKU]
      ,[FSH].[Warehouse]
	  ,[DD].[FiscalWeekLastDate]
	  ,SUM([FSH].[Quantity Shipped]) AS [Qty]
	  ,SUM([FSH].[Amount Shipped] 
	        - [FSH].[Invoice Discount]
			+ [FSH].[Other Allowances])
			- (ISNULL([Q].[Quality]+[Q].[Returns]+[Q].[Shortage],0))
			AS [NetSales]
INTO #Sales		
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
  
  WHERE [FSH].[Warehouse] NOT IN ('55','C','CNW','C35')

GROUP BY [FSH].[Item SKU]
        ,[FSH].[Warehouse]
        ,[DD].[FiscalWeekLastDate]
        ,[Q].[Quality]
        ,[Q].[Returns]
        ,[Q].[Shortage]


-- Calculate Rolling 12Mo Cogs
SELECT [Roll].[FiscalMonthFirstDate]
      ,[Roll].[FiscalMonthLastDate]
      ,[Roll].[FiscalMonthIndicator]
      ,[Roll].[SiteIdentifier]
      ,[Roll].[ItemNumber]
      ,[Roll].[Warehouse]
      ,[Roll].[Avg Std Cost]
      ,[Roll].[Qty]
      ,[Roll].[COGS - STD Cost]
      ,[Roll].[NetSales]
	  ,CAST(SUM([Roll].[COGS - STD Cost])  OVER (PARTITION BY [Roll].[ItemNumber],[Roll].[Warehouse]
												ORDER BY [Roll].[FiscalMonthLastDate]
													ROWS BETWEEN 11 PRECEDING AND 0 PRECEDING
					) AS DEC(10,2)
				) AS [12mo COGS - STD Cost]
INTO #RollCOGS
FROM (

SELECT [C].[FiscalMonthFirstDate]
      ,[C].[FiscalMonthLastDate]
      ,[C].[FiscalMonthIndicator]
      ,[C].[SiteIdentifier]
      ,[C].[ItemNumber]
      ,[S].[Warehouse]
      --,[C].[StandardCost]
	  ,CASE 
			WHEN SUM([S].[Qty]) = 0
			  THEN 0
			ELSE CAST(SUM(([C].[StandardCost]*[S].[Qty]))/SUM([S].[Qty]) AS DEC(10,2)) 
		END AS [Avg Std Cost]
      ,SUM([S].[Qty]) AS [Qty]
	  ,CAST(SUM(([C].[StandardCost]*[S].[Qty])) AS DEC(10,2)) AS [COGS - STD Cost]
      ,SUM([S].[NetSales] ) AS [NetSales]
  FROM [#STDUC] AS C
  LEFT JOIN [#Sales] AS S
    ON [C].[ItemNumber] = [S].[Item SKU]
	  AND [C].[FiscalWeekLastDate] = [S].[FiscalWeekLastDate]
  --WHERE [C].[ItemNumber] = 'M69731'
  --  AND [S].[Warehouse] = '1'

	GROUP BY [C].[FiscalMonthFirstDate]
	        ,[C].[FiscalMonthLastDate]
            ,[C].[FiscalMonthIndicator]
            ,[C].[SiteIdentifier]
            ,[C].[ItemNumber]
            ,[S].[Warehouse]

	) AS Roll


-- Pull Item Balance Records
SELECT [IB1].[FiscalMonthLastDate]
      ,[IB1].[ItemNumber]
      ,[IB1].[Warehouse]
      ,AVG([IB1].[End OH Qty]) AS [Avg OH Qty]
	  ,AVG([IB1].[Inv Dollars]) AS [Avg Inv Dollars]
INTO #ItemBal
FROM ( 

SELECT [STC].[FiscalMonthFirstDate]
      ,[STC].[FiscalMonthLastDate]
	  ,[STC].[FiscalWeekLastDate]
	  ,[STC].[ItemNumber]
	  ,COALESCE([WM].[Warehouse Code],[EIB].[Warehouse]) AS [Warehouse]
	  ,SUM(ISNULL([EIB].[OnHandQty],0)) AS [End OH Qty]
	  ,SUM(ISNULL([EIB].[OnHandQty],0)*[STC].[StandardCost]) AS [Inv Dollars]

  FROM  [#STDUC] AS STC


  LEFT JOIN [Inventory_Enh_History].[ItemBalance] AS EIB
    ON [EIB].[ItemNumber] = [STC].[ItemNumber]
	  AND [EIB].[DateWeekEnding] = [STC].[FiscalWeekLastDate]
  LEFT JOIN [PowerBI_SupplyChain].[WarehouseMaster] AS WM
    ON [EIB].[Warehouse] = [WM].[Intransit Warehouse]

	WHERE [EIB].[Warehouse] NOT IN ('55','C','CNW','C35')


  GROUP BY COALESCE([WM].[Warehouse Code],[EIB].[Warehouse])
          ,[STC].[FiscalMonthFirstDate]
          ,[STC].[FiscalMonthLastDate]
		  ,[STC].[FiscalWeekLastDate]
          ,[STC].[ItemNumber]

	) AS IB1
	GROUP BY [IB1].[FiscalMonthLastDate]
            ,[IB1].[ItemNumber]
            ,[IB1].[Warehouse]



-- Return End Table

SELECT [RC].[FiscalMonthLastDate]
      ,[RC].[ItemNumber] AS [Item SKU]
      ,[RC].[Warehouse]
      ,[RC].[Qty]
      ,[RC].[NetSales]
      ,[RC].[Avg Std Cost]
      ,[RC].[COGS - STD Cost]
	  ,[RC].[12mo COGS - STD Cost]
	  ,CAST(ISNULL([IB].[Avg OH Qty],0) AS DEC(10,2)) AS [Avg OH Qty]
	  ,CAST(ISNULL([IB].[Avg Inv Dollars],0)  AS DEC(10,2)) AS [Avg Inv Dollars]
  FROM [#RollCOGS] AS RC
  LEFT JOIN [#ItemBal] AS IB
    ON [RC].[ItemNumber] = [IB].[ItemNumber]
	  AND [RC].[Warehouse] = [IB].[Warehouse]
	  AND [RC].[FiscalMonthLastDate] = [IB].[FiscalMonthLastDate]
  
  WHERE [RC].[FiscalMonthIndicator] BETWEEN (@Periods+12) AND -1
    AND [RC].[Warehouse] IS NOT NULL



DROP TABLE [#STDUC]
DROP TABLE [#Sales]
DROP TABLE [#RollCOGS]
DROP TABLE [#ItemBal]

                      ", CreateNavigationProperties=false])
in
    Source