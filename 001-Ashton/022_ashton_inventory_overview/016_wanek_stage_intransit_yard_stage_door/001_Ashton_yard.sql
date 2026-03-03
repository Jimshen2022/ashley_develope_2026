/* YARD FILES
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.t_asn as a1 WHERE a1.wh_id = '335' and a1.status in ('NEW','CHECKED IN')
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335'
SELECT  top 10 * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335'
SELECT  top 10 * FROM Distribution_Warehouse_Wholesale.Trailer  AS a4 WHERE a4.Wh_id = '335'
*/

WITH itm AS (
    SELECT a.STID, a.ITNBR, a.ITCLS, a.B2Z95S
    FROM MasterData_ItemMaster_AFI.ITMRVA AS a
    WHERE a.STID = '335'),
CTE AS (
-- 去除Trailer中 trailer同时在yard与door的状态时，产生迪卡尔集
    SELECT 
        a4.trailer_id, 
        a4.carrier_id, 
        a4.equipment_id, 
        a4.wh_id, 
        a4.entered_yard, 
        a4.location_id, 
        a5.location_name,
        COUNT(*) OVER (
            PARTITION BY a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard
        ) AS cnt,  -- 统计该组记录出现的次数
        ROW_NUMBER() OVER (
            PARTITION BY a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard
            ORDER BY 
                CASE 
                    WHEN a5.location_name LIKE 'D%' THEN 1  -- 以D开头的优先
                    ELSE 2
                END,
                a4.location_id  -- 若没有D开头的，则取location_id最小的
        ) AS rn
    FROM Distribution_Warehouse_Wholesale.Trailer AS a4
    LEFT JOIN (
        SELECT * 
        FROM Distribution_Warehouse_Wholesale.Yalocation 
        WHERE area_id = '335'
    ) AS a5 
    ON a4.location_id = a5.location_id AND a4.area_id = a5.area_id
    WHERE a4.wh_id = '335' 
        AND a4.status IN ('IN DOOR', 'IN YARD CHASSIS') 
        --AND a4.equipment_id = 'AMFU8580681'
)
SELECT t1.wh_id 
	, t1.asn_id
	, t1.asn_number
	, t1.vendor_id
	, t1.carrier_id
	, t1.expected_arrival
	, t1.shipped
	, t1.total_quantity
	, t1.total_weight
	, t1.total_volume
	, t1.equipment_id
	, t1.trailer_type_name
	, t1.status
	, t1.sent_103_flag
	, t1.sent_101_flag
	, t2.asn_detail_id
	, t2.customer_po_number
	, t2.item_number
	, t2.uom
	, t2.quantity_shipped
    , t2.quantity_received
	, t2.quantity_shipped - t2.quantity_received AS 'In_Yard_Qty'
    , t2.serial_number_start
	, t2.serial_number_end
	, t2.born_on_date
	, t2.sn_coo
	, t4.entered_yard
	, t4.location_name
	, CONCAT(t1.equipment_id, '_', t2.customer_po_number) AS equipment_po
    , 'In_Yard' as location_type
    , itm.ITCLS
    , CASE
		WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN t2.item_number = 'RP ORDER' THEN 'RP'
		WHEN SUBSTRING(TRIM(t2.item_number),1,4) IN ('100-') THEN 'CG'
		WHEN SUBSTRING(TRIM(t2.item_number),1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		WHEN SUBSTRING(TRIM(t2.item_number),1,1) IN ('A') AND itm.B2Z95S*0.028317<=0.4 THEN 'ACCESSORY'
		WHEN SUBSTRING(TRIM(t2.item_number),1,1) IN ('L','Q','R') THEN 'ACCESSORY'
		WHEN SUBSTRING(TRIM(t2.item_number),1,1) IN ('M') AND LEN(t2.item_number) = 6 THEN 'ACCESSORY'
		ELSE 'CG' END AS Product
FROM
    (SELECT  * FROM Distribution_Warehouse_Wholesale.t_asn as a1
     WHERE a1.wh_id = '335' and a1.status in ('NEW','CHECKED IN')
     ) AS t1
LEFT JOIN
        (SELECT *
		FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335') as t2
        ON t1.asn_id = t2.asn_id and t1.wh_id = t2. wh_id
LEFT JOIN
        (SELECT  * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335') as t3
	    ON t1.asn_id = t3.AsnId and t1.wh_id= t3.Wh_id
LEFT JOIN ( SELECT * 
			FROM CTE 
			WHERE cnt = 1 OR rn = 1  -- 1. 唯一值的记录直接保留  2. 非唯一值的按规则去重
			--ORDER BY entered_yard DESC
   --     (SELECT a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard, a4.location_id, a5.location_name
   --      FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
		 --LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.YaLocation as t WHERE t.area_id = '335') as a5 
		 --			ON a4.location_id = a5.location_id and a4.area_id = a5.area_id
   --      WHERE a4.Wh_id = '335' and a4.status in ('IN DOOR','IN YARD CHASSIS')
   --      Group by a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard, a4.location_id, a5.location_name
         ) as t4
	    ON t3.TrailerId = t4.trailer_id and t3.Wh_id = t4.wh_id and t3.EquipmentId = t4.equipment_id
LEFT JOIN itm as itm ON itm.ITNBR = t2.item_number and itm.STID = t1.wh_id
WHERE t1.status in ('CHECKED IN') 
AND t2.quantity_shipped - t2.quantity_received >0