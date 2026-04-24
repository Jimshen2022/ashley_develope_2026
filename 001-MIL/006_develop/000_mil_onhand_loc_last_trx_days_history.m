let
    // Base variables for SharePoint connection
    BaseUrl = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/MIL/",
    FolderPath = BaseUrl & "Shared Documents/picking location/",

    // Fetch file from SharePoint
    Source = SharePoint.Files(BaseUrl, [ApiVersion = 15]),
    TargetFile = Table.SelectRows(Source, each [Folder Path] = FolderPath and [Name] = "Picking location.xlsx"),

    // Extract Sheet1 data
    Sheet1Data = Table.SelectRows(
                    Table.ExpandTableColumn(
                        Table.AddColumn(TargetFile, "wb", each Excel.Workbook([Content])),
                        "wb", {"Data","Item"}, {"Data","Item"}
                    ),
                    each [Item] = "Sheet1")[Data]{0},

    // Promote headers and select target columns
    Result = Table.SelectColumns(
                Table.PromoteHeaders(Sheet1Data, [PromoteAllScalars=true]),
                {"LOCATION", "Building"}),

    // Extract the LOCATION column into a List data type
    LocationList = Result[LOCATION],

    // Combine the list items into a single comma-separated string (e.g., "2A0711,2A0712...")
    LocationString = Text.Combine(LocationList, ","),

    // Construct the dynamic SQL query string for Snapshot Analysis. 
    // Note: Double quotes ("") are used to escape standard quotes in M language.
    SQLQuery = "
    WITH Exclude_Locations AS (
        SELECT value AS LLOCN
        FROM STRING_SPLIT('" & LocationString & "', ',')
    ),
    oh1 AS (
        SELECT
            a1.ITNBR,
            t2.ITDSC,
            t2.ITCLS,
            t2.UNMSR,
            a1.HOUSE,
            a1.LLOCN,
            CAST(a1.SnapshotDate AS DATE) AS SnapshotDate,
            SUM(a1.LQNTY) AS ONHAND
        FROM Manufacturing_ProductionPlanning_MIL.SLQNTY_Snapshot_MIL AS a1
        LEFT JOIN (
            SELECT a.ITNBR, a.ITCLS, a.ITDSC, a.UNMSR
            FROM MasterData_ItemMaster_MIL.ITMRVA AS a
            WHERE a.STID IN ('51')
        ) AS t2 ON a1.ITNBR = t2.ITNBR
        WHERE a1.HOUSE IN ('51')
          AND a1.LLOCN NOT IN (SELECT LLOCN FROM Exclude_Locations)
        GROUP BY 
            a1.ITNBR, t2.ITDSC, t2.ITCLS, t2.UNMSR, a1.HOUSE, a1.LLOCN, CAST(a1.SnapshotDate AS DATE)
    )
    SELECT
        oh1.SnapshotDate                                        AS ""Snapshot Date"",
        oh1.ITNBR                                               AS ""Item"",
        oh1.ITDSC                                               AS ""Description"",
        oh1.ITCLS                                               AS ""Category"",
        oh1.ONHAND                                              AS ""Qty"",
        oh1.UNMSR                                               AS ""UOM"",
        oh1.LLOCN                                               AS ""Location"",
        CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112) AS ""Last Transaction Date"",
        lt.LAST_TCODE                                           AS ""Last Transaction Type"",
        CASE
            WHEN lt.LAST_UPDDT IS NULL THEN NULL
            ELSE DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate)
        END                                                     AS ""Days Since Last Movement"",
        CASE
            WHEN lt.LAST_UPDDT IS NULL THEN NULL
            WHEN DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate) <= 3 THEN '0~3 days'
            WHEN DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate) <= 7 THEN '3~7 days'
            WHEN DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate) <= 14 THEN '7~14 days'
            WHEN DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate) <= 30 THEN '14~30 days'
            WHEN DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate) <= 60 THEN '30~60 days'
            WHEN DATEDIFF(DAY, CONVERT(DATE, '20' + SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(7)), 2, 6), 112), oh1.SnapshotDate) <= 90 THEN '60~90 days'
            ELSE '90+ days'
        END                                                     AS ""Day ranges""
    FROM oh1
    OUTER APPLY (
        SELECT TOP 1
            T1.UPDDT AS LAST_UPDDT,
            T1.TCODE AS LAST_TCODE
        FROM Manufacturing_Inventory_MIL.IMHIST AS T1
        WHERE T1.HOUSE = '51'
          AND T1.TRQTY <> 0
          AND T1.ITNBR = oh1.ITNBR
          AND CONVERT(DATE, '20' + SUBSTRING(CAST(T1.UPDDT AS VARCHAR(7)), 2, 6), 112) <= oh1.SnapshotDate
        ORDER BY T1.UPDDT DESC
    ) AS lt
    ORDER BY oh1.SnapshotDate DESC, ""Days Since Last Movement"" DESC
    ",

    // Execute the native SQL query against the database
    FinalData = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [Query=SQLQuery])
in
    FinalData