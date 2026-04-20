Select
      t.[start_tran_date]
      ,t.[wh_id]
	  ,sum(t.[tran_qty]) AS [BO Qty]
	  ,t.[return_disposition2] AS [BO Code]
	  ,case when t.[return_disposition2] IN ('10','12','18','23','47','52','53','56','57','58') then 'Uncontrollable'
	        when t.[return_disposition2] is null then 'Unknown' else 'Controllable' end [reason code assignment]
From (
SELECT [tran_type]
      ,[description]
      ,[start_tran_date]
      ,[wh_id]
      ,[item_number]
      ,[tran_qty]
      ,[location_id_2]
      ,[return_disposition]
	  ,case when [return_disposition] is null then [location_id_2] else [return_disposition] end as [return_disposition2]
  FROM [PowerBI_Distribution].[TranLog]
  where tran_type='340'
  and CAST([start_tran_date]  AS DATE) BETWEEN DATEADD(day,-200,GETDATE()) AND GETDATE()
  and [wh_id] in ('1','15','17','28','42','5','ECR','335')
  )t
  where [return_disposition2] <>'21'
  and [return_disposition2] <>'62'
  group by
       t.[wh_id]
      ,t.[start_tran_date]
      ,t.[return_disposition2]