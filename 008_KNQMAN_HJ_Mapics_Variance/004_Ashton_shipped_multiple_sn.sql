
-- look for sn be shipped over two times
SELECT item_number, 
       lot_number, 
       start_tran_date, 
       CONVERT(VARCHAR(8), start_tran_time, 108) AS start_tran_time, 
       control_number_2
FROM Distribution_Warehouse_Wholesale.TranLog
WHERE wh_id = '335'
  AND tran_type = '347'
  AND start_tran_date >= '2025-01-01'
  AND start_tran_date <= GETDATE()
  AND lot_number IN (
      SELECT lot_number
      FROM Distribution_Warehouse_Wholesale.TranLog
      WHERE wh_id = '335'
        AND tran_type = '347'
        AND start_tran_date >= '2025-01-01'
        AND start_tran_date <= GETDATE()
      GROUP BY lot_number
      HAVING COUNT(*) >= 2
  )
ORDER BY  start_tran_date, start_tran_time;