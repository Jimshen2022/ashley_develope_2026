--author: Ashton
--date: Mar.21.2025
--description: This script is used to get the trip head details for the backorder
--created by Jim,Shen
WITH im as
(select m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id
 from Distribution_Warehouse_Wholesale.t_item_master as m
    where m.wh_id = '335'
group by m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id
),
i AS (
    SELECT 
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC,
        im.pick_put_id,
        im.commodity_code,
        im.class_id
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    left join im on im.item_number = t0.ITNBR
    WHERE t0.STID = '335'
),
bo AS (
    SELECT  
        t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        SUM(t3.tran_qty) AS bo_tran_qty,
        SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube            
    FROM [PowerBI_Distribution].[TranLog] AS t3 
    LEFT JOIN i ON i.ITNBR = t3.item_number
    WHERE t3.wh_id = '335' 
        AND t3.tran_type = '340' 
        AND t3.start_tran_date > DATEADD(DAY, -180, GETDATE()) 
    GROUP BY t3.tran_type,
             CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
             t3.item_number
),
trx AS (
    SELECT  
    t3.start_tran_date,
    t3.tran_type,
    trip_info.trip_nbr,
    t3.item_number,
    i.pick_put_id,
    trip_info.product,
    t3.routing_code AS container_nbr,
    SUM(t3.tran_qty) AS tran_qty,
    SUM(t3.tran_qty * i.B2Z95S) AS tran_cube,
    trip_info.product_group
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN i ON i.ITNBR = t3.item_number
-- 子查询用于判断每个trip_nbr的product_group
INNER JOIN (
    SELECT
        CAST(LEFT(control_number_2, CHARINDEX('-', control_number_2) - 1) AS INT) AS trip_nbr,
        CASE
            WHEN COUNT(DISTINCT CASE WHEN i.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END) = 1
                THEN MAX(CASE WHEN i.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END)
            ELSE 'Mixed'
        END AS product_group,
        MAX(CASE WHEN i.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END) AS product
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '347'
        AND CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT DISTINCT bo.trip_nbr FROM bo)
        AND t3.start_tran_date > DATEADD(DAY, -200, GETDATE())
    GROUP BY CAST(LEFT(control_number_2, CHARINDEX('-', control_number_2) - 1) AS INT)
) AS trip_info
ON trip_info.trip_nbr = CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
WHERE t3.wh_id = '335'
    AND t3.tran_type = '347'
    AND CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT DISTINCT bo.trip_nbr FROM bo)
    AND t3.start_tran_date > DATEADD(DAY, -200, GETDATE())
GROUP BY
    t3.start_tran_date,
    t3.tran_type,
    trip_info.trip_nbr,
    t3.item_number,
    i.pick_put_id,
    trip_info.product,
    t3.routing_code,
    trip_info.product_group
),
all_items AS (
    -- 确保所有 item_number 都被包含
    SELECT trip_nbr, item_number FROM bo
    UNION 
    SELECT trip_nbr, item_number FROM trx
),
filled_data AS (
    SELECT 
        ai.trip_nbr,
        ai.item_number,
        -- 处理 start_tran_date
        COALESCE(t.start_tran_date, MAX(t.start_tran_date) OVER (PARTITION BY ai.trip_nbr)) AS start_tran_date,
        -- 处理 tran_type
        COALESCE(t.tran_type, MAX(t.tran_type) OVER (PARTITION BY ai.trip_nbr)) AS tran_type,
        -- 处理 container_nbr
        COALESCE(t.container_nbr, MAX(t.container_nbr) OVER (PARTITION BY ai.trip_nbr)) AS container_nbr,
        -- 计算数量和体积
        ISNULL(t.tran_qty, 0) + ISNULL(b.bo_tran_qty, 0) AS Trip_Planned_Qty,
        ISNULL(t.tran_cube, 0) + ISNULL(b.bo_tran_cube, 0) AS Trip_Planned_Cube,
        ISNULL(t.tran_qty, 0) AS Shipped_Qty,
        ISNULL(t.tran_cube, 0) AS Shipped_Cube,
        ISNULL(b.bo_tran_qty, 0) AS bo_tran_qty,
        ISNULL(b.bo_tran_cube, 0) AS bo_tran_cube
    FROM all_items ai
    LEFT JOIN trx t ON ai.trip_nbr = t.trip_nbr AND ai.item_number = t.item_number
    LEFT JOIN bo b ON ai.trip_nbr = b.trip_nbr AND ai.item_number = b.item_number
)
SELECT * FROM filled_data
ORDER BY trip_nbr, item_number;