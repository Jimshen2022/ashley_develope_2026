  SELECT [Tran Type]
      ,[Tran Descript]
      ,[EE Name]
      ,[EE Number]
      ,[Start Trans Datetime]
      ,[End Trans Datetime]
      ,[Supervisor Name]
      ,[Department]
      ,[Warehouse #]
      ,[Date]
      ,[Transaction Qty]
      ,[WorkDay] AS [work_day]
      ,[Start Tran Date] AS [start_tran_date] 
      ,[Start Tran Time] AS [start_tran_time] 
      ,[End Tran Date] AS [end_tran_date]
      ,[End Tran Time] AS [end_tran_time]
      ,[COUNT]
      ,[GapTime] AS [Gap_Time]
      ,[ElapsedTime] AS [Elapsed_Time]
      ,[WorkTypeKey]
  FROM [PowerBI_Distribution].[GapTimeReport_EmployeeDetail] AS t1
  WHERE [Warehouse #] IN ('335') AND t1.[Date] = '2024-09-17'
  --AND t1.[EE Number] IN ('50300')
  ORDER BY [end_tran_time] DESC