// SQL Query Template

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="


SELECT CONCAT(TRIM([OPT].[Sku]),'_',TRIM([OPT].[Location])) AS [Item_WH]
      ,[OPT].[Sku] AS [Item SKU]
      ,[OPT].[Location] AS [Warehouse]
      ,CONVERT(DATE, DATEADD(DAY, 15, [OPT].[DtuDate])) AS [FiscalPeriod]
      ,ISNULL([OPT].[ServiceLevel],0) AS [ServiceLevel]
      ,CAST(CEILING([OPT].[DemandAverage]) AS INT) AS [Demand Avg]
	  ,ISNULL([OPT].[DemandUncertainty],0) AS [Demand Variance]
      ,CAST(CEILING([OPT].[SafetyStockLevelCalculated]  ) AS INT) AS [SS Qty Suggested]
      ,CAST(CEILING([OPT].[SafetyStockPOSCalculated]) AS INT) [SS DOS Suggested]
      ,CAST(CEILING([OPT].[SafetyStockLevel]			  ) AS INT) AS [SS Qty Selected]
      ,CAST(CEILING([OPT].[SafetyStockLevelLowerLimit]  ) AS INT) AS [SS LL Qty]
      ,CAST(CEILING([OPT].[SafetyStockLevelUpperLimit]  ) AS INT) AS [SS UL Qty]
      --,CAST(CEILING([SafetyStockLevel_adjusted]	  ) AS INT) AS [SS Qty Adjusted]
      ,[OPT].[SafetyStockPOSLowerLimit] AS [DOS LL Setting]
      ,[OPT].[SafetyStockPOSUpperLimit] AS [DOS UL Setting]
      --,[SafetyStockPOS] 
      ,CAST(CEILING([OPT].[SafetyStockPOS_adjusted]) AS INT) AS [SS DOS Constrained]
      ,CAST(CEILING([OPT].[SafetyStockLevelMax] ) AS INT) AS [SS Max Qty Constrained]
      ,CAST(CEILING([OPT].[SafetyStockPOSMax]	  ) AS INT) AS [SS Max DOS Constrained]
	  ,[DIN].[dinSafetyStock]
	  ,[DIN].[dinMakeBuyCode]
	  ,[DIN].[dinSource1]
	  ,[DIN].[dinInventoryPlanningABCCode]
	  ,[DIN].[dinInventoryPlanningABCCode] AS [GF ABC]
	  --,[ExportDate]
      --,[Season]
      --,[SkuId]
      --,[LocationId]
      --,[SeasonId]
      --,[Dtu]
      --,[SafetyStockLevelMaxActual]
      --,[SafetyStockPOSMaxActual]
      --,[BaseStockLevel]
      --,[OnHandStockLevel]
      --,[OnHandStockPOS]
      --,[KanbanCardsCalculated]
      --,[KanbanCardsLowerLimit]
      --,[KanbanCardsUpperLimit]
      --,[KanbanCards]
      --,[KanbanCards_adjusted]
      --,[ReorderPointCalculated]
      --,[ReorderPointLowerLimit]
      --,[ReorderPointUpperLimit]
      --,[ReorderPoint]
      --,[ReorderPoint_adjusted]
      --,[CalculatedMinLevel]
      --,[CalculatedMinPOS]
      --,[CalculatedMaxLevel]
      --,[CalculatedMaxPOS]
      --,[SafetyStockTargetActualLevel]
      --,[SafetyStockTargetActualPOS]
      --,[KanbanCardsTargetActual]
      --,[ReorderPointTargetActual]
      --,[OnHandStockTargetActualLevel]
      --,[OnHandStockTargetActualPOS]
      --,[TargetType]
      --,[DisaggregationType]
      --,[DisaggregationType_adjusted]
      --,[SafetyTargetLevel]
      --,[SafetyTargetLevel_adjusted]
      --,[SafetyTargetPOS]
      --,[SafetyTargetPOS_adjusted]
      --,[SafetyTimeLevel]
      --,[SafetyTimeLevel_adjusted]
      --,[SafetyTimePOS]
      --,[SafetyTimePOS_adjusted]
      --,[SafetyTargetActualLevel]
      --,[SafetyTargetActualPOS]
      --,[SafetyTimeActualLevel]
      --,[SafetyTimeActualPOS]
      --,[NetReplenishmentLeadTime]
      --,[EngineType]
      --,[ServiceTime200]
      --,[IncomingServiceTime308]
      --,[ReviewPeriod234]
      --,[BatchOrderQuantity520]
      --,[KanbanBinSize]
      --,[ReplenishmentsPerRp237]
      --,[LaunchDate]
      --,[LeadTimeAve]
      --,[LeadTimeStdev]
  FROM [SupplyChain_Enh].[IOExportedItemOutputsSnapshot] AS OPT
  LEFT JOIN [SupplyChain_Enh].[DemandInventorySnapshot] AS DIN
    ON [OPT].[Sku] = [DIN].[dinItem]
	  AND [OPT].[Location] = [DIN].[dinWarehouse]
	  AND CONVERT(DATE, DATEADD(DAY, 14, [OPT].[DtuDate])) = CONVERT(DATE, CONCAT([DIN].[dinFiscalMonth],15))
	  AND [DIN].[dtea] = (SELECT MAX([dtea]) FROM [SupplyChain_Enh].[DemandInventorySnapshot])
  WHERE [OPT].[SnapshotDate] = (SELECT MAX([SnapshotDate]) FROM [SupplyChain_Enh].[IOExportedItemOutputsSnapshot])
    AND [OPT].[DtuDate] < DATEADD(MONTH, 6, GETDATE())
    AND [OPT].[Location] IN ('1','101','12','15','151','17','19','20','28','3','335','42','5','60','ECR')
	--AND [OPT].[Sku] = '1202038'


                      ", CreateNavigationProperties=false])
in
    Source