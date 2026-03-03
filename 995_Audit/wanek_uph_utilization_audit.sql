WITH LocationData AS (
    -- 1. 基础数据层：获取 M3 区域的库位和库存信息
    SELECT 
        s.item_number,
        s.location_id,
        MAX(l.capacity_volume) AS capacity_volume,
        -- 确保处理 NULL，虽然后续计算会处理，但好习惯保持 SUM
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
CalcMetrics AS (
    -- 2. 计算层：算出利用率
    SELECT 
        item_number,
        location_id,
        current_qty,
        (capacity_volume / 50000.0) AS max_capacity_qty,
        -- 利用率公式
        (current_qty * 50000.0) / capacity_volume AS util_rate
    FROM LocationData
),
FlagLogic AS (
    -- 3. 逻辑判断层：使用窗口函数统计分布情况
    SELECT 
        *,
        -- 核心逻辑：对于当前的 item_number，统计有多少个 location 的利用率是小于 1 (100%) 的
        COUNT(CASE WHEN util_rate < 1.0 THEN 1 END) 
            OVER (PARTITION BY item_number) AS partial_location_count
    FROM CalcMetrics
)
-- 4. 输出层
SELECT 
    item_number,
    location_id,
    current_qty,
    max_capacity_qty,
    FORMAT(util_rate, 'P') AS utilization, -- 格式化为百分比
    -- 业务逻辑：如果该物品有两个及以上未满库位，标记
    CASE 
        WHEN partial_location_count >= 2 THEN 'no consolidation'
        ELSE '' 
    END AS status
FROM FlagLogic
WHERE 
    util_rate < 0.8  -- 保持原本需求：找出利用率低的（包含 0 库存）
ORDER BY 
    item_number, 
    location_id;