SELECT  
	 a.[employee_id]
     ,a.[wh_id]
	 ,cast(a.[end_tran_date] as date) end_trans_date
     ,sum([tran_qty]) as total
  FROM [PowerBI_Distribution].[TranLog]a
  left join [PowerBI_Distribution].[ItemMaster] b
  on a.[item_number]=b.[item_number]
  and a.[wh_id]=b.[wh_id]
  where cast(a.end_tran_date as date) >=dateadd(day,-30,getdate())
  and b.[commodity_code] like 'z%'
  and b.[commodity_code] not like '%k'
  and a.[description] not like '%shtl%'
  and a.[tran_type] in ('303','305','331','301')
  and a.[wh_id] in ('335')
  group by
  a.[employee_id]
  ,a.[tran_type]
  ,a.[wh_id]
  ,a.[end_tran_date]
  order by
  a.[wh_id]
  ,a.[tran_type]
  ,a.[end_tran_date] DESC
  ,a.[employee_id]desc