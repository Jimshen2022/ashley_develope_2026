-- Calculate the date once and reuse it
DECLARE @RecentDate DATE = DATEADD(DAY, -380, GETDATE());
DECLARE @RecentTranDate DATE = DATEADD(DAY, -60, GETDATE());

-- Use a temp table for MaxEnteredYard
SELECT
    wh_id,
    equipment_id,
    MAX(entered_yard) AS max_entered_yard
INTO #MaxEnteredYard
FROM
    Distribution_Warehouse_Wholesale.Trailer
WHERE
    wh_id IN ('35', '31', '33', '34')
    AND entered_yard >= @RecentDate
GROUP BY
    wh_id, equipment_id;

-- Use a temp table for container details
SELECT
    t1.wh_id,
    t1.equipment_id,
    t1.trailer_type_id,
    t1.entered_yard,
    CASE
        WHEN t1.trailer_type_id = '86' THEN '20FT'
        WHEN t1.trailer_type_id = '87' THEN '40FT'
        WHEN t1.trailer_type_id = '88' THEN '45FT'
        WHEN t1.trailer_type_id = '177' THEN '40H'
        WHEN t1.trailer_type_id = '324' THEN '53FT'
        ELSE '40H'
    END AS Ctn_size
INTO #ContainerDetails
FROM
    Distribution_Warehouse_Wholesale.Trailer t1
INNER JOIN #MaxEnteredYard mey ON
    t1.wh_id = mey.wh_id
    AND t1.equipment_id = mey.equipment_id
    AND t1.entered_yard = mey.max_entered_yard;

-- Use a temp table for Item Data
SELECT
    T1.ITNBR,
    T1.ITMITCLS AS ITCLS,
    T1.ITMWEGHT AS WEGHT,
    T1.CUBES AS Unit_Cube
INTO #ItemData
FROM MasterData_ItemMaster_AFI.ITMEXT AS T1;

-- Use a temp table for Trip and container details
SELECT DISTINCT
    t1.control_number_2 AS trip_nbr,
    t1.wh_id,
    t1.routing_code AS ctn_nbr,
    t1.start_tran_date,
    ctn.Ctn_size
INTO #TripContainer
FROM
    Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN #ContainerDetails AS ctn ON
    ctn.equipment_id = t1.routing_code AND ctn.wh_id = t1.wh_id
WHERE
    t1.wh_id IN ('35', '31', '33', '34')
    AND t1.start_tran_date >= @RecentDate
    AND t1.tran_type = '361';

-- Use a temp table for Mixed or None-Mixed container type
SELECT
    b1.wh_id,
    b1.container#,
    b1.trip_nbr,
    COUNT(DISTINCT b1.Product) AS Product_Category_Qty,
    COUNT(DISTINCT b1.item_number) AS SKUs,
    CASE
        WHEN COUNT(DISTINCT b1.Product) = 1 THEN 'None-Mixed'
        ELSE 'Mixed'
    END AS ContainerType
INTO #MixedContainer
FROM (
    SELECT
        t1.wh_id,
        t1.item_number,
        CASE
            WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A', 'B', 'D', 'E', 'G', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
            ELSE 'UPH'
        END AS Product,
        t1.routing_code AS container#,
        t1.control_number_2 AS trip_nbr
    FROM
        Distribution_Warehouse_Wholesale.TranLog AS t1
    LEFT JOIN #ItemData AS itm ON t1.item_number = itm.ITNBR
    WHERE
        t1.wh_id IN ('35', '31', '33', '34')
        AND t1.start_tran_date >= @RecentTranDate
        AND t1.tran_type = '361'
) AS b1
GROUP BY
    b1.wh_id, b1.container#, b1.trip_nbr;

-- Main query
SELECT
    t1.tran_type,
    t1.start_tran_date,
    t1.wh_id,
    t1.item_number,
    CASE
        WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A', 'B', 'D', 'E', 'G', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
        ELSE 'UPH'
    END AS PRODUCT,
    t1.routing_code AS CONTAINER#,
    CONCAT(CAST(t1.control_number_2 AS VARCHAR), '_', t1.routing_code) AS trip_ctn,
    tp.Ctn_size,
    t1.control_number_2 AS TRIP#,
    m.ContainerType,
    m.SKUs,
    CASE
        WHEN m.ContainerType = 'None-Mixed' THEN
            CASE
                WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A', 'B', 'D', 'E', 'G', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
                ELSE 'UPH'
            END
        ELSE m.ContainerType
    END AS Cont_Categories,
    itm.Unit_Cube,
    SUM(t1.tran_qty) AS tran_qty,
    itm.Unit_Cube * SUM(t1.tran_qty) AS CUBES
FROM
    Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN #ItemData AS itm ON t1.item_number = itm.ITNBR
LEFT JOIN #MixedContainer AS m ON t1.routing_code = m.container# AND t1.control_number_2 = m.trip_nbr
LEFT JOIN #TripContainer AS tp ON t1.control_number_2 = tp.trip_nbr AND t1.wh_id = tp.wh_id AND t1.routing_code = tp.ctn_nbr
WHERE
    t1.wh_id IN ('35', '31', '33', '34')
    AND t1.start_tran_date >= @RecentTranDate
    AND t1.tran_type = '361'
GROUP BY
    t1.tran_type,
    t1.start_tran_date,
    t1.wh_id,
    t1.item_number,
    CASE
        WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A', 'B', 'D', 'E', 'G', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
        ELSE 'UPH'
    END,
    t1.routing_code,
    CONCAT(CAST(t1.control_number_2 AS VARCHAR), '_', t1.routing_code),
    tp.Ctn_size,
    t1.control_number_2,
    m.ContainerType,
    m.SKUs,
    CASE
        WHEN m.ContainerType = 'None-Mixed' THEN
            CASE
                WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A', 'B', 'D', 'E', 'G', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
                ELSE 'UPH'
            END
        ELSE m.ContainerType
    END,
    itm.Unit_Cube
ORDER BY
    t1.start_tran_date, t1.control_number_2, t1.item_number;

-- Drop temp tables when done using older SQL Server compatible syntax
IF OBJECT_ID('tempdb..#MaxEnteredYard') IS NOT NULL
    DROP TABLE #MaxEnteredYard;

IF OBJECT_ID('tempdb..#ContainerDetails') IS NOT NULL
    DROP TABLE #ContainerDetails;

IF OBJECT_ID('tempdb..#ItemData') IS NOT NULL
    DROP TABLE #ItemData;

IF OBJECT_ID('tempdb..#TripContainer') IS NOT NULL
    DROP TABLE #TripContainer;

IF OBJECT_ID('tempdb..#MixedContainer') IS NOT NULL
    DROP TABLE #MixedContainer;

