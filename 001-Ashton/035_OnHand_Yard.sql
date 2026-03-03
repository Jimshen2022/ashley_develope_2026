With itm AS
(SELECT i.ITNBR, i.ITCLS, i.B2Z95S,i.ITDSC, i1.TIHIUNLD, i1.PICKPUT, i1.PUTAWAY_CLASS, i1.UNITSWIDE, i1.UNITLAYERS, i1.UNITSDEEP, i1.SCOOPQTY, i1.SKIDSIZE
FROM (SELECT  * FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID IN ('335'))  AS i,
(SELECT b.ITNBR, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID AS PUTAWAY_CLASS, b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE
FROM MasterData_ItemMaster_AFI.ITBEXT as b WHERE b.House in ('335')
) AS i1
WHERE i.ITNBR = i1.ITNBR
),
YardData  as
(SELECT x0.item_number,
    SUM (CASE WHEN x0.ASN_Status = 'NEW' THEN x0.Yard_open_qty ELSE 0 END) as 'In_Transit_Qty',
    SUM (CASE WHEN x0.ASN_Status = 'CHECKED IN' THEN x0.Yard_open_qty ELSE 0 END) as 'In_Yard_Qty',
    'Yard' AS Location
FROM(
SELECT
    t1.equipment_id
    , t1.wh_id
	, t1.asn_id
	, t1.asn_number
	, t1.vendor_id
	, t1.carrier_id
	, t1.expected_arrival
	, t1.shipped
	, t1.total_quantity
	, t1.total_weight
	, t1.total_volume
	, t1.trailer_type_name
	, t1.status as ASN_Status
	, t1.sent_103_flag
	, t1.sent_101_flag
	, t2.asn_detail_id
	, t2.customer_po_number
	, t2.item_number
	, t2.uom
	, t2.quantity_shipped
	, t2.serial_number_start
	, t2.serial_number_end
	, t2.quantity_received
	, t2.born_on_date
	, t2.sn_coo
    , t3.TrailerID
	, t4.entered_yard
    , t4.status as Trailer_status
    , t4.location_id
    , t5.location_name
	, CONCAT(t1.equipment_id, '_', t2.customer_po_number) AS equipment_po
        , t2.quantity_shipped - t2.quantity_received AS Yard_open_qty
FROM (SELECT * FROM Distribution_Warehouse_Wholesale.t_asn as a1
WHERE a1.wh_id = '335' and a1.status in ('NEW','CHECKED IN')) AS t1
LEFT JOIN (SELECT *
			FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335') as t2
	ON t1.asn_id = t2.asn_id and t1.wh_id = t2. wh_id
LEFT JOIN (SELECT  * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335') as t3
	ON t1.asn_id = t3.AsnId and t1.wh_id= t3.Wh_id
LEFT JOIN (SELECT a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard, a4.exited_yard, a4.status, a4.location_id
           FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
           WHERE a4.Wh_id = '335' and a4.status in ('IN DOOR')) as t4
	on t3.TrailerId = t4.trailer_id and t3.Wh_id = t4.wh_id and t3.EquipmentId = t4.equipment_id
LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.YaLocation as a5 WHERE a5.area_id in ('335')) as t5
        on t4.location_id = t5.location_id and t4.wh_id = t5.area_id
) AS x0
GROUP BY x0.item_number
)


-- SN SUM

SELECT a1.item_number, a1.location_id, a2.ITCLS, a2.B2Z95S,
CASE
    WHEN SUBSTRING(a1.location_id,1,2) IN ('A3') THEN 'In_Racking'
	WHEN SUBSTRING(a1.location_id,1,2) IN ('RS') THEN 'Received_Stage'
	WHEN SUBSTRING(a1.location_id,1,1) IN ('S') THEN 'Shipping_Stage'
	WHEN SUBSTRING(a1.location_id,1,1) IN ('D') THEN 'Loaded'
	WHEN SUBSTRING(a1.location_id,1,1) IN ('NG') THEN 'NG_Loc'
	WHEN a1.location_id LIKE 'In_Transit_Qty%' THEN 'In_Transit_Qty'
	WHEN a1.location_id LIKE 'In_Yard_Qty%' THEN 'In_Yard_Qty'
	ELSE 'Others' END AS Area,
-- CASE
-- 	WHEN a2.ITCLS NOT LIKE 'Z%' THEN 'RP'
-- 	WHEN SUBSTRING(a1.item_number,1,4) IN ('100-') THEN 'CG'
-- 	WHEN SUBSTRING(a1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
-- 	WHEN SUBSTRING(a1.item_number,1,1) IN ('A') AND a2.B2Z95S*0.028317<=0.4 THEN 'ACCESSORY'
-- 	WHEN SUBSTRING(a1.item_number,1,1) IN ('L','Q','R') THEN 'ACCESSORY'
-- 	WHEN SUBSTRING(a1.item_number,1,1) IN ('M') AND LEN(a1.item_number) = 6 THEN 'ACCESSORY'
-- 	ELSE 'CG' END AS Product
    CASE
       WHEN a2.ITCLS NOT LIKE 'Z%' THEN 'RP'
       WHEN a2.PUTAWAY_CLASS LIKE 'UPH%' THEN 'UPH'
       WHEN a2.ITDSC LIKE '%RUG%' THEN 'ACCESSORY'
       WHEN a2.ITDSC LIKE '%RECLI%' THEN 'UPH'
       WHEN a2.ITDSC LIKE '%SOFA%' THEN 'UPH'
       WHEN a2.ITDSC LIKE '%LOVE%' THEN 'UPH'
       WHEN a2.PUTAWAY_CLASS LIKE 'PAL%' THEN 'CG'
       WHEN a2.PUTAWAY_CLASS LIKE 'SMALL%' THEN 'CG'
       WHEN a2.PUTAWAY_CLASS LIKE 'FLOOR%' THEN 'BULK'
       WHEN a2.PUTAWAY_CLASS LIKE 'RUG%' THEN 'ACCESSORY'
       WHEN a2.PUTAWAY_CLASS LIKE 'RAILS%' THEN 'RAILS'
       WHEN a1.item_number LIKE 'PA%' THEN 'UPH'
       WHEN SUBSTRING(a1.item_number, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
       WHEN SUBSTRING(a1.item_number, 1, 1) IN ('A', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W','Z') THEN 'CG'
       WHEN a2.PICKPUT in ('PALLT') THEN 'CG'
       WHEN a2.PICKPUT in ('UPH') THEN 'UPH'
    ELSE 'CHECK' END AS Product
	, a1.Racking_Qty as Qty
	, CONVERT(DATE, GETDATE()) as Date
FROM
((SELECT t1.item_number, t1.location_id, COUNT(t1.serial_number) as Racking_Qty
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id  IN ('335') AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S')
GROUP BY t1.item_number, t1.location_id )
UNION ALL
SELECT y0.item_number, 'In_Transit_Qty' as location_id, In_Transit_Qty
FROM YardData as y0 where y0.In_Transit_Qty<>0
UNION ALL
SELECT y0.item_number, 'In_Yard_Qty' as location_id, In_Yard_Qty
FROM YardData as y0 where y0.In_Yard_Qty<>0
) AS a1, itm as a2
WHERE a1.item_number = a2.ITNBR


