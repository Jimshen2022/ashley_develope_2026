// SQL Query Template

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ashley_edw",
                [CommandTimeout=#duration(0, 1, 0, 0), Query="

SELECT DISTINCT [BOM].[BOM Comp Item Number]
	  ,CASE 
			WHEN [CPD].[AFI Sales Category] IN ('Inner Spring Mattress','Sig. Bedding Inner Spring')
				THEN 'Spring Matt Kit'
			WHEN [CPD].[AFI Sales Category] IN ('Bedding Memory Foam','Sig. Bedding Memory Foam')
				THEN 'Foam Matt Kit'
			ELSE 'Matt Kit'
		END AS [Mattress Type]
  FROM [Manufacturing_DW].[DimBOMDetails] AS BOM
  LEFT JOIN [SupplyChain_DW].[DimCurrentProductDetails] AS CPD
    ON [BOM].[BOM End Item Number] = [CPD].[Item SKU]
  WHERE[BOM]. [BOM Comp Item Number] LIKE 'M_____UN' --('M5UN','M72731UN','M40641UN','M42631UN')
    AND [BOM].[BOM Comp Item Number] <> [BOM].[BOM End Item Number]
    
                      ", CreateNavigationProperties=false])
in
    Source