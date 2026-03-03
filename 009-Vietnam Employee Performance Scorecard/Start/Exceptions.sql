SELECT [tran_type]
      ,[description]
      ,[exception_date]
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
  FROM [Distribution_Warehouse_Wholesale].[ExceptionLog]
  --where [tran_type] IN ('DCF1','DCF3','DCF8','331F7','303F7','305F7')
  where [tran_type] not like '151%'
  and [tran_type] not like '341%'
  and [tran_type]<> 'ITMD'
  and [exception_date] > DATEADD(DAY,-15, GETDATE())
  and [wh_id] IN ('335','35')