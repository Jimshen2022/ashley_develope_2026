SELECT --[RANumber] AS [RA Number]
      convert(date,convert(varchar(8),[ReportDate])) AS [Report Date]
	  ,dates.[Last_date_of_fiscal_week] AS [Week Ending Date]
	  ,dates.[fiscal_week_diff] AS [Week Difference]
	  ,dates.[Fiscal_year] AS [Year]
      --,[ShipToNo] AS [Ship To No]
      --,[CustomerName] AS [Customer Name]
      --,[ItemNumber] AS [Item #]
      --,[SerialNumber] AS [Serial #]
      --,[DateShipped] AS [Date Shipped]
	  --,[EENumber] AS [EE #]
	  --,ees.[EmployeeName] AS [EE Name]
	  --,ees.[CurrentlyAssignedSupervisorName] AS [Supervisor Name]
      --,[DriverName] AS [Driver's Name]
      --,[TripNumber] AS [Trip #]
      ,[Warehouse] AS [Whse]
	  --,whse.[Warehouse Location] AS [Warehouse Name]
      --,[Comments] AS [Comments]
      --,[State]
      --,[RACode] AS [RA Code]
      ,sum([ReturnedQuantity]) AS [Returned Qty]
      --,[PriceofItem]
      --,[CSControlCode]
      ,Sum([TotalCost]) AS [FD2 Cost]
  FROM [PowerBI_ADS].[RARETNFL] fd2
  --left join [PowerBI_Distribution].[DimEmployee] ees
  --on fd2.eenumber=ees.employeenumber
  --and fd2.warehouse=ees.warehouseID
  --left join [AFISales_DW].[DimAshleyWarehouseMaster] whse
  --on fd2.warehouse=whse.[warehouse code]
  left join [PowerBI_Enterprise].[DimDate] dates
  on convert(date,convert(varchar(8),fd2.[ReportDate]))=dates.date_id
  where [racode]='FD2'
  and convert(date,convert(varchar(8),[reportdate])) BETWEEN DATEADD(year,-2,GETDATE()) AND GETDATE()
  group by 
	  convert(date,convert(varchar(8),[ReportDate]))
	  ,dates.[Last_date_of_fiscal_week] 
	  ,dates.[fiscal_week_diff]
	  ,dates.[Fiscal_year] 
      ,[Warehouse] 
	  --,whse.[Warehouse Location]
	  order by dates.[Last_date_of_fiscal_week] desc