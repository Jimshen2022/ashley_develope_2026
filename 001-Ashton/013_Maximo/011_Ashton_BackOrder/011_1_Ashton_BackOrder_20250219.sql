-- Ashton Backorder on Feb.19.2025
SELECT [tran_type]
      ,[description]
      ,[start_tran_date]
      ,[start_tran_time]
      ,[end_tran_date]
      ,[end_tran_time]
      ,[employee_id]
      ,[control_number]
	  ,o.[customer_id]
      ,o.[cust_po_number]
	  ,o.[ship_to_name]
      ,c.[customer_id]
      ,c.[cust_po_number]
	  ,c.[ship_to_name]
      ,[line_number]
      ,[control_number_2]
      ,[outside_id]
      ,a.[wh_id]
      ,[location_id]
      ,[hu_id]
      ,[num_items]
      ,[item_number]
      ,[lot_number]
      ,[uom]
      ,[tran_qty]
      ,[wh_id_2]
      ,[location_id_2]
      ,[verify_status]
      ,[employee_id_2]
      ,[routing_code]
      ,[hu_id_2]
      ,[return_disposition]
	  ,case when [return_disposition] is null then [location_id_2] else [return_disposition] end as [return_dispostion2]
      ,[elapsed_time]
      ,[log_id]
      ,[group_id]
      ,[afi_package_rate]
      ,[Wh_id_3]

  FROM [PowerBI_Distribution].[TranLog] a
  left join [PowerBI_Distribution].[Orders] o
  on a.wh_id = o.wh_id
  and a.control_number=o.order_number
  left join [PowerBI_Distribution].[OrderCNumber] c
  on a.wh_id = c.wh_id
  and a.control_number=c.order_number
  and a.routing_code=c.c_number
  where tran_type='340'
  and CAST([start_tran_date]  AS DATE) > '2022-06-22'
  and a.[wh_id] in ('335')
  ORDER BY
       [start_tran_date]
      ,[start_tran_time]