-- 正确写法：CTE 放最前面，外层直接套
WITH ranked AS (
    SELECT
        t1.start_tran_date,
        CAST(t1.start_tran_time AS TIME) AS start_tran_time,

        CASE
            WHEN CAST(t1.start_tran_time AS TIME) >= '07:00'
             AND CAST(t1.start_tran_time AS TIME) <  '19:00'
            THEN 'D'
            ELSE 'N'
        END AS shift,

        CASE
            WHEN CAST(t1.start_tran_time AS TIME) >= '07:00'
             AND CAST(t1.start_tran_time AS TIME) <  '19:00'
            THEN t1.start_tran_date
            WHEN CAST(t1.start_tran_time AS TIME) < '07:00'
            THEN DATEADD(day, -1, t1.start_tran_date)
            ELSE t1.start_tran_date
        END AS shift_date,

        CASE
            WHEN t1.tran_type IN ('363','372') THEN 'Picking'
            WHEN t1.tran_type IN ('151','951') THEN 'Received'
            WHEN t1.tran_type IN ('321')       THEN 'Loaded'
            WHEN t1.tran_type IN ('347')       THEN 'Shipped'
        END AS tran_category,

        t1.tran_type,
        t1.lot_number,
        t1.control_number,
        t1.control_number_2,
        t1.item_number,
        t2.commodity_code,
        t2.pick_put_id,
        t1.tran_qty,
        t1.employee_id,
        t3.name,
        t3.supervisor,

        ROW_NUMBER() OVER (
            PARTITION BY t1.tran_type,
                         t1.lot_number,
                         t1.item_number,
                         t1.employee_id
            ORDER BY t1.start_tran_date DESC,
                     t1.start_tran_time DESC
        ) AS rn

    FROM t_tran_log     AS t1 WITH (NOLOCK)
    LEFT JOIN t_item_master  AS t2 WITH (NOLOCK) ON t1.item_number = t2.item_number
    LEFT JOIN t_employee     AS t3 WITH (NOLOCK) ON t1.employee_id = t3.emp_number

    WHERE
        t1.tran_type IN ('151','951','363','372','321','347')
        AND t1.start_tran_date > '2026-01-01'
),

-- 第二个CTE：过滤rn=1并计算qty
filtered AS (
    SELECT
        shift_date,
        shift,
        tran_category,
        tran_type,
        item_number,
        commodity_code,
        pick_put_id,
        CASE
            WHEN tran_type = '951' THEN -tran_qty
            ELSE tran_qty
        END AS qty,
        employee_id,
        name,
        supervisor
    FROM ranked
    WHERE rn = 1
)

-- 最外层汇总
SELECT
    shift_date,
    shift,
    tran_category,
    tran_type,
    item_number,
    commodity_code,
    pick_put_id,
    employee_id,
    name,
    supervisor,
    SUM(qty)  AS total_qty,
    COUNT(*)  AS tran_count
FROM filtered
GROUP BY
    shift_date,
    shift,
    tran_category,
    tran_type,
    item_number,
    commodity_code,
    pick_put_id,
    employee_id,
    name,
    supervisor
ORDER BY
    tran_category,
    item_number,
    shift_date,
    shift