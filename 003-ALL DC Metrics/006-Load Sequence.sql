SELECT t.wh_id
      ,CONCAT(CAST(t.[start_tran_date] AS DATE), ' ', CAST(t.[start_tran_time] AS TIME)) as Date_Time
      ,d.[Last_date_of_fiscal_week] as [W/E]
      ,t.[employee_id]
      ,left(t.[control_number],7) as Trip
      ,right(t.[control_number],2) as 'Drop'
      --,max(t.[control_number]) as 'Max Drop'
      --,max(e.[number_of_drops]) as 'Total_Drops'
      ,max(try_cast(right(t.[control_number],2) AS int)) OVER (partition BY left(t.[control_number],7), d.[Last_date_of_fiscal_week])  as 'Total_Drops'
  FROM [PowerBI_Distribution].[TranLog] t
  left join [Powerbi_enterprise].[DimDate] d on cast (t.[start_tran_date] as date)= cast (d.[date_id] as date)
  --left join [Distribution_Warehouse_Wholesale].[LoadMaster] e on t.wh_id = e.wh_id and t.control_number_2 = e.load_id
  where t.wh_id IN ('5','1','15','17','28','42','ECR')
       and description = 'Loading - Billable (put)'
       and t.[start_tran_date] BETWEEN DATEADD(week,-6,GETDATE()) AND GETDATE()
       --and datepart(iso_week,dateadd(day, 1, t.[start_tran_date])) >= datepart(iso_week,dateadd(day, 1, Getdate())) - 6
	   and t.control_number <> 'Null'
	   and t.control_number like '%-%'
Group by 
t.wh_id
, CONCAT(CAST(t.[start_tran_date] AS DATE), ' ', CAST(t.[start_tran_time] AS TIME)) 
,d.[Last_date_of_fiscal_week]
,t.[employee_id]
,t.[control_number]