SELECT TOP 10 *,
        -- 计算 LoadDate 对应的周六
        DATEADD(DAY, 6 - DATEPART(WEEKDAY, t.LoadDate), t.LoadDate) AS SaturdayDate,
        -- 计算当前周六
        DATEADD(DAY, 6 - DATEPART(WEEKDAY, GETDATE()), GETDATE()) AS CurrentSaturday,
        CAST(LEFT(t.LoadID, 7) AS INT) AS trip_nbr  FROM Distribution_Warehouse_Wholesale.TripReport  as t  WHERE t.WhID = '335' AND t.TripStatus NOT IN ('S','X')



SELECT * FROM Distribution_Warehouse_Wholesale.TripReport  as t  WHERE t.WhID = '335'  and t.LoadID like '%15133%'


SELECT top 1000 * FROM Manufacturing_ProductionPlanning_AFI.ReasonChangeCodes


SELECT TOP 10 * 
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '335' and t3.tran_type='347' and t3.start_tran_date > '2025-04-01' 