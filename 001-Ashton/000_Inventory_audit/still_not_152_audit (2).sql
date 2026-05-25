WITH last_tran AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY lot_number
               ORDER BY end_tran_date DESC, 
                        CONVERT(TIME, end_tran_time) DESC
           ) AS rn
    FROM t_tran_log
    WHERE wh_id = '335'
      AND start_tran_date >= '2026-04-19'
)
--SELECT item_number,
--       control_number_2,
--       tran_type,
--       lot_number,
--       hu_id,
--       location_id_2,
--       start_tran_date,
--       start_tran_time
select * 
FROM last_tran
WHERE rn = 1
  AND tran_type = '151'
  AND (location_id_2 LIKE 'F%' OR location_id_2 LIKE 'V%')
  --AND location_id_2 = 'FOOT51014'
ORDER BY item_number, start_tran_date;