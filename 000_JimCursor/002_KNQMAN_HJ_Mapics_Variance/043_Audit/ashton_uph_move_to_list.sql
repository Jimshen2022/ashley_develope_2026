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
    -- 2. 模拟计算 (保持不变，确保优先填满大库存库位)
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
-- 新增逻辑开始：生成移库任务
---------------------------------------------------------------------------
Moves_Source AS (
    -- 4. 谁多了？(需要移出的人) - 供给方
    SELECT 
        item_number,
        location_id AS from_location,
        (current_qty - simulated_qty) AS qty_to_move, -- 多出来的数量
        -- 计算累加区间，用于配对
        COALESCE(SUM(current_qty - simulated_qty) OVER (PARTITION BY item_number ORDER BY location_id), 0) AS run_qty
    FROM Simulation
    WHERE current_qty > simulated_qty -- 只要现在比模拟多，就是供给源
),
Moves_Target AS (
    -- 5. 谁少了？(需要接收的人) - 需求方
    SELECT 
        item_number,
        location_id AS to_location,
        (simulated_qty - current_qty) AS qty_needed, -- 缺少的数量
        -- 计算累加区间，用于配对
        COALESCE(SUM(simulated_qty - current_qty) OVER (PARTITION BY item_number ORDER BY location_id), 0) AS run_qty
    FROM Simulation
    WHERE simulated_qty > current_qty -- 只要模拟比现在多，就是接收方
),
Move_Tasks AS (
    -- 6. 核心匹配逻辑：区间重叠法 (Range Overlap Join)
    -- 这步逻辑将"供给池"的水倒进"需求池"的桶里
    SELECT 
        S.item_number,
        S.from_location,
        T.to_location,
        -- 计算重叠部分的数量
        (CASE WHEN S.run_qty < T.run_qty THEN S.run_qty ELSE T.run_qty END) - 
        (CASE WHEN (S.run_qty - S.qty_to_move) > (T.run_qty - T.qty_needed) THEN (S.run_qty - S.qty_to_move) ELSE (T.run_qty - T.qty_needed) END) 
        AS move_qty
    FROM Moves_Source S
    JOIN Moves_Target T 
        ON S.item_number = T.item_number
        -- 确保区间有交集
        AND S.run_qty > (T.run_qty - T.qty_needed)
        AND (S.run_qty - S.qty_to_move) < T.run_qty
)
-- 7. 最终报表：给仓库员工看的格式
SELECT 
    M.item_number,
    U.pick_put_id, -- 帮助员工识别是什么包装类型
    U.class_id,
    
    -- 任务指令
    M.from_location AS [Source Location (From)],
    '-->' AS [Action],
    M.to_location AS [Dest Location (To)],
    M.move_qty AS [Qty to Move],
    
    -- 辅助信息 (可选)
    CONCAT('Move ', M.move_qty, ' pcs from ', M.from_location, ' to ', M.to_location, ' to consolidate.') AS [Instructions]
FROM Move_Tasks M
LEFT JOIN uom U ON M.item_number = U.item_number
WHERE M.move_qty > 0 -- 过滤掉无效移动
ORDER BY 
    M.item_number, 
    M.from_location, 
    M.to_location;