--author: Ashton
--date:  Apr.22.2025
--description: This script is used to get the trip head details for the backorder
--created by Jim,Shen

WITH im AS (
    SELECT
        item_number,
        description,
        wh_id,
        commodity_code,
        class_id,
        pick_put_id
    FROM (
        SELECT
            m.item_number,
            m.description,
            m.wh_id,
            m.commodity_code,
            m.class_id,
            m.pick_put_id,
            ROW_NUMBER() OVER (
                PARTITION BY m.item_number 
                ORDER BY CASE WHEN m.class_id IS NOT NULL THEN 0 ELSE 1 END
            ) AS rn
        FROM Distribution_Warehouse_Wholesale.t_item_master AS m
        WHERE m.wh_id = '335'
    ) x
    WHERE rn = 1
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
    FROM (
        SELECT
            ITNBR,
            STID,
            ITCLS,
            B2Z95S,
            ITDSC,
            ROW_NUMBER() OVER (PARTITION BY ITNBR ORDER BY (SELECT NULL)) AS rn
        FROM MasterData_ItemMaster_AFI.ITMRVA
        WHERE STID = '335'
    ) t0
    LEFT JOIN im ON im.item_number = t0.ITNBR
    WHERE t0.rn = 1
),
bo AS (
    SELECT
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        SUM(t3.tran_qty) AS bo_tran_qty,
        SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '340'
        AND t3.start_tran_date > DATEADD(DAY, -60, GETDATE())
    GROUP BY
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
        t3.item_number
),
trip_info AS (
    SELECT
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        CASE WHEN COUNT(DISTINCT i.pick_put_id) = 1 THEN
            CASE WHEN MAX(i.pick_put_id) = 'UPH' THEN 'UPH' ELSE 'CG' END
        ELSE 'Mixed' END AS container_type
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
    --INNER JOIN bo ON bo.trip_nbr = CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
    WHERE t3.wh_id = '335'
        AND t3.tran_type in ('347','340')
        --and t3.control_number_2 like '%40099%'
        AND t3.start_tran_date > DATEADD(DAY, -80, GETDATE())
		and CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT bo.trip_nbr from bo)
    GROUP BY CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
),
main_data AS (
    SELECT
        t3.start_tran_date,
        t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        t3.routing_code,
        t3.tran_qty,
        t3.tran_qty * i.B2Z95S AS tran_cube,
        i.pick_put_id
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
--     INNER JOIN bo ON bo.trip_nbr = CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '347'
        AND t3.start_tran_date > DATEADD(DAY, -80, GETDATE())
        and CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT bo.trip_nbr from bo)
),
trx as (
SELECT
    m.start_tran_date,
    m.tran_type,
    m.trip_nbr,
    m.item_number,
    m.pick_put_id,
    CASE WHEN m.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END AS product,
    m.routing_code AS container_nbr,
    SUM(m.tran_qty) AS tran_qty,
    SUM(m.tran_cube) AS tran_cube,
    trip_info.container_type
FROM main_data m
left JOIN trip_info ON m.trip_nbr = trip_info.trip_nbr
GROUP BY
    m.start_tran_date,
    m.tran_type,
    m.trip_nbr,
    m.item_number,
    m.pick_put_id,
    CASE WHEN m.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END,
    m.routing_code,
    trip_info.container_type
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
		COALESCE(t.container_type, MAX(t.container_type) OVER (PARTITION BY ai.trip_nbr)) as container_type,
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