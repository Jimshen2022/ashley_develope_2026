-- Step 0: 创建临时表 #BaseData 带 row_id 标识处理顺序
IF OBJECT_ID('tempdb..#BaseData') IS NOT NULL DROP TABLE #BaseData;

SELECT 
    *,
    MAX(AvailableSto) OVER (PARTITION BY ItemNumber) AS MaxAvailableSto,
    ROW_NUMBER() OVER (PARTITION BY ItemNumber ORDER BY DispatchDate, TripNumber) AS row_id,
    CAST(NULL AS INT) AS allocated_qty
INTO #BaseData
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO
WHERE SearchType = 'All Items'
  AND WhID = '335';

-- Step 1: 创建结果表
IF OBJECT_ID('tempdb..#FinalResult') IS NOT NULL DROP TABLE #FinalResult;

CREATE TABLE #FinalResult (
    WhID NVARCHAR(10),
    DispatchDate DATE,
    ItemNumber NVARCHAR(50),
    TripNumber NVARCHAR(50),
    TripNeeded INT,
    TripPicked INT,
    AvailableSto INT,
    AvailableStaged INT,
    StageQty INT,
    NoReceivedQty INT,
    YardQty INT,
    NewAsnQty INT,
    EarliestDate DATE,
    NegativeQty INT,
    NegativeTot INT,
    MFGScheduleQty INT,
    OverflowQty INT,
    OffsiteQty INT,
    Carrier NVARCHAR(50),
    InTransit INT,
    ProdQty INT,
    LocationId NVARCHAR(50),
    LdmStatus NVARCHAR(50),
    row_id INT,
    allocated_qty INT
);

-- Step 2: 循环每个 ItemNumber
DECLARE @ItemNumber NVARCHAR(50);

-- 暂存唯一ItemNumber
SELECT DISTINCT ItemNumber INTO #ItemList FROM #BaseData;

WHILE EXISTS (SELECT 1 FROM #ItemList)
BEGIN
    SELECT TOP 1 @ItemNumber = ItemNumber FROM #ItemList;

    DECLARE @remaining INT;
    SET @remaining = (SELECT TOP 1 MaxAvailableSto FROM #BaseData WHERE ItemNumber = @ItemNumber);

    DECLARE @i INT = 1;
    DECLARE @max_row INT = (SELECT MAX(row_id) FROM #BaseData WHERE ItemNumber = @ItemNumber);

    WHILE @i <= @max_row
    BEGIN
        DECLARE @TripNeeded INT;
        SET @TripNeeded = (
            SELECT TripNeeded 
            FROM #BaseData 
            WHERE ItemNumber = @ItemNumber AND row_id = @i
        );

        DECLARE @alloc INT;

        IF @remaining >= @TripNeeded
        BEGIN
            SET @alloc = @TripNeeded;
            SET @remaining = @remaining - @TripNeeded;
        END
        ELSE IF @remaining > 0
        BEGIN
            SET @alloc = @remaining;
            SET @remaining = 0;
        END
        ELSE
            SET @alloc = 0;

        -- 写入结果表
        INSERT INTO #FinalResult
        SELECT 
            WhID, DispatchDate, ItemNumber, TripNumber, TripNeeded, TripPicked, 
            AvailableSto, AvailableStaged, StageQty, NoReceivedQty, YardQty, 
            NewAsnQty, EarliestDate, NegativeQty, NegativeTot, MFGScheduleQty, 
            OverflowQty, OffsiteQty, Carrier, InTransit, ProdQty, LocationId,
            LdmStatus, row_id, @alloc
        FROM #BaseData
        WHERE ItemNumber = @ItemNumber AND row_id = @i;

        SET @i = @i + 1;
    END

    -- 处理完该 ItemNumber，移除
    DELETE FROM #ItemList WHERE ItemNumber = @ItemNumber;
END

-- Step 3: 获取 refreshed_time
; WITH RefreshTime AS (
    SELECT TOP 1 tpkModified AS refreshed_time
    FROM dw_developer.tabledictionary
    WHERE tpktablename = 'TripAvailableSTO'
)

-- Step 4: 最终输出
SELECT 
    f.WhID as [Wh Id],
    f.DispatchDate as [Dispatch Date],
    f.ItemNumber as [Item Number],
    f.TripNumber as [Trip Number],
    f.LdmStatus,
    f.TripNeeded as [Trip Needed],
    f.TripPicked as [Trip Picked],
    f.AvailableSto as [Available Sto],
    f.AvailableStaged AS [Available Staged],
    f.StageQty as [Stage Qty],
    f.NoReceivedQty as [No Received Qty],
    f.YardQty as [Yard Qty],
    f.NewAsnQty as [New Asn Qty],
    f.EarliestDate as [Earliest Date],
    f.NegativeQty as [Negative Qty],
    f.NegativeTot as [Negative Tot],
    f.MFGScheduleQty as [MFG Schedule Qty],
    f.OverflowQty as [Overflow Qty],
    f.OffsiteQty as [Offsite Qty],
    f.Carrier,
    f.InTransit as [In Transit],
    f.ProdQty as [Prod Qty],
    f.LocationId as [Location Id],
    f.allocated_qty,
    rt.refreshed_time
FROM #FinalResult f
CROSS JOIN RefreshTime rt
ORDER BY f.ItemNumber, f.DispatchDate, f.TripNumber;
