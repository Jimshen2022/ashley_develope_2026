SELECT a.[tran_type]
      ,a.[start_tran_date]
      ,a.[wh_id]
      ,CAST(LEFT(a.trip_number, CHARINDEX('-', a.trip_number + '-') - 1) AS INT) AS trip_number
      ,SUM(a.[tran_qty]) AS Qty
FROM (
    SELECT [tran_type]
          ,CAST([start_tran_date] AS DATE) AS [start_tran_date]
          ,[control_number_2] AS trip_number
          ,[wh_id]
          ,[tran_qty]
    FROM [PowerBI_Distribution].[TranLog]
    WHERE tran_type IN ('321', '621')
          AND start_tran_date > DATEADD(DAY, -180, GETDATE())
          AND [wh_id] IN ('335')
) a
GROUP BY a.[tran_type], a.[start_tran_date], a.[wh_id], LEFT(a.trip_number, CHARINDEX('-', a.trip_number + '-') - 1)
ORDER BY a.start_tran_date


SELECT TOP 10 * 
FROM [PowerBI_Distribution].[TranLog]
WHERE tran_type IN ('321', '621')
    AND start_tran_date > DATEADD(DAY, -180, GETDATE())
    AND [wh_id] IN ('335')