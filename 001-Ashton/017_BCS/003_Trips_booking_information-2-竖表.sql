WITH LatestBookings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335'
),
FilteredData AS (
    SELECT t.*, d.tpkModified
    FROM LatestBookings AS t
    CROSS JOIN (SELECT tpkModified FROM dw_developer.tabledictionary WHERE tpktablename LIKE 'Bookings') AS d
    WHERE t.rn = 1
    --AND t.BokTripStatusCode NOT IN ('P')
    --AND t.BokContainerNumBer IN ('OOLU899910','CSNU562396')
    AND t.BokTripCreateDate > DATEADD(DAY, -90, GETDATE())
)
SELECT 
    BokTripNumBer,
    FieldName,
    FieldValue
FROM FilteredData
UNPIVOT (
    FieldValue FOR FieldName IN (
        BokPowereon,
        BokBookingID,
        BokWarehouse,
        BokBookingStatus,
        BokTripCreateDate,
        BokTripNumBer,
        BokJobID,
        BokTripStatusCode,
        BokTripType,
        BokCustomerNumber,
        BokCustomerShotName,
        BokFreightForwarderID,
        BokOceanCarrierID,
        BokLoadDate,
        BokTotalCubicFeet,
        BokContainerSize,
        BokRequiredContainerSize,
        tpkModified
    )
) AS unpvt
ORDER BY BokTripNumBer, FieldName;