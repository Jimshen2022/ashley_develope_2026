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
    WHERE t.wh_id = '335' AND t.pick_put_id = 'UPH'
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
     SELECT t.wh_id, 
        t.tran_type,
        t.start_tran_date,
        t.start_tran_time,
        DATEPART(HOUR, t.start_tran_time) AS Hour24,
        t.item_number,
        i.pick_put_id,
        i.std_hand_qty,
        i.unit_volume,
        i.class_id,
        i.pallet_id,
        t.tran_qty,
        1.0* t.tran_qty * NULLIF(i.unit_volume,0) as cubes,
        -- 把 1.5 m 转成英尺：1.6×3.28084=5.249344 ft
        -- 体积：5×7×5.249344=183.727 ft³.
        1.0* t.tran_qty * NULLIF(i.unit_volume,0) /183.727 as pallet_by_cube,  
        t.tran_qty/NULLIF(i.std_hand_qty,0) as pallet_by_piece        
     FROM Distribution_Warehouse_Wholesale.TranLog AS t
     LEFT JOIN itm as i on t.item_number = i.item_number and t.wh_id = i.wh_id
     WHERE t.wh_id = '335'
       AND t.tran_type ='363'
       AND i.pick_put_id = 'UPH'
       AND CAST(t.start_tran_date AS DATETIME) + CAST(t.start_tran_time AS DATETIME) >= '2025-01-01'
       AND CAST(t.start_tran_date AS DATETIME) + CAST(t.start_tran_time AS DATETIME) < '2025-12-31'
)
SELECT 
    a.wh_id,
    a.item_number,
    a.start_tran_date,
    a.hour24,
    a.class_id,
    a.std_hand_qty,
    a.pallet_id,
    case 
        when a.pallet_id = 1 then '5x5'
        when a.pallet_id = 3 then '5x7'
        when a.pallet_id = 4 then '3.5x5'
        when a.pallet_id = 5 then '3.5x7'
        when a.pallet_id = 16 then 'bulk'
        when a.pallet_id = 18 then '5x8'
    else 'UPH' End as pallet_type,
    a.unit_volume,
    a.pick_put_id,
    SUM(a.tran_qty) AS tran_qty,
    SUM(a.cubes) AS cubes,
    SUM(a.pallet_by_piece) AS pallet_by_piece,
    SUM(a.pallet_by_cube) AS pallet_by_cube
FROM agg AS a
WHERE a.pick_put_id IN ('UPH') 
    AND a.tran_qty >0
GROUP BY 
    a.wh_id,
    a.item_number,
    a.pick_put_id,
    a.start_tran_date,
    a.hour24,
    a.class_id,
    a.std_hand_qty,
    a.pallet_id,
    case 
        when a.pallet_id = 1 then '5x5'
        when a.pallet_id = 3 then '5x7'
        when a.pallet_id = 4 then '3.5x5'
        when a.pallet_id = 5 then '3.5x7'
        when a.pallet_id = 16 then 'bulk'
        when a.pallet_id = 18 then '5x8'
    else 'UPH' End, 
    a.unit_volume,
    a.pick_put_id
ORDER BY a.start_tran_date


