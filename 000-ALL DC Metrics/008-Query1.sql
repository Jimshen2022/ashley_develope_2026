/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
	   d.[Fiscal Year] as Year
	  ,d.[Fiscal Week Ended] as [W/E]
	  ,d.[Fiscal Week] as Week
	  ,d.[Week Day] as Day
	  ,d.[WeekDayID] as Day_Nbr
	  -- datepart(iso_week,dateadd(day, +1, [work_day])) as Week
	  --,datename(dw,[work_day]) as Day
	  --,datepart(dw,[work_day]) as Day_Nbr
	  ,b.[EmployeeName]
	  ,a.[group_nbr]
	  ,a.[department]
      ,a.[work_shift_id]
	  ,a.supervisor_nbr
	  ,b.hiredate
	  ,datediff(day, b.hiredate, CONVERT(VARCHAR(10), getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time', 111)) as DOS
	  ,sum([actual_elapsed_time]) as DT
      ,sum([total_sam]) as SAM
	  ,c.[processname]
  
  FROM [Distribution_Warehouse_Wholesale].[ProcessReport] a
  left join [Highjump_DW].[DimEmployee] b on a.employee_id = b.EmployeeID and a.wh_id = b.warehouseid
  left join [Highjump_DW].[DimProcess] c on a.[process_id] = c.[ProcessId]
  left join [Distribution_DW].[DimDateFile] d on cast (a.[work_day] as date)= cast (d.[Transaction Date] as date)
  
  where wh_id = '28' 
  and work_day >= '2019-12-29'
  --and datepart(iso_week,dateadd(day, +1, [work_day])) <= datepart(iso_week,dateadd(day, +1, Getdate())) - 4
  and labor_type = 'DIR' 
  and a.department = '4005'
  --and work_day >= CONVERT(VARCHAR(10), getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time', 111)
  
  group by datepart(iso_week,dateadd(day, +1, [work_day])),datename(dw,[work_day]), datepart(dw,[work_day]) , b.employeename, c.[processname], a.work_shift_id, a.[group_nbr], a.[department], b.hiredate, a.supervisor_nbr,
  				  d.[Fiscal Week]
				 ,d.[Week Day]
				 ,d.[WeekDayID]
				 ,d.[Fiscal Week Ended]
				 ,d.[Fiscal Year]