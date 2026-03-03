-- Sep.1i.2024 Updated MIL and WNK damaged and defect products BI report by new process -- JimShen
-- To get serial number received into whse begin date from HJ transactions
WITH r1 AS (
    SELECT t1.wh_id
        , t1.item_number
        , CAST(t1.lot_number as VARCHAR(20)) AS SN
        , MIN(t1.start_tran_date) AS received_into_whse_date
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id IN ('51','35','31','33','34') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
    GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20))
    ),
-- To get serial number received into location begin date from HJ transactions
    r2 AS (
    SELECT t1.wh_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.location_id_2
	, MIN(t1.start_tran_date) AS received_into_loc_date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('51','35','31','33','34') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
	AND t1.location_id_2 IN ('NG001UP1','NG001DC1','NG01OPWN3','NG001EX1','NG001IN1','NG001EX1','NG001IN1','NG001UP1',
	                         'SA4061UP1','SA4061UP1','QA001UP1','QA001OBQ',   -- Above is Wanek NG locations
	                        'DM001AA1','QC001AA2','HUY001','NG001CG1','NG001SC1','PL001AA1')  -- FOR MIL NG LOCATIONS
GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20)), t1.location_id_2
    )
----------- Main ------------------------------------------------------------------
SELECT t1.wh_id
	, t1.serial_number
	, t1.item_number
	, t1.po_number
	, t1.location_id
	, CASE
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001UP1' THEN 'WH UPH Damage'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001DC1' THEN 'WH UPH Damage'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG01OPWN3' THEN 'Orphan position should be checked before processing'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001EX1' THEN 'Defective goods from the manufacturing department'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001IN1' THEN 'Defective goods caused by WH'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001EX1' THEN 'Defective goods from the manufacturing department'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001IN1' THEN 'Defective goods caused by WH'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001UP1' THEN 'WH UPH Damage'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'SA4061UP1' THEN 'Move to Showroom'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'SA4061UP1' THEN 'Move to Showroom'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'QA001UP1' THEN 'Move to OBQ - QC - TAT CHECK'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA001UP1' THEN 'Move to OBQ - QC - TAT CHECK'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA001OBQ' THEN 'Move to B1 ram OBQ'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA004OBQ' THEN 'Move to B4 ram OBQ'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'DM001AA1' THEN 'Damaged&Defect Main location'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'QC001AA2' THEN 'Quality issue'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'HUY001' THEN 'Quality issue and cannot rework'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'NG001CG1' THEN 'Damaged by WH'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'NG001SC1' THEN 'Waiting for approval to Scrap'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'PL001AA1' THEN 'OBQ'
			ELSE 'Check' END AS Location_Meaning
	, CASE
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001UP1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001DC1' THEN 'Damaged & Defect'
				WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG01OPWN3' THEN 'Inventory adjustment'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001EX1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001IN1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001EX1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001IN1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001UP1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'SA4061UP1' THEN 'Showroom'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'SA4061UP1' THEN 'Showroom'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'QA001UP1' THEN 'OBQ'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA001UP1' THEN 'OBQ'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA001OBQ' THEN 'OBQ'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA004OBQ' THEN 'OBQ'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'DM001AA1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'QC001AA2' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'HUY001' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'NG001CG1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'NG001SC1' THEN 'Damaged & Defect'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'PL001AA1' THEN 'OBQ'
			ELSE 'Check' END AS Location_Category
	, CASE
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001UP1' THEN 'WN3'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001DC1' THEN 'BLOCK 13'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG01OPWN3' THEN 'WN3'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001EX1' THEN 'WN3'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'NG001IN1' THEN 'WN3'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001EX1' THEN 'WN2'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001IN1' THEN 'WN2'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'NG001UP1' THEN 'WN2'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'SA4061UP1' THEN 'WN2'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'SA4061UP1' THEN 'WN3'
			WHEN t1.wh_id IN ('33') AND t1.location_id = 'QA001UP1' THEN 'WN2'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA001UP1' THEN 'WN3'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA001OBQ' THEN 'WN3'
			WHEN t1.wh_id IN ('35') AND t1.location_id = 'QA004OBQ' THEN 'WN3'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'DM001AA1' THEN 'MIL'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'QC001AA2' THEN 'MIL'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'HUY001' THEN 'MIL'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'NG001CG1' THEN 'MIL'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'NG001SC1' THEN 'MIL'
			WHEN t1.wh_id IN ('51') AND t1.location_id = 'PL001AA1' THEN 'MIL'
			ELSE 'Check' END AS Sites
    , r1.received_into_whse_date
    , r2.received_into_loc_date
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS t1
    LEFT JOIN (SELECT * FROM r1) AS r1 ON t1.wh_id = r1.wh_id AND t1.item_number = r1.item_number AND t1.serial_number = r1.SN
    LEFT JOIN (SELECT * FROM r2) AS r2 ON t1.wh_id = r2.wh_id AND t1.item_number = r2.item_number AND t1.serial_number = r2.SN AND t1.location_id = r2.location_id_2
WHERE  t1.wh_id  IN ('51','35','31','33','34')
	AND T1.location_id IN ('NG001UP1','NG001DC1','NG001EX1','NG001IN1','NG001EX1','NG001IN1','NG001UP1',
	                         'SA4061UP1','SA4061UP1','QA001UP1','QA001OBQ','QA001UP1', -- Wanek locations
	                       'DM001AA1','QC001AA2','HUY001','NG001CG1','NG001SC1','PL001AA1')    -- MIL locations
	AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S')
