
WITH LatestBookings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335'
)
SELECT 
       t.BokTripNumBer,
       t.BokTripStatusCode,
       t.BokTripType,
       t.BokTripCreateDate,
       t.BokBookingNumber, 
       CONCAT(t.BokContainerNumBer, t.BokContainerNumberCheckDigit) AS ContainerNumber,
       t.BoksealNo,
       t.BokContainerSize,
       t.BokCustomerNumber,
       t.BokCustomerShipto,
       t.BokTruckingCompany,
       t.BokDispatchDate,
       t.BokContainerYardCutoffDate,
       t.BokUsername,
       d.tpkModified as data_whse_refreshed_date

FROM LatestBookings AS t
CROSS JOIN (SELECT tpkModified FROM dw_developer.tabledictionary WHERE tpktablename LIKE 'Bookings') AS d
WHERE t.rn = 1
--AND t.BokTripStatusCode NOT IN ('P')
--AND t.BokContainerNumBer IN ('OOLU899910','CSNU562396')
AND t.BokTripNumBer = '42226'
  AND t.dtea > DATEADD(DAY, -40, GETDATE())
ORDER BY t.BokTripNumBer, t.BokTripCreateDate;