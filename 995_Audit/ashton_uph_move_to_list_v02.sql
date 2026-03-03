WITH uom AS (
    SELECT item_number, wh_id, pick_put_id, cube_factor, class_id
    FROM t_item_uom WHERE wh_id = '335' AND pick_put_id = 'UPH'
),
BaseData AS (
    -- 1. 基础数据 (保持不变)
    SELECT 
        s.item_number,
        s.location_id,
        (MAX(l.capacity_volume) / 50000.0) AS max_capacity_qty,
        ISNULL(SUM(s.actual_qty), 0) AS current_qty
    FROM t_stored_item s
    JOIN t_location l 
        ON s.wh_id = l.wh_id 
        AND s.location_id = l.location_id
    WHERE 
        l.location_id LIKE 'A3%' 
        AND l.type = 'I'
        AND l.pick_area = 'UPHOLSTERY'
        AND l.capacity_volume >= 50000
    GROUP BY s.item_number, s.location_id
),
RunningCalcs AS (
    -- 2. 模拟计算 (保持不变：优先填满库存多的库位)
    SELECT 
        item_number,
        location_id,
        current_qty,
        max_capacity_qty,
        SUM(current_qty) OVER (PARTITION BY item_number) AS total_item_inventory,
        COUNT(location_id) OVER (PARTITION BY item_number) AS loc_count,
        ISNULL(SUM(max_capacity_qty) OVER (
            PARTITION BY item_number 
            ORDER BY current_qty DESC, location_id ASC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 0) - max_capacity_qty AS prev_accumulated_cap
    FROM BaseData
),
Simulation AS (
    -- 3. 得出每个库位"应该"有多少库存
    SELECT 
        *,
        CASE 
            WHEN total_item_inventory <= prev_accumulated_cap THEN 0
            WHEN (total_item_inventory - prev_accumulated_cap) >= max_capacity_qty THEN max_capacity_qty
            ELSE (total_item_inventory - prev_accumulated_cap)
        END AS simulated_qty
    FROM RunningCalcs
),
---------------------------------------------------------------------------
-- 移库任务生成逻辑
---------------------------------------------------------------------------
Moves_Source AS (
    -- 4. 供给方 (Source)
    SELECT 
        item_number,
        location_id AS from_location,
        current_qty,      -- 保留当前库存，用于显示
        simulated_qty,    -- [关键] 保留模拟后库存，用于判断是否清空
        (current_qty - simulated_qty) AS qty_to_move, 
        COALESCE(SUM(current_qty - simulated_qty) OVER (PARTITION BY item_number ORDER BY location_id), 0) AS run_qty
    FROM Simulation
    WHERE current_qty > simulated_qty 
),
Moves_Target AS (
    -- 5. 需求方 (Target)
    SELECT 
        item_number,
        location_id AS to_location,
        (simulated_qty - current_qty) AS qty_needed, 
        COALESCE(SUM(simulated_qty - current_qty) OVER (PARTITION BY item_number ORDER BY location_id), 0) AS run_qty
    FROM Simulation
    WHERE simulated_qty > current_qty 
),
Move_Tasks AS (
    -- 6. 核心匹配逻辑
    SELECT 
        S.item_number,
        S.from_location,
        T.to_location,
        S.simulated_qty AS source_remaining_qty, -- 把源库位剩余数量带过来
        -- 计算移动数量
        (CASE WHEN S.run_qty < T.run_qty THEN S.run_qty ELSE T.run_qty END) - 
        (CASE WHEN (S.run_qty - S.qty_to_move) > (T.run_qty - T.qty_needed) THEN (S.run_qty - S.qty_to_move) ELSE (T.run_qty - T.qty_needed) END) 
        AS move_qty
    FROM Moves_Source S
    JOIN Moves_Target T 
        ON S.item_number = T.item_number
        AND S.run_qty > (T.run_qty - T.qty_needed)
        AND (S.run_qty - S.qty_to_move) < T.run_qty
)
-- 7. 最终报表
SELECT 
    M.item_number,
    U.pick_put_id,
    U.class_id,
    
    -- 任务明细
    M.from_location AS [Source Location],
    M.to_location AS [Dest Location],
    M.move_qty AS [Qty to Move],
    
    -- [新增列] 标记：源库位是否会被清空
    -- 如果源库位模拟后的剩余数量为0，则标记为1
    CASE 
        WHEN M.source_remaining_qty = 0 THEN 1 
        ELSE 0 
    END AS [Source Cleared?],

    -- 供参考的操作指令
    CONCAT(
        'Move ', M.move_qty, ' pcs. ',
        CASE WHEN M.source_remaining_qty = 0 THEN '(EMPTY LOCATION)' ELSE '(Partial Move)' END
    ) AS [Note]

FROM Move_Tasks M
LEFT JOIN uom U ON M.item_number = U.item_number
WHERE M.move_qty > 0 and CASE 
        WHEN M.source_remaining_qty = 0 THEN 1 
        ELSE 0 
    END = 1
ORDER BY 
    M.item_number, 
    M.from_location, 
    M.to_location;