-- Aug.16.2024 Updated Ashton damaged and defect products BI report by new process -- JimShen
-- To get serial number received into Ashton begin date from HJ transactions
WITH r1 AS (
    SELECT t1.wh_id
        , t1.item_number
        , CAST(t1.lot_number as VARCHAR(20)) AS SN
        , MIN(t1.start_tran_date) AS received_into_ashton_date
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
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
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
	AND t1.location_id_2 IN ('DM001AA1','NG001MT1','VD001AA1','EX001AA1','EX001AA2','SH001AA1','NG001CK3','NG001CG3','NG001UP3','NG001VD3') 
GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20)), t1.location_id_2
    )
----------- Main ------------------------------------------------------------------
SELECT t1.wh_id
	, t1.serial_number
	, t1.item_number
	, t1.po_number
	, t1.location_id
	, CASE
			WHEN t1.location_id = 'DM001AA1' THEN 'Damaged&Defect Main location'
			WHEN t1.location_id = 'NG001MT1' THEN 'Checking Mattresses(Over 150 days)'
			WHEN t1.location_id = 'VD001AA1' THEN 'Inbound Vendor Damaged'
			WHEN t1.location_id = 'EX001AA1' THEN 'Vendor Over Shipment'
			WHEN t1.location_id = 'EX001AA2' THEN 'Extra Due to Operation Issue'
			WHEN t1.location_id = 'SH001AA1' THEN 'Vendor Short Shipment'
			WHEN t1.location_id = 'NG001CK3' THEN 'Checking Pieces(Lack repair materials)'
			WHEN t1.location_id = 'NG001CG3' THEN 'Whse CaseGoods Damaged'
			WHEN t1.location_id = 'NG001UP3' THEN 'Whse UPH Damaged'
			WHEN t1.location_id = 'NG001VD3' THEN 'Send back to Vendor for fixing'
			ELSE 'Check' END AS Location_Meaning
    , CASE 
            WHEN substring(t1.item_number,1,4) LIKE '100-' THEN 'CG' 
            WHEN substring(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') then 'UPH'
            WHEN substring(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','R','T','W','Z') then 'CG'
            ELSE 'Check' END AS Item_Type 
    , r1.received_into_ashton_date
    , r2.received_into_loc_date
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
    LEFT JOIN (SELECT * FROM r1) AS r1 ON t1.wh_id = r1.wh_id AND t1.item_number = r1.item_number AND t1.serial_number = r1.SN
    LEFT JOIN (SELECT * FROM r2) AS r2 ON t1.wh_id = r2.wh_id AND t1.item_number = r2.item_number AND t1.serial_number = r2.SN AND t1.location_id = r2.location_id_2
WHERE  t1.wh_id  IN ('335') 
	AND T1.location_id IN ('DM001AA1','NG001MT1','VD001AA1','EX001AA1','EX001AA2','SH001AA1','NG001CK3','NG001CG3','NG001UP3','NG001VD3') 
	AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S') 