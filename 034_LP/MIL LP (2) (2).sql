-- 使用CTE，更清晰易读
WITH lp_summary AS (
    -- 先计算每个LP的汇总信息
    SELECT 
        hu_id,
        wh_id,
        COUNT(1) AS total_roll_qty,
        SUM(actual_qty) AS total_qty
    FROM t_hu_detail WITH(NOLOCK)
    GROUP BY hu_id, wh_id
)
SELECT 
    hum.hu_id,
    hum.status,
    hum.wh_id,
    hum.location_id,
    hud.item_number,
    hud.po_number,
    hud.lot_number,                    -- Roll/Lot
    hud.mapics_batch_lot,              -- Batch Lot Number
    hud.actual_qty,                    -- 当前行数量
    lp_summary.total_roll_qty,         -- 该LP的总行数
    lp_summary.total_qty               -- 该LP的总数量
FROM t_hu_master hum WITH(NOLOCK)
    INNER JOIN t_hu_detail hud WITH(NOLOCK) 
        ON hum.wh_id = hud.wh_id 
        AND hum.hu_id = hud.hu_id
    INNER JOIN t_item_master itm WITH(NOLOCK) 
        ON hud.wh_id = itm.wh_id 
        AND hud.item_number = itm.item_number
    INNER JOIN t_stored_item sto WITH(NOLOCK) 
        ON sto.wh_id = hum.wh_id 
        AND sto.location_id = hum.location_id
        AND sto.item_number = hud.item_number 
        AND ISNULL(sto.lot_number, '') = ISNULL(hud.lot_number, '')
        AND ISNULL(sto.po_number, '') = ISNULL(hud.po_number, '')
    LEFT JOIN lp_summary
        ON lp_summary.hu_id = hum.hu_id 
        AND lp_summary.wh_id = hum.wh_id
WHERE hum.type IN ('IV', 'RC') 
    AND itm.inventory_type = 'RM'
    AND hud.item_number = '110821'
ORDER BY hum.hu_id, hud.lot_number;