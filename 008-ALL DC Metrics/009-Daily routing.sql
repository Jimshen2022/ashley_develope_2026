Select --datepart(iso_week,dateadd(day, 1, [dispatch_date])) as [Week]
	  --,(datename(dw,[dispatch_date])) as [Day]
	  --,(datepart(dw,[dispatch_date])) as [Day_Nbr]
	  c.[wh_id]
	  ,c.[load_id]
	  ,c.[dispatch_date]
	  ,c.[dispatch_time]
	  ,c.[trip_type_id]
	  ,c.[trip_create_date]
      ,c.[trip_create_time]
From(
SELECT 
	  a.[wh_id]
      ,[load_id]


      ,max(convert(date,[dispatch_date])) as dispatch_date
      ,max(convert(time,[dispatch_time])) as dispatch_time
      ,[trip_type_id]

      ,convert(date,[trip_create_date]) as trip_create_date
      ,convert(time,[trip_create_time]) as trip_create_time
  FROM [PowerBI_ADS].[LoadMaster] a
  --LEFT JOIN [PowerBI_ADS].[Carrier] c ON a.carrier_id = c.carrier_id and a.wh_id = c.wh_id
  where right(a.[load_id],2) = '00'
  and a.wh_id  IN ('5', '42', '17', '15', '1', 'ECR', '28')
  and cast([dispatch_date] as date) between dateadd(week, -2, getdate()) and getdate()
  --and datepart(iso_week,dateadd(day, +1, [dispatch_date])) >= datepart(iso_week,dateadd(day, +1, Getdate())) - 2
	--and CONVERT(DATETIME, CONVERT(CHAR(8), [trip_create_date], 112) + ' ' + CONVERT(CHAR(8), [trip_create_date], 108)) >= cast(DATEDIFF(dd, 8, GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time') as datetime) + cast('03:00:00' as datetime)
	--and CONVERT(DATETIME, CONVERT(CHAR(8), [trip_create_date], 112) + ' ' + CONVERT(CHAR(8), [trip_create_date], 108)) <= cast(DATEDIFF(dd, 0, GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time') as datetime) + cast('03:00:00' as datetime)
	group by
	  a.[wh_id]
	  ,[load_id]
	  ,[trip_type_id]
	  ,[trip_create_date]
      ,[trip_create_time]
	)c
	group by
       --datepart(iso_week,dateadd(day, 1, [dispatch_date]))
	  --,(datename(dw,[dispatch_date])) 
	  --,(datepart(dw,[dispatch_date]))
	  c.[wh_id]
	  ,c.[load_id]
	  ,c.[dispatch_date]
	  ,c.[dispatch_time]
	  ,c.[trip_type_id]
	  ,c.[trip_create_date]
      ,c.[trip_create_time]