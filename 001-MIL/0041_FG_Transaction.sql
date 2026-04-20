SELECT   *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN (SELECT a.ITNBR, a.ITCLS FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID = '51') AS t2 ON t1.item_number = t2.ITNBR
WHERE t1.wh_id IN ('51') and t1.lot_number in ('501604431961')
ORDER BY t1.start_tran_date, t1.start_tran_time
-- and t1.item_number in ('EW2270-268')
--AND t1.start_tran_date > '2021-01-01' 
--AND t1.tran_type IN ('151','183','951','347') 
--ORDER BY CAST(t1.[start_tran_date] AS DATE) DESC