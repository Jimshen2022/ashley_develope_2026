SELECT  *
FROM [PowerBI_Distribution].[OSHAPreOperationalChecklist] AS t1
WHERE t1.WarehouseID IN ('335')
AND CAST(t1.PerformedAt AS DATE) BETWEEN CAST(DATEADD(DAY, -7, GETDATE()) AS DATE) AND CAST(GETDATE() AS DATE)


SELECT *, CAST(t1.PerformedAt AS DATE) AS Performed_Date
FROM [PowerBI_Distribution].[OSHAPreOperationalChecklist] AS t1
WHERE t1.WarehouseID IN ('355','31','51') AND CAST(t1.PerformedAt AS DATE) BETWEEN CAST(DATEADD(DAY, -90, GETDATE()) AS DATE) AND CAST(GETDATE() AS DATE)


SELECT  *
FROM [PowerBI_Distribution].[OSHAPreOperationalChecklist] T1
WHERE T1.WarehouseID IN ('335','51','35','33')
and CAST(t1.PerformedAt AS DATE) = CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)