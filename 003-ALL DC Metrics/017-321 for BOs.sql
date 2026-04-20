SELECT [wh_id]
      ,cast([start_tran_date] as date)[start_tran_date]
       ,Sum([tran_qty]) as Qty
 FROM [PowerBI_Distribution].[TranLog]
  where tran_type IN ('321','621')
  and CAST([start_tran_date]  AS DATE) BETWEEN DATEADD(day,-200,GETDATE()) AND GETDATE()
  and [wh_id] in ('1','15','17','28','42','5','ECR','335')
  group by
	   [wh_id]
      ,[start_tran_date]