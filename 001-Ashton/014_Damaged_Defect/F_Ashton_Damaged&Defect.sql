
-- Aug.16.2024 Updated Ashton damaged and defect products BI report by new process -- JimShen
-- To get serial number received into Ashton begin date from HJ transactions
WITH itm as (
    SELECT distinct b.ITNBR as item_number,b.PICKPUT as pick_put_id,
	case when b.PICKPUT = 'UPH' then 'UPH'
	else 'CG' end as product_category
	FROM MasterData_ItemMaster_AFI.ITBEXT b
    WHERE b.HOUSE IN ('335')
),

r1 AS (
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
	AND t1.location_id_2 IN ('DM001AA1','NG001CK3','NG001CG3','NG001UP3','NG001VD3') 
GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20)), t1.location_id_2
    ),

	-- To get serial number received into location begin date from HJ transactions
    r3 AS (
    SELECT t1.wh_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.location_id_2
	, MIN(t1.start_tran_date) AS received_into_DM_date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2023-01-01' AND t1.lot_number is not null and len(t1.lot_number)>5
	AND t1.location_id_2 IN ('DM001AA1') 
GROUP BY t1.wh_id, t1.item_number, CAST(t1.lot_number as VARCHAR(20)), t1.location_id_2
    )
----------- Main ------------------------------------------------------------------
SELECT t1.wh_id
	, t1.serial_number
	, t1.item_number
	, t1.po_number
	, t1.location_id
	, CASE
			WHEN t1.location_id = 'DM001AA1' THEN '(1) Damaged Item Entry Location - PendingInspection'
			WHEN t1.location_id = 'NG001CK3' THEN '(2) Repair Materials Required - CartonsDamaged'
			WHEN t1.location_id = 'NG001CG3' THEN '(3) Vendor Repair Required - ProductsDamaged'
			WHEN t1.location_id = 'NG001UP3' THEN '(3) Vendor Repair Required - ProductsDamaged'
			WHEN t1.location_id = 'NG001VD3' THEN '(4) Returned To Vendor For Repair'
			ELSE 'Check' END AS Location_Meaning
    , case when itm.product_category is null then 
										case when left(t1.item_number,1) like '[U,1-9]%' THEN 'UPH' else 'CG' end
										else itm.product_category end as Item_Type
    , r1.received_into_ashton_date
    , r2.received_into_loc_date
	, CASE 
			WHEN r3.received_into_DM_date IS NULL 
				THEN DATEADD(day, -1, r2.received_into_loc_date)
			WHEN r3.received_into_DM_date < r2.received_into_loc_date  
				THEN DATEADD(day, -1, r2.received_into_loc_date)
			ELSE r3.received_into_DM_date 
			END AS received_into_dm_date

FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
    LEFT JOIN (SELECT * FROM r1) AS r1 ON t1.wh_id = r1.wh_id AND t1.item_number = r1.item_number AND t1.serial_number = r1.SN
    LEFT JOIN (SELECT * FROM r2) AS r2 ON t1.wh_id = r2.wh_id AND t1.item_number = r2.item_number AND t1.serial_number = r2.SN AND t1.location_id = r2.location_id_2
    LEFT JOIN (SELECT * FROM r3) AS r3 ON t1.wh_id = r3.wh_id AND t1.item_number = r3.item_number AND t1.serial_number = r3.SN 
	LEFT JOIN itm ON t1.item_number = itm.item_number
WHERE  t1.wh_id  IN ('335') 
	AND T1.location_id IN ('DM001AA1','NG001CK3','NG001CG3','NG001UP3','NG001VD3') 
	AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S') 