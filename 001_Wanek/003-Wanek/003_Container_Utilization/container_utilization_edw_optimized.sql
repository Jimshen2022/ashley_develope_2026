-- 声明参数
DECLARE @ContainerDetailsStartDate DATE = DATEADD(DAY, -65, CAST(GETDATE() AS DATE));
DECLARE @ContainerDetailsEndDate DATE = CAST(GETDATE() AS DATE);
DECLARE @HeaderDetailsStartDate DATE = DATEADD(DAY, -60, CAST(GETDATE() AS DATE));
DECLARE @HeaderDetailsEndDate DATE = CAST(GETDATE() AS DATE);

WITH ContainerDetails AS (
    SELECT 
        LTRIM(RTRIM(a.WCICONTAINERNUMBER)) AS ContainerNumber,
        a.WCIORIGIN, 
        a.WCIDESTINATION, 
        a.WCIORDER, 
        LTRIM(RTRIM(a.WCIITEMNUMBER)) AS ItemNumber, 
        a.WCIQUANTITYLOADED AS Qty,
        a.WCILASTMAINTENANCETIMESTAMP, 
        a.WCILASTMAINTENANCEUSER, 
        b.ITMCQTY, 
        c.itcls, 
        c.B2Z95S AS UnitCube, 
        c.WEGHT AS UnitWeight, 
        a.WCIQUANTITYLOADED * c.B2Z95S AS Cubes,
        CEILING(CAST(a.WCIQUANTITYLOADED AS FLOAT) / b.ITMCQTY) AS Cartons,
        LTRIM(RTRIM(a.WCIORIGIN)) + '-' + LTRIM(RTRIM(a.WCICONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCIDESTINATION)) AS [Container#],
        CASE 
            WHEN a.WCIITEMNUMBER LIKE 'B%' THEN 'CG'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%K' THEN 'Un-Kits'
            WHEN c.ITCLS LIKE 'Z%Z' THEN 'ZipperCover'
            ELSE 'UPH' 
        END AS Product,
        NULL AS ArchiveTimestamp
    FROM Manufacturing_ProductionPlanning_WNK.WVCNTID a
    JOIN MasterData_ItemMaster_WNK.ITMEXT b ON a.WCIITEMNUMBER = b.itnbr
    JOIN MasterData_ItemMaster_WNK.ITMRVA c ON a.WCIITEMNUMBER = c.itnbr AND a.WCIORIGIN = c.STID
    WHERE a.WCIORIGIN IN ('35','33')
      AND a.WCILASTMAINTENANCETIMESTAMP >= @ContainerDetailsStartDate
      AND a.WCILASTMAINTENANCETIMESTAMP <= @ContainerDetailsEndDate
      AND LEFT(LTRIM(RTRIM(a.WCICONTAINERNUMBER)), 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')

    UNION ALL

    SELECT 
        LTRIM(RTRIM(a.WCICONTAINERNUMBER)),
        a.WCIORIGIN, 
        a.WCIDESTINATION, 
        a.WCIORDER, 
        LTRIM(RTRIM(a.WCIITEMNUMBER)), 
        a.WCIQUANTITYLOADED,
        a.WCILASTMAINTENANCETIMESTAMP, 
        a.WCILASTMAINTENANCEUSER, 
        b.ITMCQTY, 
        c.itcls, 
        c.B2Z95S, 
        c.WEGHT, 
        a.WCIQUANTITYLOADED * c.B2Z95S,
        CEILING(CAST(a.WCIQUANTITYLOADED AS FLOAT) / b.ITMCQTY),
        LTRIM(RTRIM(a.WCIORIGIN)) + '-' + LTRIM(RTRIM(a.WCICONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCIDESTINATION)) + '-' + LEFT(CONVERT(VARCHAR(23), a.WCIARCHIVETIMESTAMP, 121), 13),
        CASE 
            WHEN a.WCIITEMNUMBER LIKE 'B%' THEN 'CG'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%K' THEN 'Un-Kits'
            WHEN c.ITCLS LIKE 'Z%Z' THEN 'ZipperCover'
            ELSE 'UPH' 
        END,
        a.WCIARCHIVETIMESTAMP
    FROM Manufacturing_ProductionPlanning_WNK.WVCNTIDA a
    JOIN MasterData_ItemMaster_WNK.ITMEXT b ON a.WCIITEMNUMBER = b.itnbr
    JOIN MasterData_ItemMaster_WNK.ITMRVA c ON a.WCIITEMNUMBER = c.itnbr AND a.WCIORIGIN = c.STID
    WHERE a.WCIORIGIN IN ('35','33')
      AND a.WCILASTMAINTENANCETIMESTAMP >= @ContainerDetailsStartDate
      AND a.WCILASTMAINTENANCETIMESTAMP <= @ContainerDetailsEndDate
      AND LEFT(LTRIM(RTRIM(a.WCICONTAINERNUMBER)), 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')
),
ContainerType AS (
    SELECT 
        [Container#],
        CASE WHEN COUNT(DISTINCT Product) = 1 THEN 'None-Mixed' ELSE 'Mixed' END AS ContainerType
    FROM ContainerDetails
    GROUP BY [Container#]
),
HeaderDetails AS (
    SELECT 
        LTRIM(RTRIM(a.WCHCONTAINERNUMBER)) AS ContainerNumber,
        a.WCHCONTAINERSIZE,
        a.WCHDOORNUMBER,
        a.WCHBUILDING,
        a.WCHPOSTEDTIMESTAMP,
        LTRIM(RTRIM(a.WCHORIGIN)) + '-' + LTRIM(RTRIM(a.WCHCONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCHDESTINATION)) AS [Container#],
        a.WCHTOTALCUBES as H_Cubes,
        a.WCHCLOSEDUSER,
        NULL AS ArchiveTimestamp
    FROM Manufacturing_ProductionPlanning_WNK.WVCNTHD a
    WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a.WCHORIGIN IN ('35','33')
      AND (a.WCHACTUALARRIVALMAINTPROGRAM='SVCHECKIN' 
      OR (a.WCHACTUALARRIVALMAINTPROGRAM <> 'SVCHECKIN' AND a.WCHBUILDING IN ('B1','B2','V3','M3','K1','33')))
      AND a.WCHBUILDING <> 'B5'
      AND a.WCHPOSTEDTIMESTAMP >= @HeaderDetailsStartDate
      AND a.WCHPOSTEDTIMESTAMP <= @HeaderDetailsEndDate
      AND a.WCHCONTAINERNUMBER NOT LIKE 'AIR%'
      AND a.WCHDESTINATION NOT IN ('100', '101', '12', '131', '01', '3', '990')
      AND LEFT(LTRIM(RTRIM(a.WCHCONTAINERNUMBER)), 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')

    UNION ALL

    SELECT 
        LTRIM(RTRIM(a.WCHCONTAINERNUMBER)),
        a.WCHCONTAINERSIZE,
        a.WCHDOORNUMBER,
        a.WCHBUILDING,
        a.WCHPOSTEDTIMESTAMP,
        LTRIM(RTRIM(a.WCHORIGIN)) + '-' + LTRIM(RTRIM(a.WCHCONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCHDESTINATION)) + '-' + LEFT(CONVERT(VARCHAR(23), a.WCHARCHIVETIMESTAMP, 121), 13),
        a.WCHTOTALCUBES,
        a.WCHCLOSEDUSER,
        a.WCHARCHIVETIMESTAMP
    FROM Manufacturing_ProductionPlanning_WNK.WVCNTHDA a
    WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a.WCHORIGIN IN ('35','33')
      AND (a.WCHACTUALARRIVALMAINTPROGRAM='SVCHECKIN' 
      OR (a.WCHACTUALARRIVALMAINTPROGRAM <> 'SVCHECKIN' AND a.WCHBUILDING IN ('B1','B2','V3','M3','K1','33')))
      AND a.WCHBUILDING <> 'B5'
      AND a.WCHPOSTEDTIMESTAMP >= @HeaderDetailsStartDate
      AND a.WCHPOSTEDTIMESTAMP <= @HeaderDetailsEndDate
      AND a.WCHCONTAINERNUMBER NOT LIKE 'AIR%'
      AND a.WCHDESTINATION NOT IN ('100', '101', '12', '131', '01', '3', '990')
      AND LEFT(LTRIM(RTRIM(a.WCHCONTAINERNUMBER)), 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')
)
SELECT 
    d.WCIORIGIN,
    d.[Container#],
    d.Cubes,
    d.itcls,
    d.Product,
    d.WCIDESTINATION,
    d.WCIORDER,
    d.ItemNumber,
    d.Qty,
    d.WCILASTMAINTENANCETIMESTAMP,
    d.ContainerNumber,
    t.ContainerType,
    d.WCILASTMAINTENANCEUSER,
    d.ITMCQTY,
    d.UnitCube,
    d.UnitWeight,
    d.Cartons,
    h.WCHCONTAINERSIZE,
    h.WCHDOORNUMBER,
    h.WCHBUILDING,
    h.H_Cubes,
    h.WCHCLOSEDUSER,
    h.[Container#] AS H_Container#,
    h.WCHPOSTEDTIMESTAMP,
    CONVERT(VARCHAR(10), h.WCHPOSTEDTIMESTAMP, 120) AS [Date],
    CASE 
        WHEN LEFT(LTRIM(RTRIM(h.WCHCONTAINERSIZE)), 2) = '53' THEN d.Cubes / 3831
        WHEN LEFT(LTRIM(RTRIM(h.WCHCONTAINERSIZE)), 2) = '50' THEN d.Cubes / 3333
        WHEN LEFT(LTRIM(RTRIM(h.WCHCONTAINERSIZE)), 3) = '40H' THEN d.Cubes / 2650
        WHEN LEFT(LTRIM(RTRIM(h.WCHCONTAINERSIZE)), 3) = '40' THEN d.Cubes / 2383
        WHEN LEFT(LTRIM(RTRIM(h.WCHCONTAINERSIZE)), 3) = '45' THEN d.Cubes / 3058
        WHEN LEFT(h.WCHCONTAINERSIZE, 1) = '2' THEN d.Cubes / 1191
        ELSE d.Cubes / 2650 
    END AS Utilization,
    CASE 
        WHEN d.[Container#] LIKE '31%' THEN 'WN1'
        WHEN d.[Container#] LIKE '33%' THEN 'WN2'
        WHEN d.[Container#] LIKE '35%' AND LTRIM(RTRIM(h.WCHDOORNUMBER)) LIKE '4%' THEN 'WN3'
        WHEN d.[Container#] LIKE '35%' AND LTRIM(RTRIM(h.WCHDOORNUMBER)) LIKE '9%' THEN 'WN2'
        WHEN d.[Container#] LIKE '35%' AND LTRIM(RTRIM(h.WCHDOORNUMBER)) LIKE '8%' THEN 'DC'
        WHEN d.[Container#] LIKE '35%' AND LTRIM(RTRIM(h.WCHDOORNUMBER)) LIKE '1%' THEN 'WN5'
        WHEN d.[Container#] LIKE '35%' AND h.WCHBUILDING IN ('B1', 'B2') THEN 'WN2'
        WHEN d.[Container#] LIKE '35%' AND h.WCHBUILDING = 'V3' THEN 'WN3'
        WHEN d.[Container#] LIKE '35%' AND h.WCHBUILDING = 'M3' THEN 'DC'
        WHEN d.[Container#] LIKE '35%' AND h.WCHBUILDING = 'K1' THEN 'WN5'
        ELSE 'CHECK'
    END AS WH
FROM ContainerDetails d
JOIN ContainerType t ON d.[Container#] = t.[Container#]
RIGHT JOIN HeaderDetails h ON d.[Container#] = h.[Container#]
WHERE d.[Container#] IS NOT NULL
ORDER BY d.WCIORIGIN, d.ContainerNumber, d.WCILASTMAINTENANCETIMESTAMP
OPTION (MAXDOP 4);
