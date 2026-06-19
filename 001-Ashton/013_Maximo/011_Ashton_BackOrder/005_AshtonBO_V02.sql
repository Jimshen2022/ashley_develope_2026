/*
author: Ashton
date: Mar.21.2025
description: This script is used to get the trip head details for the backorder
created by Jim,Shen
*/
WITH i AS
(SELECT t0.ITNBR,
		t0.STID,
		t0.ITCLS,
		t0.B2Z95S,
		t0.ITDSC
	FROM MasterData_ItemMaster_AFI.ITMRVA as t0
	WHERE t0.STID = '335'
),
bo AS (
SELECT  t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
		t3.return_disposition as bo_reason_code,
        t3.item_number,
        sum(t3.tran_qty) as bo_tran_qty,
        sum(t3.tran_qty * i.B2Z95S) as bo_tran_cube            
FROM [PowerBI_Distribution].[TranLog] AS t3 
LEFT JOIN i on i.ITNBR = t3.item_number
WHERE t3.wh_id = '335' and t3.tran_type='340' and t3.start_tran_date > DATEADD(DAY, -360, GETDATE()) 
	and t3.item_number in ('5930113','U4380987','5930147')
GROUP BY  t3.tran_type,
		  CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
		  t3.return_disposition,
		  t3.item_number
),
bo_tp AS (
SELECT DISTINCT bo.trip_nbr from bo
),
trx AS (
SELECT  t3.start_tran_date,
		t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        t3.routing_code as container_nbr,
		t3.return_disposition,
        sum(t3.tran_qty) as tran_qty,
        sum(t3.tran_qty * i.B2Z95S) as tran_cube            
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN i on i.ITNBR = t3.item_number
WHERE t3.wh_id = '335' and t3.tran_type='347' and t3.start_tran_date > DATEADD(DAY, -400, GETDATE())
	and CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT * FROM bo_tp)  
	and t3.item_number in ('5930113','U4380987','5930147')
GROUP BY  
		t3.start_tran_date,	
		t3.tran_type,
		  CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
		  t3.item_number,
          t3.routing_code,
		  t3.return_disposition
)
SELECT 
	trx.start_tran_date,
    trx.tran_type,
    trx.trip_nbr,
    trx.item_number,
    trx.container_nbr,
	trx.return_disposition,
	trx.tran_qty + ISNULL(bo.bo_tran_qty,0)  as Trip_Planned_Qty,
    	(CASE 
		WHEN trx.item_number = 'RP ORDER' THEN trx.tran_qty * 1
		ELSE ISNULL(trx.tran_cube,0) end) + 	(CASE 
		WHEN trx.item_number = 'RP ORDER' and bo.bo_tran_qty > 0 then bo.bo_tran_qty*1 
		ELSE ISNULL(bo.bo_tran_cube,0) END)  as Trip_Planned_Cube,

    trx.tran_qty as Shipped_Qty,
	CASE 
		WHEN trx.item_number = 'RP ORDER' THEN trx.tran_qty * 1
		ELSE ISNULL(trx.tran_cube,0) END as Shipped_Cube,

    ISNULL(bo.bo_tran_qty,0) AS bo_tran_qty,
	CASE 
		WHEN trx.item_number = 'RP ORDER' and bo.bo_tran_qty > 0 then bo.bo_tran_qty*1 
		ELSE ISNULL(bo.bo_tran_cube,0) END AS bo_tran_cube

FROM trx
LEFT JOIN bo on trx.trip_nbr = bo.trip_nbr and trx.item_number = bo.item_number
ORDER BY  trx.item_number,trx.start_tran_date, trx.trip_nbr