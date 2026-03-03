SELECT
 f.[Date]
,f.wh_id
,f.[Item Type]
,count(distinct [control_number]) as [Unloaded Containers]

from(
SELECT
CAST(a.end_tran_date AS DATE) [Date]
,a.item_number
,a.wh_id
,a.tran_qty
,b.pick_put_id
,a.[control_number]
,a.AFIFinanceDivision
,CASE WHEN b.pick_put_id LIKE '%UPH%' THEN 'UPH' else 'Casegoods' END [Item Type]
,CASE WHEN b.pick_put_id LIKE '%UPH%' THEN a.tran_qty ELSE 0 END [UPH]
,CASE WHEN b.pick_put_id NOT LIKE '%UPH%' THEN a.tran_qty ELSE 0 END [Casegoods]

 


FROM(
SELECT  [tran_type]
      ,a.[description]
      ,[start_tran_date]
      ,[start_tran_time]
      ,[end_tran_date]
      ,[end_tran_time]
      ,[employee_id]
      ,[control_number]
      ,[line_number]
      ,[control_number_2]
      ,[outside_id]
      ,a.[wh_id]
      ,[location_id]
      ,[hu_id]
      ,[num_items]
      ,a.[item_number]
      ,[lot_number]
      ,a.[uom]
      ,[tran_qty]
      ,[wh_id_2]
      ,[location_id_2]
      ,[verify_status]
      ,[employee_id_2]
      ,[routing_code]
      ,[hu_id_2]
      ,[return_disposition]
      ,[elapsed_time]
      ,[log_id]
      ,[group_id]
      ,[afi_package_rate]
	  ,c.AFIFinanceDivision
  FROM [PowerBI_Distribution].[TranLog] a
  LEFT JOIN [PowerBI_Enterprise].[DimItemMaster] c 
  ON a.item_number=c.ItemSKU
  WHERE CAST(a.end_tran_date AS DATE) BETWEEN DATEADD(day,-200,GETDATE()) AND GETDATE()
  AND a.tran_type='151'
 ) a
LEFT JOIN 
  (SELECT DISTINCT 
  a.item_number,
  a.wh_id,
  a.pick_put_id,
  a.commodity_code
 FROM  [PowerBI_Distribution].[ItemMaster] a
 WHERE a.commodity_code LIKE 'Z%'
 AND a.commodity_code NOT LIKE '%K'
 ) b
  ON a.item_number=b.item_number
  AND a.wh_id=b.wh_id

  ) f

  group by
     f.[Date]
    ,f.wh_id
    ,f.[Item Type]