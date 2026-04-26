-- check inbound by item (with shift & shift_date)
SELECT
    t1.start_tran_date,
    t1.start_tran_time,

    -- Shift: D = 07:00~18:59, N = 19:00~06:59
    CASE
        WHEN CAST(t1.start_tran_time AS TIME) >= '07:00'
         AND CAST(t1.start_tran_time AS TIME) <  '19:00'
        THEN 'D'
        ELSE 'N'
    END AS shift,

    -- Shift date: night shift after midnight belongs to previous day
    CASE
        WHEN CAST(t1.start_tran_time AS TIME) >= '07:00'
         AND CAST(t1.start_tran_time AS TIME) <  '19:00'
        THEN t1.start_tran_date
        WHEN CAST(t1.start_tran_time AS TIME) < '07:00'
        THEN DATEADD(day, -1, t1.start_tran_date)
        ELSE t1.start_tran_date  -- 19:00~23:59, same day N shift
    END AS shift_date,

    -- Transaction category
    CASE
        WHEN t1.tran_type IN ('363','372') THEN 'Picking'
        WHEN t1.tran_type IN ('151','951') THEN 'Received'
        WHEN t1.tran_type IN ('321')       THEN 'Loaded'
        WHEN t1.tran_type IN ('347')       THEN 'Shipped'
    END AS tran_category,

    t1.tran_type,
    t1.control_number,
    t1.control_number_2,
    t1.item_number,
    t2.commodity_code,
    t2.pick_put_id,

    SUM(CASE
        WHEN t1.tran_type = '951' THEN -t1.tran_qty   -- Received reversal
        ELSE t1.tran_qty
    END) AS qty,

    t1.employee_id,
    t3.name,
    t3.supervisor

FROM t_tran_log AS t1
LEFT JOIN t_item_master AS t2 ON t1.item_number  = t2.item_number
LEFT JOIN t_employee    AS t3 ON t1.employee_id  = t3.emp_number

WHERE
    t1.tran_type IN ('151','951','363','372','321','347')
    --AND t1.control_number_2 LIKE 'P2V1217%'
    --AND t1.item_number IN ('A3000224')
    AND t1.start_tran_date > '2026-01-01'

GROUP BY
    t1.start_tran_date,
    t1.start_tran_time,
    CASE
        WHEN CAST(t1.start_tran_time AS TIME) >= '07:00'
         AND CAST(t1.start_tran_time AS TIME) <  '19:00'
        THEN 'D' ELSE 'N'
    END,
    CASE
        WHEN CAST(t1.start_tran_time AS TIME) >= '07:00'
         AND CAST(t1.start_tran_time AS TIME) <  '19:00'
        THEN t1.start_tran_date
        WHEN CAST(t1.start_tran_time AS TIME) < '07:00'
        THEN DATEADD(day, -1, t1.start_tran_date)
        ELSE t1.start_tran_date
    END,
    CASE
        WHEN t1.tran_type IN ('363','372') THEN 'Picking'
        WHEN t1.tran_type IN ('151','951') THEN 'Received'
        WHEN t1.tran_type IN ('321')       THEN 'Loaded'
        WHEN t1.tran_type IN ('347')       THEN 'Shipped'
    END,
    t1.tran_type,
    t1.control_number,
    t1.control_number_2,
    t1.item_number,
    t2.commodity_code,
    t2.pick_put_id,
    t1.employee_id,
    t3.name,
    t3.supervisor

ORDER BY
    tran_category,
    t1.item_number,
    shift_date,
    shift,
    t1.start_tran_date