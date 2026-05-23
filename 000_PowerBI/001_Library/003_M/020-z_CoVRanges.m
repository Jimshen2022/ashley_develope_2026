// SQL Query Template

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="


SELECT [ABC].[Item SKU]
      ,[ABC].[Avg Wkly Demand]
      ,[ABC].[Std Dev of Demand]
      ,[ABC].[CoefVar]
	  ,[B2].[Percentile]
      ,[ABC].[ABC Code]
      ,[ABC].[XYZ Code]
      ,[ABC].[ABCXYZ Code]
      ,[ABC].[SnapshotMonthYear]
      ,[ABC].[Warehouse Group]
FROM [SupplyChain_Enh].[ItemABCCode_AFI]                  AS ABC
    LEFT JOIN [SupplyChain_DW].[DimCurrentProductDetails] AS CPD
        ON [ABC].[Item SKU] = [CPD].[Item SKU]
	LEFT JOIN (
SELECT [B].[Percentile]
      ,MIN([B].[CoefVar]) AS [Min CoV]
	  ,MAX([B].[CoefVar]) AS [Max CoV]
FROM (
SELECT [A].[CoefVar]
      ,CASE 
			WHEN ROUND(PERCENT_RANK() OVER (ORDER BY [A].[CoefVar] ),1) = 0
				THEN .1
			ELSE ROUND(PERCENT_RANK() OVER (ORDER BY [A].[CoefVar] ),1)
		END AS [Percentile]
  FROM [SupplyChain_Enh].[ItemABCCode_AFI] AS A
  WHERE [A].[SnapshotMonthYear] = (SELECT MAX([SnapshotMonthYear]) FROM [SupplyChain_Enh].[ItemABCCode_AFI])

  ) AS B

  GROUP BY [B].[Percentile]

	) AS B2
	ON [ABC].[CoefVar] BETWEEN [B2].[Min CoV] AND [B2].[Max CoV]


WHERE [ABC].[SnapshotMonthYear]   = (SELECT MAX([SnapshotMonthYear]) FROM [SupplyChain_Enh].[ItemABCCode_AFI])
      AND [ABC].[Warehouse Group] = 'AFI'
   --   AND [ABC].[Future Status]   = ''
   --   AND [ABC].[Current Status] IN ('C', 'N')
	  --AND [CPD].[AFI Finance Division] IN ('Import Bedding','Import Casegoods','Imported Upholstery','Upholstery')
	  --AND [CPD].[Series Number] <> '100'


                      ", CreateNavigationProperties=false])
in
    Source