SELECT [work_q_id]
      ,[work_type]
      ,[description]
      ,[pick_ref_number]
      ,[priority]
      ,[item_number]
      ,[wh_id]
      ,[location_id]
      ,[from_location_id]
      ,[work_status]
      ,[employee_id]
      ,[datetime_stamp]
	  ,cast ([datetime_stamp] as date) as [tran_date]
      ,[equipment_class_id]
  FROM [Distribution_Warehouse_Wholesale].[t_work_q]
  where [work_type]='56'
  and cast ([datetime_stamp] as date)>DATEADD(DAY, -15, GETDATE())
  and [wh_id] IN ('335','35')