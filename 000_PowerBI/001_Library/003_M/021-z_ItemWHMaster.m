let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="

SELECT DISTINCT CONCAT(TRIM([DIN].[dinItem]),'_',TRIM([DIN].[dinWarehouse])) AS [Item_WH]
      ,[DIN].[dinItem] AS [Item SKU]
      ,[DIN].[dinWarehouse] AS [Warehouse]
      ,[DIN].[dinMakeBuyCode] AS [MBX]
      ,[DIN].[dinSource1] AS [MBX Source]
      ,[DIN].[dinInventoryPlanningABCCode] AS [IP ABC]
      ,[DIN].[dinInvPlanning1stChoice] AS [IP 1st Choice]
      ,[DIN].[dinInvPlanning4thChoice] AS [IP 4th Choice]
  FROM [SupplyChain_Enh].[DemandInventorySnapshot] AS DIN
  WHERE [DIN].[dtea] = (SELECT MAX([dtea]) FROM [SupplyChain_Enh].[DemandInventorySnapshot]) 


                      ", CreateNavigationProperties=false])
in
    Source