WITH uom AS (
    SELECT DISTINCT 
        u.wh_id,
        u.item_number,
        u.uom,
        u.cube_factor 
    FROM 
		Distribution_Warehouse_Wholesale.t_item_uom AS u
    WHERE 
		u.wh_id IN ('35', '33', '31')
)
SELECT 
    t1.wh_id2,
    t1.item_number,
    CASE
        WHEN EXISTS (
            SELECT 1 
            FROM uom 
            WHERE t1.item_number = uom.item_number AND t1.wh_id2 = uom.wh_id
        ) THEN (
            SELECT TOP 1 uom.cube_factor 
            FROM uom 
            WHERE t1.item_number = uom.item_number AND t1.wh_id2 = uom.wh_id
        )
        ELSE 0 
    END AS cube_factor,
    t1.description,
    t1.uom,
    t1.commodity_code,
    t1.qty_on_hand,
    t1.class_id,
    t1.Pick_location,
    t1.unit_weight,
    t1.unit_volume,
    t1.nested_volume,
    t1.pick_put_id,
    t1.length,
    t1.width,
    t1.height,
    t1.pallet_id,
    t1.overflow_pick_building
FROM 
    Distribution_Warehouse_Wholesale.t_item_master AS t1
WHERE 
    t1.wh_id2 IN ('35', '33', '31')
    AND t1.qty_on_hand > 0
    AND t1.commodity_code LIKE 'Z%'
    AND t1.commodity_code NOT LIKE 'Z%K';


--SELECT TOP 10 *
--FROM Distribution_Warehouse_Wholesale.t_item_uom AS t1
--WHERE t1.wh_id in ('35')

