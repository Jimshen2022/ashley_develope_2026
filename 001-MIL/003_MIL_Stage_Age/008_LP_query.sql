select top 10 * from t_hu_master
select top 10 * from t_hu_detail

-- 定义参数
DECLARE @HU_ID VARCHAR(50) = '%';
DECLARE @LocationID VARCHAR(50) = '%';
DECLARE @ItemNumber VARCHAR(50) = '%';
DECLARE @WH_ID VARCHAR(20) = '51';
DECLARE @LotNumber VARCHAR(50) = '%';

SELECT TOP 100
    hum.hu_id,
    hum.status,
    hum.wh_id,
    hum.location_id,
    hud.item_number,
    -- 新增列：提取 lot_number 中 '/' 之前的部分
    -- 如果没有 '/'，则返回完整的 lot_number
    LEFT(hud.lot_number, CHARINDEX('/', hud.lot_number + '/') - 1) AS lot_prefix,
    COUNT(1) AS roll_qty,
    hud.po_number,
    SUM(hud.actual_qty) AS sumqty
FROM t_hu_master hum WITH (NOLOCK)
JOIN t_hu_detail hud WITH (NOLOCK)
    ON hum.wh_id = hud.wh_id
    AND hum.hu_id = hud.hu_id
JOIN t_item_master itm WITH (NOLOCK)
    ON hud.wh_id = itm.wh_id
    AND hud.item_number = itm.item_number
JOIN t_stored_item sto WITH (NOLOCK)
    ON sto.wh_id = hum.wh_id
    AND sto.location_id = hum.location_id
    AND sto.item_number = hud.item_number
    AND ISNULL(sto.lot_number, '') = ISNULL(hud.lot_number, '')
    AND ISNULL(sto.po_number, '') = ISNULL(hud.po_number, '')
WHERE
    hum.hu_id LIKE @HU_ID
    AND hum.location_id LIKE @LocationID
    AND hud.item_number LIKE @ItemNumber
    AND hum.wh_id LIKE @WH_ID
    AND hum.type IN ('IV', 'RC')
    AND itm.inventory_type = 'RM'
    AND hud.lot_number LIKE @LotNumber
GROUP BY
    hum.hu_id,
    hum.status,
    hum.wh_id,
    hum.location_id,
    hud.item_number,
    -- 必须在 GROUP BY 中同步增加此截取逻辑
    LEFT(hud.lot_number, CHARINDEX('/', hud.lot_number + '/') - 1),
    hud.po_number;