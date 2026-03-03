
SELECT 	t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date
	, CAST(t1.start_tran_time AS TIME(0)) as star_tran_time
	, t1.end_tran_date 
	, CAST(t1.end_tran_time AS TIME(0)) as end_tran_time
	, t1.employee_id
	, t1.control_number
	, t1.line_number
	, t1.control_number_2 as reference
	, t1.hu_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.uom
	, t1.tran_qty
	, t1.location_id AS 'from Location'
	, t1.location_id_2 AS 'To Location'
	, t1.employee_id_2
    , CASE
        WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN t1.item_number LIKE '100-%' THEN 'CG'
        WHEN SUBSTR(TRIM(t1.item_number),1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
        WHEN SUBSTR(TRIM(t1.item_number),1,1) IN ('A') AND t2.B2Z95S >= 0.3 THEN 'CG'
        WHEN SUBSTR(TRIM(t1.item_number),1,1) IN ('A','L','R','Q') THEN 'ACCESSORY'
        WHEN LENGTH(TRIM(t1.item_number)) = 6 AND SUBSTR(TRIM(t1.item_number),1,1) ='M' THEN 'ACCESSORY'
    ELSE 'CG' END AS Product

FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335','31','33','35','51') AND t1.start_tran_date >= '2024-01-01'
WHERE t1.start_tran_date > '2024-01-01'
--AND t1.lot_number IN ('503947312670')
-- AND t1.reference IN ('P2D8N12')
ORDER BY t1.lot_number,t1.start_tran_date,t1.start_tran_time


/*

SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('35','33','31')
AND t1.location_id like 'IE%'


--AND t1.item_number IN ('T468-3')
--AND t1.tran_type IN ('151','183','161','165','158','855','001','202')

SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
	, t1.item_number
	, t1.description
	, t2.ITCLS as Item_Class
	, (CASE 
		WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE 'CG' END) AS Product
    , t1.tran_qty
	, t1.lot_number
*/




--LEFT JOIN (SELECT a.ITNBR, a.ITCLS FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID = '335') AS t2 ON t1.item_number = t2.ITNBR
--('3140338',
--AND t1.tran_type IN ('161','855') 
--AND t1.item_number IN 
--('3140338',
--'3370638',
--'5950535',
--'B751-31',
--'D760-45')
-- AND t1.lot_number IN
--('503944914074','503945798996','503945798997','503945873438','503945873439','503945977407','503945977408','503945977409','503945977412','503945977413','503945977422','503946122710','503946122712','503946122726','503946298626','503946298627','503946298628','503946298629','503946298630','503946298635','503946372943','503946437916','503946437918','503946437919','503946932436','503946932444','503946932445','503947191443','503947191445','503947191446','503947191447','503947191448','503947191451','503947191453','503947191454','503947191456','503947191457','503947191458','503947191459','503947191460','503947191461','503947191462','503947191463','503947194690','503947194691','503947194696','503947194712','503947194713','503947194714','503947194715','503947194716','503947194717','503947194720','503947194721','503947194723','503947194724','503947194725','503947362851','503947362852','503947362853','503947362854','503947379310','503947379311','503947379312','503947379313','503947379314','503947379315','503947379316','503947379317','503947379318','503947379319','503947379320','503947379321','503947379322','503947379325','503947379326','503947379328','503947379329','503947379330','503947379331','503947379332','503947379333','503947379334','503947379335','503947379336','503947379337','503947379338','503947379339','503947379340','503947379341','503947379342','503947379343','503947379344','503947379345','503947381592','503947381593','503947381594','503947381595','503947381596','503947381597','503947381598','503947381601','503947381602','503947381603','503947381604','503947381605','503947381606','503947381607','503947381608','503947381609','503947381610','503947381611','503947381612','503947381613','503947381614')


/*
SELECT t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date
	, CAST(t1.start_tran_time AS TIME(0)) as star_tran_time
	, CAST(t1.end_tran_time AS TIME(0)) as end_tran_time
	, t1.control_number
	, t1.line_number
	, t1.control_number_2 as reference
	, t1.location_id AS 'from '
	, t1.item_number
	, t1.tran_qty
	, t1.location_id_2
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2024-08-15' 
ORDER BY t1.lot_number,t1.start_tran_date,t1.start_tran_time
*/

/*
-- SN be received into ashton date
SELECT t1.wh_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.item_number + '_' + CAST(t1.lot_number as VARCHAR(20)) AS item_sn
	, MIN(t1.start_tran_date) AS received_date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20)), t1.item_number + '_' + CAST(t1.lot_number as VARCHAR(20))


-- SN be received into ashton racking location date
SELECT t1.wh_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.location_id
	, t1.item_number + '_' + CAST(t1.lot_number as VARCHAR(20))+ '_' + t1.location_id  AS item_sn
	, MIN(t1.start_tran_date) AS received_date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20)),t1.location_id, t1.item_number + '_' + CAST(t1.lot_number as VARCHAR(20))+ '_' + t1.location_id



SELECT t1.wh_id
	, t1.serial_number
	, t1.item_number
	, t1.po_number
	, t1.location_id
	, CASE
			WHEN t1.location_id = 'DM001AA1' THEN 'Ashton Damaged&Defect Main location'
			WHEN t1.location_id = 'NG001MT1' THEN 'Checking Mattresses(Over 150 days)'
			WHEN t1.location_id = 'VD001AA1' THEN 'Inbound Vendor Damaged'
			WHEN t1.location_id = 'EX001AA1' THEN 'Vendor Over Shipment'
			WHEN t1.location_id = 'SH001AA1' THEN 'Vendor Short Shipment'
			WHEN t1.location_id = 'NG001CK3' THEN 'Checking Pieces(Lack repair materials)'
			WHEN t1.location_id = 'NG001CG3' THEN 'Whse CaseGoods Damaged'
			WHEN t1.location_id = 'NG001UP3' THEN 'Whse UPH Damaged'
			WHEN t1.location_id = 'NG001VD3' THEN 'Send back to Vendor for fixing'
			WHEN t1.location_id = 'DR001AA1' THEN 'Shipping Supervisor Unpick/Unload'
			WHEN t1.location_id = 'DR001AB1' THEN 'Shipping Supervisor Unpick/Unload'
			ELSE 'Check' END AS Location_Meaning
	, t1.received_date
	, t1.ship_date
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id  IN ('335') 
	AND T1.location_id IN ('DM001AA1','NG001MT1','VD001AA1','EX001AA1','SH001AA1','NG001CK3','NG001CG3','NG001UP3','NG001VD3','DR001AA1','DR001AB1') 
	AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S') 


*/