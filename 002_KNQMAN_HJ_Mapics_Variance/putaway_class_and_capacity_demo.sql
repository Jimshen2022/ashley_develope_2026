/*
SELECT top 10 * FROM t_location where len(location_id) = 8
select top 10 *  from  t_class_loca where location_id like 'A3021%1'
select top 10 *  from  t_loc_pallet_capacity  where location_id = 'A3020HA1'
select top 10 *  from  t_location
select top 10 *  from  t_fwd_pick
select top 10 *  from  t_zone_loca 

select top 100 * from t_item_uom where item_number like 'W%' AND pick_put_id = 'PALLT'



*/


-- 先创建 pallet capacity 的 CTE
select top 10 *  from  t_class_loca where location_id like 'A3020HA1%'; 
select top 10 *  from  t_loc_pallet_capacity  where location_id = 'A3020HA1';

WITH item_uom as (
    select 
        item_number,
        wh_id,
        uom,
        conversion_factor,
        uom_weight,
        unit_volume,
        length,
        width,
        height,
        class_id,
        pick_put_id,
        units_per_layer as units_wide,
        layers_per_uom as layers_tall, 
        max_in_layer as units_deep,
        pallet_id,
        equipment_class_id,
        std_hand_qty,
        max_hand_qty
    from t_item_uom 
),
pallet_capacity AS (
    SELECT 
        wh_id,
        location_id,
        STUFF((
            SELECT DISTINCT ' | ' + 
                CASE 
                    WHEN pallet_id = '1' THEN '5x5'
                    WHEN pallet_id = '3' THEN '5x7'
                    WHEN pallet_id = '4' THEN '3.5x5'
                    WHEN pallet_id = '5' THEN '3.5x7'
                    WHEN pallet_id = '18' THEN '5x8'
                    WHEN pallet_id = '16' THEN 'No_Skid'
                    ELSE 'Check'
                END + ':' + CAST(capacity AS VARCHAR)
            FROM t_loc_pallet_capacity t2
            WHERE t2.wh_id = t1.wh_id 
                AND t2.location_id = t1.location_id
            FOR XML PATH('')
        ), 1, 3, '') AS pallet_capacity_info
    FROM t_loc_pallet_capacity t1 
    GROUP BY wh_id, location_id
),
fwd as (
    select * from t_fwd_pick where location_id not in ('A1001AA1','A1001AA9')
)
-- 主查询：putaway class 与 pallet capacity 连接
SELECT 
    t0.wh_id, 
    t0.location_id, 
        CASE 
        WHEN SUBSTRING(t0.location_id,6,1) IN ('C','E','G','J','L','N','Q','S','U','X','Z') 
        THEN 'C_right_side'
        ELSE 'D_left_side' 
    END as side,
    SUBSTRING(t0.location_id,6,1) AS sixth_char,
    SUBSTRING(t0.location_id,4,2) AS aisle,
    t0.type,
    t0.status,
    STUFF((
        SELECT DISTINCT ',' + class_id
        FROM t_class_loca t2
        WHERE t2.wh_id = t0.wh_id 
            AND t2.location_id = t0.location_id
        FOR XML PATH('')
    ), 1, 1, '') AS class_ids,
    pc.pallet_capacity_info, 
    f.item_number,
    f.replen_level,
    f.replen_qty,
    f.capacity_qty,
    f.is_new_item,
    f.uom,
    i.wh_id as item_wh_id,
    i.uom as item_uom,
    i.conversion_factor,
    i.uom_weight,
    i.unit_volume,
    i.length,
    i.width,
    i.height,
    i.class_id as item_class_id,
    i.pick_put_id,
    i.units_wide,
    i.layers_tall, 
    i.units_deep,
    i.pallet_id,
    i.equipment_class_id,
    i.std_hand_qty,
    i.max_hand_qty
FROM t_location AS t0
LEFT JOIN t_class_loca t1 ON t0.location_id = t1.location_id
LEFT JOIN pallet_capacity pc ON t0.wh_id = pc.wh_id AND t0.location_id = pc.location_id
LEFT JOIN fwd as f ON f.location_id = t0.location_id
LEFT JOIN item_uom as i ON i.item_number = f.item_number
WHERE 1=1
  AND SUBSTRING(t0.location_id,1,5) IN ('A3020')
  AND SUBSTRING(t0.location_id, 6, 1) IN ('H','K','M')
  AND SUBSTRING(t0.location_id, 8, 1) IN ('1')
  AND NOT EXISTS (select 1 from t_location as d where d.type = 'ZZ' and d.location_id = t0.location_id)
GROUP BY 
    t0.wh_id, 
    t0.location_id,
    SUBSTRING(t0.location_id,6,1),
    CASE 
        WHEN SUBSTRING(t0.location_id,6,1) IN ('C','E','G','J','L','N','Q','S','U','X','Z') 
        THEN 'C_right_side'
        ELSE 'D_left_side' 
    END,
    SUBSTRING(t0.location_id,4,2),
    t0.type, 
    t0.status, 
    pc.pallet_capacity_info, 
    f.item_number,
    f.replen_level,
    f.replen_qty,
    f.capacity_qty,
    f.is_new_item,
    f.uom,
    i.wh_id,
    i.uom,
    i.conversion_factor,
    i.uom_weight,
    i.unit_volume,
    i.length,
    i.width,
    i.height,
    i.class_id,
    i.pick_put_id,
    i.units_wide,
    i.layers_tall, 
    i.units_deep,
    i.pallet_id,
    i.equipment_class_id,
    i.std_hand_qty,
    i.max_hand_qty
ORDER BY t0.wh_id, t0.location_id