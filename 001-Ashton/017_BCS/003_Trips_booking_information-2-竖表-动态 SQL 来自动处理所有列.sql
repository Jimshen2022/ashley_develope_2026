DECLARE @sql NVARCHAR(MAX)
DECLARE @columns NVARCHAR(MAX)

-- 获取所有需要转换的列名（排除不需要转换的列如 rn）
SELECT @columns = STRING_AGG(COLUMN_NAME, ',')
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Bookings' 
AND COLUMN_NAME NOT IN ('rn')  -- 排除不需要的列

-- 构建动态SQL
SET @sql = '
WITH LatestBookings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = ''335''
),
FilteredData AS (
    SELECT t.*, d.tpkModified
    FROM LatestBookings AS t
    CROSS JOIN (SELECT tpkModified FROM dw_developer.tabledictionary WHERE tpktablename LIKE ''Bookings'') AS d
    WHERE t.rn = 1
    --AND t.BokTripStatusCode NOT IN (''P'')
    AND t.BokContainerNumBer IN (''OOLU899910'',''CSNU562396'')
    AND t.BokTripCreateDate > DATEADD(DAY, -120, GETDATE())
)
SELECT 
    BokTripNumBer,
    FieldName,
    FieldValue
FROM FilteredData
UNPIVOT (
    FieldValue FOR FieldName IN (' + @columns + ')
) AS unpvt
ORDER BY BokTripNumBer, FieldName'

EXEC sp_executesql @sql