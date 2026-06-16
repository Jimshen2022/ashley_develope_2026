let
    Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [Query="SELECT  #(lf)#(tab) a.[employee_id]#(lf)     ,a.[wh_id]#(lf)#(tab) ,cast(a.[end_tran_date] as date) end_trans_date#(lf)     ,sum([tran_qty]) as total#(lf)  FROM [PowerBI_Distribution].[TranLog]a#(lf)  left join [PowerBI_Distribution].[ItemMaster] b#(lf)  on a.[item_number]=b.[item_number]#(lf)  and a.[wh_id]=b.[wh_id]#(lf)  where cast(a.end_tran_date as date) >=dateadd(day,-30,getdate())#(lf)  and b.[commodity_code] like 'z%'#(lf)  and b.[commodity_code] not like '%k'#(lf)  and a.[description] not like '%shtl%'#(lf)  and a.[tran_type] in ('303','305','331','301')#(lf)  and a.[wh_id] in ('335')#(lf)  group by#(lf)  a.[employee_id]#(lf)  ,a.[tran_type]#(lf)  ,a.[wh_id]#(lf)  ,a.[end_tran_date]#(lf)  order by#(lf)  a.[wh_id]#(lf)  ,a.[tran_type]#(lf)  ,a.[end_tran_date] DESC#(lf)  ,a.[employee_id]desc", CreateNavigationProperties=false, CommandTimeout=#duration(0, 2, 40, 0)]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"end_trans_date", type date}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "Custom", each [wh_id]&"-"&[employee_id]),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom",{"Custom"})
in
    #"Removed Columns"


/*
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

  */