select top 10 * from t_serial_active where hu_id is not null
select top 10 * from t_hu_master where hu_id is not null
select top 10 * from t_hu_detail where hu_id is not null

SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE  COLUMN_NAME LIKE '%roll%'

-- 查询前10条处理单元(HU)的汇总信息
SELECT 
    hum.hu_id,
    hum.status,
    hum.wh_id,
    hum.location_id,
    hud.item_number,    
    COUNT(1) AS roll_qty,
    hud.po_number,
    hud.lot_number,
    hud.mapics_batch_lot,
    SUM(hud.actual_qty) AS sumqty

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
WHERE hum.type IN ('IV', 'RC') 
    AND itm.inventory_type = 'RM'
    AND itm.item_number = '110821'
GROUP BY 
    hum.hu_id, 
    hum.status, 
    hum.wh_id, 
    hum.location_id, 
    hud.item_number,
    hud.po_number,
    hud.lot_number,
    hud.mapics_batch_lot
ORDER BY hum.hu_id;