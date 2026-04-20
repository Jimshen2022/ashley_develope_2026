SELECT *
from Distribution_Warehouse_Wholesale.maTranLog as t1
where t1.wh_id in ('51') and t1.item_number in ('113284')
and t1.start_tran_date > '2024-06-01' 
and t1.control_number_2 in ('PM1BW27')



SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
	, CASE 
		WHEN t1.tran_type IN ('151','183','951') THEN 'Receiving'
		ELSE 'Shipping' END AS Trx_Type
	, t1.description
	, t1.item_number
	, t2.ITCLS as Item_Class
	, (CASE 
		WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE 'CG' END) AS Product
	, CASE 
		WHEN t1.tran_type IN ('151','183','347') THEN t1.tran_qty 
		ELSE - t1.tran_qty END AS Transaction_qty

FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN (SELECT a.ITNBR, a.ITCLS FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID = '335') AS t2 ON t1.item_number = t2.ITNBR
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2021-01-01' 
AND t1.tran_type IN ('151','183','951','347') 
-- AND (CASE 
--		WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
--		WHEN SUBSTRING(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
--		ELSE 'CG' END) = 'UPH' 
ORDER BY CAST(t1.[start_tran_date] AS DATE) DESC