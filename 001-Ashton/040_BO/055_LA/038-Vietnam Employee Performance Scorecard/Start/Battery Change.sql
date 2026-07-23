SELECT [tran_type]
      ,[description]
      ,[start_tran_date]
      ,[start_tran_time]
      ,[end_tran_date]
      ,[end_tran_time]
      ,[employee_id]
      ,[control_number]
      ,[control_number_2]
      ,[wh_id]
      ,[location_id]
      ,[elapsed_time]
	  ,CAST(DATEDIFF(SECOND,start_tran_time, end_tran_time) / 60.00 AS FLOAT) AS spent_time_minutes
  FROM [PowerBI_Distribution].[TranLog]
  where [wh_id] IN ('35','335')
  and [tran_type]='500'
  order by start_tran_date asc