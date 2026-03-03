with uom as 
(select item_number, wh_id, pick_put_id,cube_factor, class_id
 from t_item_uom where wh_id = '35' and pick_put_id = 'UPH'
),
BaseData AS (
    -- 1. 基础数据层 (保持不变)
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
        l.location_id LIKE 'M3%' 
        AND l.type = 'I'
        AND l.capacity_volume >= 50000
    GROUP BY s.item_number, s.location_id
),
RunningCalcs AS (
    -- 2. 累计计算层 (核心修改在这里)
    SELECT 
        item_number,
        location_id,
        current_qty,
        max_capacity_qty,
        
        -- 总水量不变
        SUM(current_qty) OVER (PARTITION BY item_number) AS total_item_inventory,
        
        -- 统计分布数
        COUNT(location_id) OVER (PARTITION BY item_number) AS loc_count,

        -- [核心修改点]: 累计容量的计算顺序
        -- 改为：按 current_qty 降序排列。
        -- 意义：优先把"容量"分配给"当前库存最多"的库位，保证它们先被填满。
        ISNULL(SUM(max_capacity_qty) OVER (
            PARTITION BY item_number 
            ORDER BY current_qty DESC, location_id ASC -- <--- 这里改了
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 0) - max_capacity_qty AS prev_accumulated_cap
    FROM BaseData
),
Simulation AS (
    -- 3. 模拟层 (逻辑保持不变，但因为输入顺序变了，结果会更优)
    SELECT 
        *,
        CASE 
            WHEN total_item_inventory <= prev_accumulated_cap THEN 0
            WHEN (total_item_inventory - prev_accumulated_cap) >= max_capacity_qty THEN max_capacity_qty
            ELSE (total_item_inventory - prev_accumulated_cap)
        END AS simulated_qty
    FROM RunningCalcs
)
-- 4. 最终输出层
SELECT 
    Simulation.item_number,
    u.class_id,
    u.cube_factor,
    u.pick_put_id,
    location_id,
    current_qty,
    max_capacity_qty,
    simulated_qty,
    FORMAT(CASE WHEN max_capacity_qty > 0 THEN simulated_qty / max_capacity_qty ELSE 0 END, 'P') AS simulated_utilization,
    CASE WHEN loc_count > 1 THEN 1 ELSE 0 END AS is_consolidation_candidate,
    CASE WHEN current_qty > 0 AND simulated_qty = 0 THEN 1 ELSE 0 END AS is_freed_up
FROM Simulation
LEFT JOIN uom AS u ON Simulation.item_number = u.item_number 
ORDER BY 
    Simulation.item_number, 
    -- 排序建议：为了让你直观看到哪些被填满、哪些被清空，
    -- 我们可以先按模拟后的库存排序，再按原库位排序
    simulated_qty DESC, 
    location_id;