/*D:\Documents\08-Ashton_Phu_my\12-Pallets Need\Ashton CG Location Needs Estimated - 20250823.xlsb*/

WITH pallt AS (
    SELECT 
        t.wh_id,
        t.item_number,
        t.commodity_code,
        t.[description],
        t.class_id,
        t.std_hand_qty,
        t.pallet_id,
        t.unit_volume,
        t.pick_put_id
    FROM Distribution_Warehouse_Wholesale.t_item_master AS t 
    WHERE t.wh_id = '335' AND t.pick_put_id = 'PALLT'
),
ranked AS (
    SELECT 
        i.*,
        ROW_NUMBER() OVER (
            PARTITION BY i.item_number
            ORDER BY
                CASE WHEN NULLIF(LTRIM(RTRIM(i.pallet_id)), '') IS NOT NULL THEN 0 ELSE 1 END,
                CASE WHEN i.unit_volume IS NOT NULL THEN 0 ELSE 1 END,
                i.item_number
        ) AS rn
    FROM pallt AS i
),
itm AS (
    SELECT
        wh_id, item_number, commodity_code, [description],
        class_id, std_hand_qty, pallet_id, unit_volume, pick_put_id
    FROM ranked
    WHERE rn = 1
),
agg AS (
    SELECT 
        t.Warehouse as wh_id,
        t.ItemNumber as item_number,
        t.DateWeekEnding as [date],
        SUM(t.OnHandQty) AS OnHandQty
    FROM Inventory_Enh_History.ItemBalance AS t
    WHERE t.Warehouse = '335'
      AND t.DateWeekEnding >= '2025-01-01'
    GROUP BY t.Warehouse, t.ItemNumber, t.DateWeekEnding
)
SELECT 
    a.wh_id,
    a.item_number,
    i.class_id,
    i.std_hand_qty,
    i.pallet_id,
    case 
        when i.pallet_id = 1 then '5x5'
        when i.pallet_id = 3 then '5x7'
        when i.pallet_id = 4 then '3.5x5'
        when i.pallet_id = 5 then '3.5x7'
        when i.pallet_id = 16 then 'bulk'
        when i.pallet_id = 18 then '5x8'
    else 'Check' End as pallet_type,
    i.unit_volume,
    i.pick_put_id,
    a.[date],
    a.OnHandQty,
    -- 向上取整的托盘数（std_hand_qty 为 0/NULL 时返回 NULL）
    1.0 * a.OnHandQty / NULLIF(i.std_hand_qty, 0) AS pallets,
    1.0* a.OnHandQty * NULLIF(i.unit_volume, 0) AS cubes
    -- 平均每托件数：当 total_qty=0 时给 0；否则用“总件数 ÷ 向上取整的托盘数”

FROM agg AS a
LEFT JOIN itm AS i 
  ON i.item_number = a.item_number
WHERE i.pick_put_id IN ('PALLT') 
    AND a.OnHandQty >0
ORDER BY a.[date], a.item_number;


