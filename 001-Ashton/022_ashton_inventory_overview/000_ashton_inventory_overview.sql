-- Ashton Inventory Supply Overview included Wanek stage and door, Created by Jim,Shen at May.15.2025
WITH itm AS (
    SELECT i.ITNBR, i.ITCLS, i.B2Z95S, i.ITDSC, i1.TIHIUNLD, i1.PICKPUT, i1.PUTAWAY_CLASS, i1.UNITSWIDE, i1.UNITLAYERS, i1.UNITSDEEP, i1.SCOOPQTY, i1.SKIDSIZE
    FROM (
        SELECT * FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID IN ('335')
    ) AS i
    JOIN (
        SELECT b.ITNBR, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID AS PUTAWAY_CLASS, b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE
        FROM MasterData_ItemMaster_AFI.ITBEXT AS b WHERE b.House IN ('335')
    ) AS i1
    ON i.ITNBR = i1.ITNBR
),
ord as (
SELECT t.order_number, t.customer_id, t.arrive_date
FROM Distribution_Warehouse_Wholesale.[t_order] as t
WHERE t.wh_id in ('31','35','33','34')
AND t.customer_id = '335'
),
 wanek_stage_for_ashton  as (
    SELECT sto.item_number,
     sto.actual_qty,
    sto.status,
    sto.wh_id,
    sto.location_id,
    loc.TypeDescription,
    sto.type
FROM (select * from Distribution_Warehouse_Wholesale.t_stored_item  as t where t.wh_id in ('31','35','33','34')) as sto
JOIN ( select * from Distribution_Warehouse_Wholesale.t_location  as t1 where t1.wh_id in ('31','35','33','34')) as loc
    ON sto.location_id = loc.location_id
    AND sto.wh_id = loc.wh_id
Where sto.type IN ( SELECT t3.order_number FROM ord as t3)
    ),
CTE AS (
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
        ) AS cnt,
        ROW_NUMBER() OVER (
            PARTITION BY a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard
            ORDER BY
                CASE
                    WHEN a5.location_name LIKE 'D%' THEN 1
                    ELSE 2
                END,
                a4.location_id
        ) AS rn
    FROM Distribution_Warehouse_Wholesale.Trailer AS a4
    LEFT JOIN (
        SELECT * FROM Distribution_Warehouse_Wholesale.Yalocation WHERE area_id = '335'
    ) AS a5
    ON a4.location_id = a5.location_id AND a4.area_id = a5.area_id
    WHERE a4.wh_id = '335'
    AND a4.status IN ('IN DOOR', 'IN YARD CHASSIS')
),
YardData AS (
    SELECT
        x0.item_number,
        x0.po_number,
        x0.location_name,
        SUM(CASE WHEN x0.status = 'NEW' THEN x0.open_qty ELSE 0 END) AS In_Transit_Qty,
        SUM(CASE WHEN x0.status = 'CHECKED IN' THEN x0.open_qty ELSE 0 END) AS In_Yard_Qty,
        'Yard' AS Location
    FROM (
        SELECT
            t1.wh_id,
            t1.asn_id,
            t1.asn_number,
            t1.vendor_id,
            t1.carrier_id,
            t1.expected_arrival,
            t1.shipped,
            t1.total_quantity,
            t1.total_weight,
            t1.total_volume,
            t1.equipment_id,
            t1.trailer_type_name,
            t1.status,
            t1.sent_103_flag,
            t1.sent_101_flag,
            t2.asn_detail_id,
            t2.customer_po_number AS po_number,
            t2.item_number,
            t2.uom,
            t2.quantity_shipped,
            t2.quantity_received,
            t2.quantity_shipped - t2.quantity_received AS open_qty,
            t2.serial_number_start,
            t2.serial_number_end,
            t2.born_on_date,
            t2.sn_coo,
            t4.entered_yard,
            t4.location_name,
            CONCAT(t1.equipment_id, '_', t2.customer_po_number) AS equipment_po,
            'In_Yard' AS location_type,
            itm.PICKPUT,
            CASE WHEN itm.PICKPUT = 'UPH' THEN 'UPH' ELSE 'CG' END AS Product
        FROM (
            SELECT * FROM Distribution_Warehouse_Wholesale.t_asn AS a1
            WHERE a1.wh_id = '335' AND a1.status IN ('NEW','CHECKED IN')
        ) AS t1
        LEFT JOIN Distribution_Warehouse_Wholesale.ASN_Detail AS t2
            ON t1.asn_id = t2.asn_id AND t1.wh_id = t2.wh_id
        LEFT JOIN (
            SELECT * FROM Distribution_Warehouse_Wholesale.t_trailer_asn AS a3 WHERE a3.Wh_id = '335'
        ) AS t3
            ON t1.asn_id = t3.AsnId AND t1.wh_id = t3.Wh_id
        LEFT JOIN (
            SELECT * FROM CTE WHERE cnt = 1 OR rn = 1
        ) AS t4
            ON t3.TrailerId = t4.trailer_id AND t3.Wh_id = t4.wh_id AND t3.EquipmentId = t4.equipment_id
        LEFT JOIN itm ON itm.ITNBR = t2.item_number
        WHERE t2.quantity_shipped - t2.quantity_received > 0
    ) AS x0
    WHERE x0.po_number NOT IN ('P2KZC68','P2KNW28','P2K9X99','P2LCV97','P2KS391','P2LD985')
    GROUP BY x0.item_number, x0.po_number,location_name
)

-- Final Query
SELECT a1.item_number, a1.location_id, a1.po_number, a1.Type, a2.ITCLS, a2.B2Z95S,
    CASE
        WHEN a1.Type = 'In_Racking' and  SUBSTRING(a1.location_id,1,2) IN ('A3') THEN 'In_Racking'
        WHEN a1.Type = 'In_Racking' and  SUBSTRING(a1.location_id,1,2) IN ('RS') THEN 'Received_Stage'
        WHEN a1.Type = 'In_Racking' and  SUBSTRING(a1.location_id,1,1) IN ('S') THEN 'Shipping_Stage'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,1) IN ('D') and SUBSTRING(a1.location_id,1,2) <>'DM' THEN 'Loaded'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,2) IN ('NG') THEN 'NG_Loc'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,2) IN ('DM') THEN 'NG_Loc'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,8) IN ('EX001AA1') THEN 'Vendor_Over_Shipment'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,8) IN ('EX001AA2') THEN 'Extra_pieces'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,2) IN ('RP') THEN 'In_Racking'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,2) IN ('SH') THEN 'Vendor_Short_shipment'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,2) IN ('DR') THEN 'Unload_loc'
        WHEN a1.Type = 'In_Racking' and SUBSTRING(a1.location_id,1,2) IN ('VS','VJ','VE','FO','VR','VF') THEN 'On_Fork_loc'
        WHEN a1.Type = 'On_Wanek_Stage'  and a1.location_id Like 'D%' THEN 'Wanek_Door'
        WHEN a1.Type = 'On_Wanek_Stage'   THEN 'Wanek_Stage'
        WHEN a1.Type = 'In_Transit'  THEN 'In_Transit'
        WHEN a1.Type = 'In_Yard'  THEN 'In_Yard'
        ELSE 'Check'
    END AS Area,
    CASE
        WHEN a2.PICKPUT IN ('UPH') THEN 'UPH'
        ELSE 'CG'
    END AS Product,
    a1.Racking_Qty AS Qty,
    CONVERT(DATETIME, GETDATE()) AS Date
FROM (
    SELECT t1.item_number, t1.location_id, t1.po_number,'In_Racking' as 'Type', COUNT(t1.serial_number) AS Racking_Qty
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    WHERE t1.wh_id IN ('335') AND t1.serial_no_status NOT IN ('O') AND t1.master_status NOT IN ('S')
    GROUP BY t1.item_number, t1.location_id, t1.po_number
    UNION ALL
    SELECT y0.item_number, y0.location_name, y0.po_number, 'In_Transit', y0.In_Transit_Qty
    FROM YardData AS y0 WHERE y0.In_Transit_Qty <> 0
    UNION ALL
    SELECT y0.item_number, y0.location_name,y0.po_number,'In_Yard',  y0.In_Yard_Qty
    FROM YardData AS y0 WHERE y0.In_Yard_Qty <> 0
    UNION ALL
    SELECT w0.item_number, w0.location_id, w0.type, 'On_Wanek_Stage', w0.actual_qty
    FROM wanek_stage_for_ashton AS w0
) AS a1
JOIN itm AS a2 ON a1.item_number = a2.ITNBR
