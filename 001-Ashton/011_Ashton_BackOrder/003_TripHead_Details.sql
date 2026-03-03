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
WHERE t3.wh_id = '335' and t3.tran_type='340' and t3.start_tran_date > '2025-01-01'
GROUP BY  t3.tran_type,
		  CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
		  t3.return_disposition,
		  t3.item_number
),
bo_tp AS (
SELECT DISTINCT bo.trip_nbr from bo
),
triph AS
	(SELECT t1.BHTRP#, 
		t1.BHWHS#,
		t1.BHTRPS,
		CONCAT(TRIM(t1.BHCNTI),t1.BHCNTN) AS Container_nbr,
        CAST(BHTRP# AS VARCHAR) + '_' + CONCAT(TRIM(t1.BHCNTI),t1.BHCNTN) AS trip_ctn_string,
		t1.BHDOOR,
		t1.BHSEL1,
		t1.BHTITM,
		t1.BHTCUB,
		t1.BHTSNS,
		t1.BHCDAT,
		t1.BHLDAT,
		t1.BHLPGM
	FROM Wholesale_CODIS.BTTRIPH as t1
	WHERE t1.BHWHS# = '335' AND t1.BHTRP# IN (SELECT * FROM bo_tp)  
		AND t1.BHTRPS = 'P'
),
tripd AS
(     SELECT 
        t2.BDTRP#,
        t2.BDITM#,
        SUM(t2.BDITQT) AS BDITQT,
        SUM(t2.BDITCT) AS BDITCT,
        SUM(t2.BDITWT) AS BDITWT
    FROM Wholesale_CODIS.BTTRIPD as t2
	WHERE t2.BDTRP# IN (SELECT * FROM bo_tp) AND t2.BDCUSR like '%335%'
	GROUP BY t2.BDTRP#, t2.BDITM#
),

trx AS (
SELECT  t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        t3.
        t3.routing_code as container_nbr,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1)*1 AS VARCHAR) + '_' + t3.routing_code AS trip_ctn_string,
        sum(t3.tran_qty) as tran_qty,
        sum(t3.tran_qty * i.B2Z95S) as tran_cube            
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN i on i.ITNBR = t3.item_number
WHERE t3.wh_id = '335' and t3.tran_type='347' and t3.start_tran_date > '2025-01-01' 
	and CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT * FROM bo_tp)  
GROUP BY  t3.tran_type,
		  CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
		  t3.item_number,
          t3.routing_code,
		   CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1)*1 AS VARCHAR) + '_' + t3.routing_code
)
SELECT 
	triph.BHLDAT as Lst_Maintain_Date,
    triph.BHTRP# AS trip_number,
    triph.BHWHS# AS warehouse_number,
    triph.Container_nbr,
    triph.trip_ctn_string,
    tripd.BDITM# AS item_number,
    tripd.BDITQT AS trip_planned_qty,
    i.B2Z95S AS unit_cube,
    tripd.BDITCT AS trip_planned_cubes,
    bo.bo_reason_code,
	ISNULL(SUM(trx.tran_qty), 0) AS actual_tran_qty,
	ISNULL(SUM(trx.tran_cube), 0) AS actual_tran_cube,
	ISNULL(sum(bo.bo_tran_qty), 0) AS bo_tran_qty,
	ISNULL(sum(bo.bo_tran_cube), 0) AS bo_tran_cube

FROM triph
INNER JOIN tripd
    ON triph.BHTRP# = tripd.BDTRP#
LEFT JOIN i
    ON tripd.BDITM# = i.ITNBR
LEFT JOIN trx
    ON triph.trip_ctn_string = trx.trip_ctn_string
    AND tripd.BDITM# = trx.item_number
LEFT JOIN bo
	ON triph.BHTRP# = bo.trip_nbr
    AND tripd.BDITM# = bo.item_number
GROUP BY
    	triph.BHLDAT,
    triph.BHTRP#,
    triph.BHWHS#,
    triph.Container_nbr,
    triph.trip_ctn_string,
    tripd.BDITM#,
    tripd.BDITQT,
    i.B2Z95S,
    tripd.BDITCT,
    bo.bo_reason_code
ORDER BY triph.BHLDAT, triph.BHTRP#, tripd.BDITM#
