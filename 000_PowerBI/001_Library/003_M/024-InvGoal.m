// SQL Query Template

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="

SELECT [DFC].[dfcItem] AS [Item SKU]
      ,[DFC].[dfcWarehouse] AS [Warehouse]
	  ,[RVB].[STDUC] AS [Std Cost]
	  ,SUM([DFC].[dfcResultantForecast]+[DFC].[dfcPromotionalLift]) AS [12Mo Fcst]
	  ,CAST(SUM([DFC].[dfcResultantForecast]+[DFC].[dfcPromotionalLift])*[RVB].[STDUC] AS DEC(12,2)) AS [12Mo COGS]
	  ,[Inv].[Goal Inv]
	  ,[Inv].[Goal Inv] * [RVB].[STDUC] AS [Goal Inv Cost]
	  ,[DFC].[dtea] AS [FcastSnapshot]
	  ,[Inv].[InvSnapshot]
  FROM [SupplyChain_Enh].[DemandForecastSnapshot] AS DFC
  INNER JOIN ( 
SELECT DISTINCT [FiscalMonthYear]
  FROM [Enterprise_DW].[DimDate] 
  WHERE [FiscalMonthIndicator] BETWEEN 0 AND 11
  ) AS DD
  ON [DFC].[dfcFiscalMonth] = [DD].[FiscalMonthYear]

LEFT JOIN ( 
SELECT [DIN].[dinItem]
      ,[DIN].[dinWarehouse]
      ,AVG([DIN].[dinSafetyStock]) AS [Goal Inv]
	  ,[DIN].[dtea] AS [InvSnapshot]
  FROM [SupplyChain_Enh].[DemandInventorySnapshot] AS DIN
  INNER JOIN ( 
SELECT DISTINCT [FiscalMonthYear]
  FROM [Enterprise_DW].[DimDate] 
  WHERE [FiscalMonthIndicator] BETWEEN 0 AND 11
  ) AS DD
    ON [DIN].[dinFiscalMonth] = [DD].[FiscalMonthYear]
  LEFT JOIN [PowerBI_SupplyChain].[CurrentProductDetails] AS CPD
    ON [DIN].[dinItem] = [CPD].[Item SKU]
  WHERE [DIN].[dtea] = (SELECT MAX([dtea]) FROM [SupplyChain_Enh].[DemandInventorySnapshot])
    --AND [DIN].[dinItem] = 'M69731'

	GROUP BY [DIN].[dinItem]
            ,[DIN].[dinWarehouse]
			,[DIN].[dtea]
) AS Inv 
  ON [DFC].[dfcItem] = [Inv].[dinItem]
    AND [DFC].[dfcWarehouse] = [Inv].[dinWarehouse]

  LEFT JOIN [MasterData_ItemMaster_AFI].[ITMRVB] AS RVB
    ON [DFC].[dfcItem] = [RVB].[ITNBR]
	  AND [RVB].[STID] = '000'
  WHERE [DFC].[dtea] = (SELECT MAX([dtea]) FROM [SupplyChain_Enh].[DemandForecastSnapshot])
    --AND [DFC].[dfcItem] = 'M69731'

  GROUP BY [DFC].[dfcItem]
          ,[DFC].[dfcWarehouse]
          ,[RVB].[STDUC]
          ,[Inv].[Goal Inv]
          ,[DFC].[dtea]
          ,[Inv].[InvSnapshot]

                      ", CreateNavigationProperties=false])
in
    Source