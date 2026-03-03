SELECT  [tran_type]
      ,[description]
      ,Cast([exception_date] as date) exception_date
      ,[exception_time]
      ,[employee_id]
      ,[wh_id]
      ,[suggested_value]
      ,[entered_value]
      ,[location_id]
      ,[item_number]
      ,[lot_number]
      ,[quantity]
      ,[hu_id]
      ,[load_id]
      ,[control_number]
      ,[line_number]
	  ,case when wh_id = '42' then '42 - Spanaway'
	   when wh_id = '28' then '28 - Mesquite'
	   when wh_id = '5' then '5 - Redlands'
	   when wh_id = '17' then '17 - Advance'
	   when wh_id = '15' then '15 - Leesport'
	   when wh_id = 'ECR' then 'ECR - Ecru'
	   when wh_id = '1' then '1 - Arcadia'
	   when wh_id = '335' then '335 - Ashton'
	   else 'Other WHSE' end as [Market]
  FROM [PowerBI_Distribution].[ExceptionLog]
  where tran_type IN ('112F2','115f2','152f2','202f2','252f2','254f2','262f2','303f7', '301f7', '305f7' ,'311a','313a', '315a', 'dcf1','dcf6','dcf8','SLRP','254f9','202f9', 'dcf3')
  and [wh_id] in ('335')
  and cast([exception_date] as date) BETWEEN DATEADD(day,-60,GETDATE()) AND GETDATE()