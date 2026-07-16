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
        t.pick_put_id,
        t.unit_weight
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
        class_id, std_hand_qty, pallet_id, unit_volume, pick_put_id, unit_weight
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
      AND t.DateWeekEnding >= '2026-01-01'
    GROUP BY t.Warehouse, t.ItemNumber, t.DateWeekEnding
)
SELECT
    a.wh_id,
    a.item_number,
    i.class_id,
    i.std_hand_qty,
    i.pallet_id,
    CASE
        WHEN i.pallet_id = 1  THEN '5x5'
        WHEN i.pallet_id = 3  THEN '5x7'
        WHEN i.pallet_id = 4  THEN '3.5x5'
        WHEN i.pallet_id = 5  THEN '3.5x7'
        WHEN i.pallet_id = 16 THEN 'bulk'
        WHEN i.pallet_id = 18 THEN '5x8'
        ELSE 'Check'
    END AS pallet_type,
    i.unit_volume,
    i.pick_put_id,
    i.unit_weight * 0.453592                                    AS [unit_weight(kg)],
    1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 AS [pallet_weight(kg)],
    a.[date],
    a.OnHandQty,
    1.0 * a.OnHandQty / NULLIF(i.std_hand_qty, 0)              AS pallets,
    1.0 * a.OnHandQty * NULLIF(i.unit_volume, 0)                AS cubes,
    1.0 * a.OnHandQty * NULLIF(i.unit_weight, 0) * 0.453592     AS [onhand_weight(kg)],
    -- pallet_weight bucket
    CASE
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  500  THEN '0~500kg'
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  1000 THEN '500~1000kg'
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  1500 THEN '1000~1500kg'
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 >= 1500 THEN 'Over 1500kg'
        ELSE NULL   -- pallet_weight 为 NULL 时（unit_weight 为 0 或 NULL）
    END AS pallet_weight_bucket
FROM agg AS a
LEFT JOIN itm AS i
    ON i.item_number = a.item_number
WHERE i.pick_put_id IN ('PALLT')
    AND a.OnHandQty > 0
ORDER BY a.[date], a.item_number;