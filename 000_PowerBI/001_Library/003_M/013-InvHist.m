// SQL Query Template

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="

DECLARE @SSFactor AS DEC(10,2)
SET @SSFactor = .5


SELECT CONCAT(TRIM([Inv].[Item SKU]),'_',TRIM([Inv].[Warehouse])) AS [Item_WH] 
      ,[Inv].[Item SKU]
      ,[Inv].[Warehouse]
      ,[Inv].[Fiscal Week End]
	  ,[Inv].[Make/Buy]
	  ,[Inv].[Source]
	  ,[PRP].[ProductionResource]
      ,[Inv].[Inv Qty]
      ,[Inv].[SS Target]
      ,[Inv].[Min SS]
      ,CASE 
			WHEN [Inv].[Max SS] < ISNULL([PRP].[MOQ],0) AND [Inv].[Make/Buy] = 'M'
				THEN [Inv].[SS Target] +ISNULL([PRP].[MOQ],0)
			ELSE [Inv].[Max SS]
		END AS [Max SS]
	  ,CASE 
		  WHEN [Inv].[Max SS] < [PRP].[MOQ]
			 THEN 
				CASE 
					WHEN [Inv].[Inv Qty] < ISNULL([Inv].[Min SS],0)
						THEN 'Under'  
					WHEN [Inv].[Inv Qty] > ([Inv].[SS Target] +ISNULL([PRP].[MOQ],0) ) AND [Inv].[Make/Buy] = 'M'
						THEN 'Over'  
					WHEN [Inv].[Inv Qty] > ([Inv].[Max SS]) AND [Inv].[Make/Buy] <> 'M'
						THEN 'Over'
					ELSE 'In Control'
					END 
			ELSE [Inv].[Inv Status]
		END AS [Inv Status]
      ,[Inv].[Inv Status]
      ,[Inv].[Build Qty]
      ,[Inv].[SS + Build]
      ,[Inv].[Min SS+Build]
      ,[Inv].[Max SS+Build]
      ,[Inv].[Inv Status w/ Build]
      ,[Inv].[Inv Qty] * [CPD].[FOB Price] AS [$ Inv]
      ,[Inv].[SS Target] * [CPD].[FOB Price] AS [$ SS Target]
      ,[Inv].[Min SS] * [CPD].[FOB Price] AS [$ Min SS]
      ,CASE 
			WHEN [Inv].[Max SS] < [PRP].[MOQ]
				THEN ([Inv].[SS Target] +[PRP].[MOQ]) * [CPD].[FOB Price]
			ELSE [Inv].[Max SS]* [CPD].[FOB Price]
		END AS [$ Max SS]
      ,[Inv].[Build Qty] * [CPD].[FOB Price] AS [$ Build]
      ,[Inv].[SS + Build] * [CPD].[FOB Price] AS [$ SS + Build]
      ,[Inv].[Min SS+Build] * [CPD].[FOB Price] AS [$ Min SS+Build]
      ,[Inv].[Max SS+Build] * [CPD].[FOB Price] AS [$ Max SS+Build]
      ,[Inv].[Snapshot Date]

FROM ( 
SELECT [DIN].[dinItem] AS [Item SKU]
      ,[DIN].[dinWarehouse] AS [Warehouse]
	  ,CONVERT(DATE, [DIN].[dtea]) AS [Fiscal Week End]
	  ,[DIN].[dinMakeBuyCode] AS [Make/Buy]
	  ,COALESCE([PRQ2].[Source],[DIN].[dinSource1]) AS [Source]
	  ,[DIN].[dinOnHandQuantity] AS [Inv Qty]
	  ,[DIN].[dinSafetyStock] AS [SS Target]
	  ,([DIN].[dinSafetyStock] * (1-@SSFactor)) AS [Min SS]
	  ,([DIN].[dinSafetyStock] * (1+@SSFactor)) AS [Max SS]
	  ,CASE
			WHEN [DIN].[dinOnHandQuantity] < ([DIN].[dinSafetyStock] * (1-@SSFactor))
				THEN 'Under'
			WHEN [DIN].[dinOnHandQuantity] > ([DIN].[dinSafetyStock] * (1+@SSFactor))
				THEN 'Over'
			ELSE 'In Control'
		END AS [Inv Status]
	  ,[DIN].[dinBuildQuantity] AS [Build Qty]
	  ,[DIN].[dinSafetyStock] + [DIN].[dinBuildQuantity] AS [SS + Build]
	  ,(([DIN].[dinSafetyStock] * (1-@SSFactor))+[DIN].[dinBuildQuantity]) AS [Min SS+Build]
	  ,(([DIN].[dinSafetyStock] * (1+@SSFactor))+[DIN].[dinBuildQuantity]) AS [Max SS+Build]
	  ,CASE
			WHEN [DIN].[dinOnHandQuantity] < (([DIN].[dinSafetyStock] * (1-@SSFactor))+[DIN].[dinBuildQuantity])
				THEN 'Under'
			WHEN [DIN].[dinOnHandQuantity] > (([DIN].[dinSafetyStock] * (1+@SSFactor))+[DIN].[dinBuildQuantity])
				THEN 'Over'
			ELSE 'In Control'
		END AS [Inv Status w/ Build]
      ,[Snapshot Date] = (SELECT MAX(CONVERT(DATE, [dtea])) FROM [Wholesale_DemandPlanning_AFI].[SupplyPlanDetail] )
  FROM [SupplyChain_Enh].[DemandInventorySnapshot] AS DIN
  INNER JOIN (
SELECT DISTINCT [FiscalWeekLastDate]
      ,[FiscalMonthYear]
  FROM [Enterprise_DW].[DimDate]
  WHERE [FiscalMonthIndicator] >= -6
    AND [FiscalWeekIndicator] < 0

  ) AS D1
  ON CONVERT(DATE, [DIN].[dtea]) = [D1].[FiscalWeekLastDate]
    AND [DIN].[dinFiscalMonth] = [D1].[FiscalMonthYear]

  LEFT JOIN ( -- Replace Source with Vendor# for Buy Locations

SELECT DISTINCT [PRQ].[prqItem]
      ,[PRQ].[prqWarehouse]
	  ,[MBX] = 'B'
	  ,[PRQ].[prqVendorNumber] AS [Source]
  FROM [Wholesale_DemandPlanning_AFI].[PlannedRequirementsLogility] AS PRQ
  INNER JOIN [SupplyChain_DW].[DimCurrentProductDetails] AS CPD
    ON [PRQ].[prqItem] = [CPD].[Item SKU]
	  --AND [CPD].[AFI Finance Division] IN ('DOMESTIC BEDDING', 'IMPORT BEDDING')
  WHERE [PRQ].[dtea] = (SELECT MAX([dtea]) FROM [Wholesale_DemandPlanning_AFI].[PlannedRequirementsLogility])
    --AND [PRQ].[prqVendorNumber] IN ('600039','624556','900515')
	AND [PRQ].[prqWarehouse] <> '335'

  ) AS PRQ2
  ON [DIN].[dinItem] = [PRQ2].[prqItem]

	AND [DIN].[dinSource1] = [PRQ2].[prqWarehouse]


  WHERE ([DIN].[dinSafetyStock] > 0 OR [DIN].[dinOnHandQuantity] > 0)
  
   --AND [DIN].[dinItem] = 'M69731'
   --AND [DIN].[dinWarehouse] = '1'


UNION 


SELECT [DIN].[dinItem] AS [Item SKU]
      ,[DIN].[dinWarehouse] AS [Warehouse]
	  ,[D1].[FiscalWeekLastDate] AS [Fiscal Week End]
	  ,[DIN].[dinMakeBuyCode] AS [Make/Buy]
	  ,COALESCE([PRQ3].[Source],[DIN].[dinSource1]) AS [Source]
	  ,[SPD].[spdShippableInventory] AS [Inv Qty]
	  ,[DIN].[dinSafetyStock] AS [SS Target]
	  ,([DIN].[dinSafetyStock] * (1-@SSFactor)) AS [Min SS]
	  ,([DIN].[dinSafetyStock] * (1+@SSFactor)) AS [Max SS]
	  ,CASE
			WHEN [SPD].[spdShippableInventory] < ([DIN].[dinSafetyStock] * (1-@SSFactor))
				THEN 'Under'
			WHEN [SPD].[spdShippableInventory] > ([DIN].[dinSafetyStock] * (1+@SSFactor))
				THEN 'Over'
			ELSE 'In Control'
		END AS [Inv Status]
	  ,[DIN].[dinBuildQuantity] AS [Build Qty]
	  ,[DIN].[dinSafetyStock] + [DIN].[dinBuildQuantity] AS [SS + Build]
	  ,(([DIN].[dinSafetyStock] * (1-@SSFactor))+[DIN].[dinBuildQuantity]) AS [Min SS+Build]
	  ,(([DIN].[dinSafetyStock]* (1+@SSFactor))+[DIN].[dinBuildQuantity])  AS [Max SS+Build]
	  ,CASE
			WHEN [SPD].[spdShippableInventory] < (([DIN].[dinSafetyStock]* (1-@SSFactor))+[DIN].[dinBuildQuantity]) 
				THEN 'Under'
			WHEN [SPD].[spdShippableInventory] > (([DIN].[dinSafetyStock] * (1+@SSFactor))+[DIN].[dinBuildQuantity])
				THEN 'Over'
			ELSE 'In Control'
		END AS [Inv Status w/ Build]
      ,[Snapshot Date] = (SELECT MAX(CONVERT(DATE, [dtea])) FROM [Wholesale_DemandPlanning_AFI].[SupplyPlanDetail] )
 FROM [SupplyChain_Enh].[DemandInventorySnapshot] AS DIN
  INNER JOIN (
SELECT DISTINCT [FiscalWeekLastDate]
      ,[FiscalMonthYear]
  FROM [Enterprise_DW].[DimDate]
  WHERE [FiscalMonthIndicator] < 8
    AND [FiscalWeekIndicator] >= 0

  ) AS D1
   ON [DIN].[dinFiscalMonth] = [D1].[FiscalMonthYear]

LEFT JOIN [Wholesale_DemandPlanning_AFI].[SupplyPlanDetail] AS SPD
  ON [SPD].[dtea] = (SELECT MAX([dtea]) FROM [Wholesale_DemandPlanning_AFI].[SupplyPlanDetail] )
    AND [DIN].[dinItem] = [SPD].[spdItem]
	AND [DIN].[dinWarehouse] = [SPD].[spdWarehouse]
	AND [D1].[FiscalWeekLastDate] = [SPD].[spdWeekEnding]

  LEFT JOIN ( 

SELECT DISTINCT [PRQ].[prqItem]
      ,[PRQ].[prqWarehouse]
	  ,[MBX] = 'B'
	  ,[PRQ].[prqVendorNumber] AS [Source]
  FROM [Wholesale_DemandPlanning_AFI].[PlannedRequirementsLogility] AS PRQ
  INNER JOIN [SupplyChain_DW].[DimCurrentProductDetails] AS CPD
    ON [PRQ].[prqItem] = [CPD].[Item SKU]
	  --AND [CPD].[AFI Finance Division] IN ('DOMESTIC BEDDING', 'IMPORT BEDDING')
  WHERE [PRQ].[dtea] = (SELECT MAX([dtea]) FROM [Wholesale_DemandPlanning_AFI].[PlannedRequirementsLogility])
    --AND [PRQ].[prqVendorNumber] IN ('600039','624556','900515')
	AND [PRQ].[prqWarehouse] <> '335'

  ) AS PRQ3
  ON [DIN].[dinItem] = [PRQ3].[prqItem]
	AND [DIN].[dinSource1] = [PRQ3].[prqWarehouse]

 WHERE [DIN].[dtea] = (SELECT MAX([dtea]) FROM [SupplyChain_Enh].[DemandInventorySnapshot])
  
   --AND [DIN].[dinItem] = 'M69731'
   --AND [DIN].[dinWarehouse] = '1'


   ) AS Inv

  LEFT JOIN [SupplyChain_DW].[DimCurrentProductDetails] AS CPD
    ON [Inv].[Item SKU] = [CPD].[Item SKU]


  LEFT JOIN ( -- Join Prod Resource
SELECT [PRP].[Item]
      ,[PRP].[Location]
	  ,[PRP].[ProductionResource]
	  ,MIN([PRP].[Qty]) AS [MOQ]
  FROM [SupplyChain_Enh].[ProductionResourcePlan] AS PRP
  WHERE [PRP].[SnapshotDate] = (SELECT MAX([SnapshotDate]) FROM [SupplyChain_Enh].[ProductionResourcePlan])
 GROUP BY [PRP].[Item]
         ,[PRP].[Location]
         ,[PRP].[ProductionResource]

  ) AS PRP
	ON [Inv].[Item SKU] = [PRP].[Item]
	  AND [Inv].[Source] = [PRP].[Location]

  WHERE ([Inv].[SS Target] > 0 OR [Inv].[Inv Qty] <> 0)


                      ", CreateNavigationProperties=false]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Fiscal Week End", type date}, {"Inv Qty", Int64.Type}, {"SS Target", Int64.Type}, {"Min SS", Int64.Type}, {"Max SS", Int64.Type}, {"Build Qty", Int64.Type}, {"SS + Build", Int64.Type}, {"Min SS+Build", Int64.Type}, {"Max SS+Build", Int64.Type}, {"Snapshot Date", type date}})
in
    #"Changed Type"