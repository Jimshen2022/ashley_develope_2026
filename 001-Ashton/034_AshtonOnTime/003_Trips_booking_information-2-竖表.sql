WITH LatestBookings AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335'
)
SELECT t.*, d.tpkModified
FROM LatestBookings AS t
CROSS JOIN (SELECT tpkModified FROM dw_developer.tabledictionary WHERE tpktablename LIKE 'Bookings') AS d
WHERE t.rn = 1
AND t.BokTripStatusCode NOT IN ('P')
AND t.BokTripCreateDate > '2025-09-01'
ORDER BY t.BokTripNumBer, t.BokTripCreateDate;