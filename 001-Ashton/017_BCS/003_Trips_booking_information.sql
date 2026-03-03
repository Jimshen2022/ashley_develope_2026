

with ci AS
(select * from Distribution_Warehouse_Wholesale.YaTranLog 
where wh_id = '335' 
    and tran_type='101' 
),  
LatestBookings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335'
)
SELECT t.*, d.tpkModified,ci.started as checkin_datetime, ci.destination_location  
FROM LatestBookings AS t
CROSS JOIN (SELECT tpkModified FROM dw_developer.tabledictionary WHERE tpktablename LIKE 'Bookings') AS d
LEFT JOIN ci ON t.BokContainerNumBer = ci.carrier_trailer_number
WHERE t.rn = 1
--AND t.BokTripStatusCode NOT IN ('P')
AND t.BokContainerNumBer LIKE 'TIIU711013%'
--AND t.BokTripNumBer = '4259'
  AND t.BokTripCreateDate > DATEADD(DAY, -30, GETDATE())
ORDER BY t.BokTripNumBer, t.BokTripCreateDate;





