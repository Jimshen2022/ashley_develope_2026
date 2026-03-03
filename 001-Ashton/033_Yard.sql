WITH FilteredASN AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.t_asn 
    WHERE wh_id = '335' 
    AND status IN ('NEW','CHECKED IN')
),
FilteredASNDetail AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.ASN_Detail 
    WHERE wh_id = '335'
),
FilteredTrailer AS (
    SELECT trailer_id, carrier_id, equipment_id, wh_id, 
           entered_yard, exited_yard, status, location_id
    FROM Distribution_Warehouse_Wholesale.Trailer
    WHERE Wh_id = '335' 
    AND status = 'IN DOOR'
),
vn as
    (SELECT * FROM Distribution_Warehouse_Wholesale.Vendor as v1 WHERE v1.Whid in ('335')),
itm AS
(SELECT i.ITNBR, i.ITCLS, i.B2Z95S,i.ITDSC, i1.TIHIUNLD, i1.PICKPUT, i1.PUTAWAY_CLASS, i1.UNITSWIDE, i1.UNITLAYERS, i1.UNITSDEEP, i1.SCOOPQTY, i1.SKIDSIZE
FROM (SELECT  * FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID IN ('335'))  AS i,
(SELECT b.ITNBR, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID AS PUTAWAY_CLASS, b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE
FROM MasterData_ItemMaster_AFI.ITBEXT as b WHERE b.House in ('335')
) AS i1
WHERE i.ITNBR = i1.ITNBR
)

SELECT
    t2.customer_po_number,
    t1.equipment_id,
    t1.wh_id,
--     t1.asn_id,
--     t1.asn_number,
--     t1.vendor_id,
    v0.VendorCode,
    v0.VendorName,
    '' as 'Due_Date(Ashton_Unload_Date)',
    t1.shipped as 'PCS',
    t1.total_volume AS 'Cubes(ft3)',
    t1.expected_arrival,
    t1.total_quantity,
    t1.total_weight,
    t1.trailer_type_name,
    t1.status,
    t1.sent_103_flag,
    t1.sent_101_flag,
    t2.asn_detail_id,
    t2.item_number,
    t2.uom,
    t2.quantity_shipped,
    t2.serial_number_start,
    t2.serial_number_end,
    t2.quantity_received,
    t2.born_on_date,
    t2.sn_coo,
    t3.TrailerID,
    t4.entered_yard,
    t4.status,
    t4.location_id,
    t5.location_name,
    CONCAT(t1.equipment_id, '_', t2.customer_po_number) AS equipment_po,
    t2.quantity_shipped - t2.quantity_received AS Yard_open_qty,
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
       WHEN t2.item_number LIKE 'PA%' THEN 'UPH'
       WHEN SUBSTRING(t2.item_number, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
       WHEN SUBSTRING(t2.item_number, 1, 1) IN ('A', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W','Z') THEN 'CG'
       WHEN a2.PICKPUT in ('PALLT') THEN 'CG'
       WHEN a2.PICKPUT in ('UPH') THEN 'UPH'
    ELSE 'CHECK' END AS Product
FROM FilteredASN t1
LEFT JOIN FilteredASNDetail t2
    ON t1.asn_id = t2.asn_id 
    AND t1.wh_id = t2.wh_id
LEFT JOIN Distribution_Warehouse_Wholesale.t_trailer_asn t3
    ON t1.asn_id = t3.AsnId 
    AND t1.wh_id = t3.Wh_id
    AND t3.Wh_id = '335'
LEFT JOIN FilteredTrailer t4
    ON t3.TrailerId = t4.trailer_id 
    AND t3.Wh_id = t4.wh_id 
    AND t3.EquipmentId = t4.equipment_id
LEFT JOIN Distribution_Warehouse_Wholesale.YaLocation t5
    ON t4.location_id = t5.location_id 
    AND t4.wh_id = t5.area_id
    AND t5.area_id = '335'
LEFT JOIN itm as a2 on t2.item_number = a2.ITNBR
LEFT JOIN vn as v0 on v0.VendorId = t1.vendor_id