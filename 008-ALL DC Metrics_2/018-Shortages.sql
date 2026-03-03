SELECT 
      [Transaction Date]
      ,[Warehouse Code]
      ,Sum([Short Ship Quantity]) AS [Short Ship Qty]
      ,Sum([Short Ship Amount]) AS [Short Ship Amount]
from [PowerBI_Distribution].[FactQualityCosts]
where [Defect Code]='XP'
and cast([Transaction Date] as date) BETWEEN DATEADD(day,-200,GETDATE()) AND GETDATE()
and [warehouse code] in ('1','15','17','28','5','42','ECR','335')
group by
      [Transaction Date]
      ,[Warehouse Code]