SELECT [WhId]
      ,SUM(CASE WHEN [product] IN ('Upholstery','Non_Upholstery') AND [priority]='A' THEN 1 ELSE 0 END) AS Count_Priority_As
	  ,SUM(CASE WHEN [product] IN ('Upholstery','Non_Upholstery') AND [priority]='B' THEN 1 ELSE 0 END) AS Count_Priority_Bs
	  ,SUM(CASE WHEN [product] = 'Upholstery' THEN 1 ELSE 0 END) AS Count_UPH_Containers
	  ,SUM(CASE WHEN [product] = 'Non_Upholstery' THEN 1 ELSE 0 END) AS Count_CG_Containers
	  ,SUM(CASE WHEN [product] IN ('Upholstery','Non_Upholstery') THEN 1 ELSE 0 END) AS Yard_Inventory
FROM [PowerBI_ADS].[Schedule_Equipment_Unload]
WHERE whid IN ('1','15','17','ECR','42','28','5','335')
AND flag = 'backorder'
AND product IN ('Non_Upholstery','Upholstery')
GROUP BY whid