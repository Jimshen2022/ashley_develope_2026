
SELECT 
       [Item Sku]
      ,[Warehouse]
      ,SUM([Open Order Quantity]) as [Open Order Quantity]
      ,SUM([Back Order Quantity]) as [Back Order Quantity]
	  ,CASE WHEN [DD].[FiscalDateIndicator] <1
	  THEN 1
	  ELSE [DD].[FiscalDateIndicator]
	  END AS [FiscalDateIndicator]
	  ,GETDATE() as [Last Refresh]

  FROM [AFISales_DW].[FactOpenOrders] OO

  INNER JOIN [Enterprise_DW].[DimDate] DD

  ON [OO].[Current Load Date] = [DD].[DateID]
  AND [DD].[FiscalDateIndicator] <15

  WHERE [Inventory Allocated Flag] <> '0'

  GROUP BY 

       [Item Sku]
      ,[Warehouse]
	  ,CASE WHEN [DD].[FiscalDateIndicator] <1
	  THEN 1
	  ELSE [DD].[FiscalDateIndicator]
	  END


ORDER BY [Item Sku], [FiscalDateIndicator] ASC
	  