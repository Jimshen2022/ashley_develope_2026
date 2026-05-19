WITH last_tran AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY lot_number
               ORDER BY start_tran_date DESC, 
                        CONVERT(TIME, start_tran_time) DESC
           ) AS rn
    FROM t_tran_log
    WHERE wh_id = '335'
      AND start_tran_date >= '2026-04-19'
),
valid_lots AS (
    -- 符合條件的 lot_number 清單
    SELECT lot_number
    FROM last_tran
    WHERE rn = 1
      AND tran_type = '151'
      AND (location_id_2 LIKE 'F%' OR location_id_2 LIKE 'V%')
)
-- 用這些 lot_number 去撈所有記錄
SELECT t.*
FROM t_tran_log AS t
INNER JOIN valid_lots v ON t.lot_number = v.lot_number
WHERE t.wh_id = '335'
ORDER BY t.lot_number, t.start_tran_date, CONVERT(TIME, t.start_tran_time);