
SELECT 
    t201.lot_number,
    t201.employee_id AS emp_201,
    t152.start_tran_date AS date_152_end,
    t152.end_tran_time AS time_152_end,
    t201.start_tran_time AS time_201_start,
    DATEDIFF(second, t152.end_tran_time, t201.start_tran_time) AS overlapping_seconds,
    t201.item_number,
    t201.location_id AS loc_201
FROM t_tran_log t201
INNER JOIN t_tran_log t152 
    ON t201.lot_number = t152.lot_number
    AND t201.item_number = t152.item_number -- 确保是同一个物料
WHERE t201.tran_type = '201'  -- 201 Move (Pick)
  AND t152.tran_type = '152'  -- 152 交易
  AND t201.start_tran_time < t152.end_tran_time -- 异常条件：201开始早于152结束
  -- 如果跨天，请确保日期也一致（可选）：
  AND t201.start_tran_date = t152.end_tran_date
  and t201.start_tran_date >= '2026-01-18' -- 可选：限制查询范围
ORDER BY t201.start_tran_date DESC, t201.start_tran_time DESC;