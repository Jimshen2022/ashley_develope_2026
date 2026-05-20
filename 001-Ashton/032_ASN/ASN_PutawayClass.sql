with v as (
    select vendor_id, vendor_name 
    from t_vendor
),
itm as 
(
select 
    im.item_number, 
    im.description,
    ROUND(im.unit_weight*0.4536, 2) as [unit_Weight(Kg)], 
    ROUND(im.unit_volume*0.028316846592, 2) as [Unit_Cube(m3)],
    im.class_id, 
    im.pick_put_id,
    uom.uom, 
    uom.units_per_layer as width,
    uom.layers_per_uom as height, 
    uom.max_in_layer as depth, 
    im.std_hand_qty as SCOOP_Qty, 
    im.pallet_id
from t_item_master as im 
inner join (select * from t_item_uom where pick_put_id != 'SCOOP') as uom 
    on im.item_number = uom.item_number
),
asn as ( 
    select asn_number, vendor_id, carrier_id, asn_id, expected_arrival, shipped, total_quantity, total_volume, total_weight, equipment_id, trailer_type_name, status, sent_101_flag, sent_103_flag, unload_date_xml_status
    from t_asn
    where status IN ('NEW', 'CHECKED IN')
),
asd as (
    select asn_id, item_number, customer_po_number,  sn_coo , sum(quantity_shipped) as quantity_shipped , sum(quantity_received) as quantity_received, sum(quantity_shipped)- sum(quantity_received) as remaining_quantity
    from t_asn_detail
    group by asn_id, item_number, customer_po_number, sn_coo  
),
base_data as (
    select 
        CONVERT(VARCHAR(10), a.expected_arrival, 23) as DueDate,
        CONVERT(VARCHAR(10), DATEADD(DAY, 6 - (DATEPART(WEEKDAY, a.expected_arrival) + @@DATEFIRST - 1) % 7, a.expected_arrival), 23) as WeekSaturday,
        d.customer_po_number as PO_Number,
        a.equipment_id,
        d.item_number,
        d.quantity_shipped as shipped_qty,
        d.quantity_received as received_qty,
        d.remaining_quantity as remain_qty,
        i.class_id,
        i.uom,
        i.width,
        i.height,
        i.depth,
        i.SCOOP_Qty,
        i.pallet_id,
        i.pick_put_id,
        i.[unit_Weight(Kg)],
        i.[Unit_Cube(m3)],
        a.asn_number,
        a.vendor_id,
        v.vendor_name,
        CONVERT(VARCHAR(10), a.shipped, 23) as shipped,
        a.total_quantity,
        a.total_volume,
        a.status,
        a.sent_101_flag,
        a.sent_103_flag,
        d.sn_coo,
        i.description,
        a.trailer_type_name,
        ROW_NUMBER() OVER(PARTITION BY d.customer_po_number, a.equipment_id, i.pick_put_id ORDER BY d.item_number) as rn_by_type
    from asn a
    inner join asd d on a.asn_id = d.asn_id
    left join itm i on d.item_number = i.item_number
    left join v on a.vendor_id = v.vendor_id
    where d.remaining_quantity > 0
)
select 
    DueDate,
    WeekSaturday,
    PO_Number,
    equipment_id,
    item_number,
    shipped_qty,
    received_qty,
    remain_qty,
    -- 新增两列：基于剩余数量的总重量和总体积
    ROUND(remain_qty * [unit_Weight(Kg)], 2) as Total_Weight_Kg,
    ROUND(remain_qty * [Unit_Cube(m3)], 4) as Total_Cube_m3,
    class_id,
    uom,
    width,
    height,
    depth,
    SCOOP_Qty,
    case 
        when pallet_id = 1 then '5X5'
        when pallet_id = 3 then '5X7'
        when pallet_id = 4 then '3.5X5'
        when pallet_id = 5 then '3.5X7'
        when pallet_id = 18 then '5X8'
        when pallet_id = 16 then 'No Skid'
     else 'Check' end as pallet_type,
    case 
        when pick_put_id = 'UPH' then class_id
        else (case 
                when class_id = 'RUGS' then 'RUGS'
                when class_id = 'FLOOR' then 'BULK'
                when pallet_id = 1 then '5X5'
                when pallet_id = 3 then '5X7'
                when pallet_id = 4 then '3.5X5'
                when pallet_id = 5 then '3.5X7'
                when pallet_id = 18 then '5X8'
                when pallet_id = 16 then 'No Skid'
                else 'Check' end)
    end as Product_Category,
    CASE 
        WHEN pick_put_id = 'RPFG' THEN 
            CASE WHEN rn_by_type = 1 THEN 1 ELSE 0 END
        ELSE
            CEILING(
                CASE
                    WHEN pick_put_id <> 'UPH' AND SCOOP_Qty > 0 THEN remain_qty * 1.0 / SCOOP_Qty
                    WHEN SCOOP_Qty = 0 AND pallet_id = 1 THEN remain_qty * 1.0 / 18
                    WHEN SCOOP_Qty = 0 AND pallet_id = 4 THEN remain_qty * 1.0 / 13
                    WHEN SCOOP_Qty = 0 AND pallet_id = 3 THEN remain_qty * 1.0 / 12
                    WHEN SCOOP_Qty = 0 AND pallet_id = 18 THEN remain_qty * 1.0 / 9
                    WHEN SCOOP_Qty = 0 AND pallet_id = 5 THEN remain_qty * 1.0 / 8
                    ELSE 0
                END)
    END as Pallet_Need_Qty,
    pick_put_id,
    [unit_Weight(Kg)] as Unit_Weight_Kg,
    [Unit_Cube(m3)] as Unit_Cube_m3,
    asn_number,
    vendor_id,
    vendor_name,
    shipped,
    total_quantity,
    total_volume,
    status,
    sent_101_flag,
    sent_103_flag,
    sn_coo,
    description,
    trailer_type_name
from base_data
order by DueDate, PO_Number, item_number