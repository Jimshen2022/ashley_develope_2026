WITH Parameters AS (
    SELECT
        -- 明细表时间窗口：2025-01-01 07:00:00 ~ 今天早上 06:59:59
        TIMESTAMP('2025-01-01', '07:00:00') AS StartDate_Details,
        TIMESTAMP(CURRENT DATE, '06:59:59') AS EndDate_Details,

        -- 头表时间窗口（同样逻辑）
        TIMESTAMP('2025-01-01', '07:00:00') AS StartDate_Header,
        TIMESTAMP(CURRENT DATE, '06:59:59') AS EndDate_Header
    FROM SYSIBM.SYSDUMMY1
),
ContainerDetails AS (
    SELECT 
        TRIM(a.WCICONTAINERNUMBER) AS ContainerNumber,
        a.WCIORIGIN, 
        a.WCIDESTINATION, 
        a.WCIORDER, 
        TRIM(a.WCIITEMNUMBER) AS ItemNumber, 
        a.WCIQUANTITYLOADED AS Qty,
        a.WCILASTMAINTENANCETIMESTAMP, 
        a.WCILASTMAINTENANCEUSER, 
        b.ITMCQTY, 
        c.itcls, 
        c.B2Z95S AS UnitCube, 
        c.WEGHT AS UnitWeight, 
        a.WCIQUANTITYLOADED * c.B2Z95S AS Cubes,
        CEIL(a.WCIQUANTITYLOADED / b.ITMCQTY) AS Cartons,
        TRIM(a.WCIORIGIN) || '-' || TRIM(a.WCICONTAINERNUMBER) || '-' || TRIM(a.WCIDESTINATION) AS Container#,
        CASE 
            WHEN a.WCIITEMNUMBER LIKE 'B%' THEN 'CG'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%' AND c.ITCLS LIKE '%K' THEN 'Un-Kits'
            WHEN c.ITCLS LIKE 'Z%' AND c.ITCLS LIKE '%Z' THEN 'ZipperCover'
            ELSE 'UPH' 
        END AS Product
    FROM DISTLIBW.TBL_WVCONTAINER_DTL_ITM a
    JOIN Parameters p ON 1 = 1
    JOIN AFILELIBW.ITMEXT b ON a.WCIITEMNUMBER = b.itnbr
    JOIN AMFLIBW.ITMRVA c ON a.WCIITEMNUMBER = c.itnbr AND a.WCIORIGIN = c.STID
    WHERE a.WCIORIGIN IN ('35','33','36')
      AND a.WCILASTMAINTENANCETIMESTAMP BETWEEN p.StartDate_Details AND p.EndDate_Details
      AND SUBSTR(TRIM(a.WCICONTAINERNUMBER), 1, 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')

    UNION ALL

    SELECT 
        TRIM(a.WCICONTAINERNUMBER) AS ContainerNumber,
        a.WCIORIGIN, 
        a.WCIDESTINATION, 
        a.WCIORDER, 
        TRIM(a.WCIITEMNUMBER) AS ItemNumber, 
        a.WCIQUANTITYLOADED AS Qty,
        a.WCILASTMAINTENANCETIMESTAMP, 
        a.WCILASTMAINTENANCEUSER, 
        b.ITMCQTY, 
        c.itcls, 
        c.B2Z95S AS UnitCube, 
        c.WEGHT AS UnitWeight, 
        a.WCIQUANTITYLOADED * c.B2Z95S AS Cubes,
        CEIL(a.WCIQUANTITYLOADED / b.ITMCQTY) AS Cartons,
        TRIM(a.WCIORIGIN) || '-' || TRIM(a.WCICONTAINERNUMBER) || '-' || TRIM(a.WCIDESTINATION) || '-' || SUBSTR(CHAR(a.WCIARCHIVETIMESTAMP), 1, 13) AS Container#,
        CASE 
            WHEN a.WCIITEMNUMBER LIKE 'B%' THEN 'CG'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%' AND c.ITCLS LIKE '%K' THEN 'Un-Kits'
            WHEN c.ITCLS LIKE 'Z%' AND c.ITCLS LIKE '%Z' THEN 'ZipperCover'
            ELSE 'UPH' 
        END AS Product
    FROM ASHLEYARCW.TBL_WVCONTAINER_DTL_ITM_A a
    JOIN Parameters p ON 1 = 1
    JOIN AFILELIBW.ITMEXT b ON a.WCIITEMNUMBER = b.itnbr
    JOIN AMFLIBW.ITMRVA c ON a.WCIITEMNUMBER = c.itnbr AND a.WCIORIGIN = c.STID
    WHERE a.WCIORIGIN IN ('35','33','36')
      AND a.WCILASTMAINTENANCETIMESTAMP BETWEEN p.StartDate_Details AND p.EndDate_Details
      AND SUBSTR(TRIM(a.WCICONTAINERNUMBER), 1, 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')
),
ContainerType AS (
    SELECT 
        Container#,
        CASE WHEN COUNT(DISTINCT Product) = 1 THEN 'None-Mixed' ELSE 'Mixed' END AS ContainerType
    FROM ContainerDetails
    GROUP BY Container#
),
HeaderDetails AS (
    SELECT DISTINCT
        TRIM(a.WCHCONTAINERNUMBER) AS ContainerNumber,
        a.WCHCONTAINERSIZE,
        a.WCHDOORNUMBER,
        a.WCHBUILDING,
        a.WCHPOSTEDTIMESTAMP,
        TRIM(a.WCHORIGIN) || '-' || TRIM(a.WCHCONTAINERNUMBER) || '-' || TRIM(a.WCHDESTINATION) AS Container#,
        a.WCHTOTALCUBES as H_Cubes,
        a.WCHCLOSEDUSER
    FROM DISTLIBW.TBL_WVCONTAINER_HDR a
    JOIN Parameters p ON 1 = 1
    WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a.WCHORIGIN IN ('35','33','36')
      AND (a.WCHACTUALARRIVALMAINTPROGRAM = 'SVCHECKIN' 
           OR (a.WCHACTUALARRIVALMAINTPROGRAM NOT IN ('SVCHECKIN') 
               AND a.WCHBUILDING IN ('B1','B2','V3','M3','K1','33','A2')))
      AND a.WCHBUILDING <> 'B5'
      AND a.WCHPOSTEDTIMESTAMP BETWEEN p.StartDate_Header AND p.EndDate_Header
      AND a.WCHCONTAINERNUMBER NOT LIKE 'AIR%'
      AND a.WCHDESTINATION NOT IN ('100', '101', '12', '131', '01', '3', '990')
      AND SUBSTR(TRIM(a.WCHCONTAINERNUMBER), 1, 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')

    UNION ALL

    SELECT 
        TRIM(a.WCHCONTAINERNUMBER) AS ContainerNumber,
        a.WCHCONTAINERSIZE,
        a.WCHDOORNUMBER,
        a.WCHBUILDING,
        a.WCHPOSTEDTIMESTAMP,
        TRIM(a.WCHORIGIN) || '-' || TRIM(a.WCHCONTAINERNUMBER) || '-' || TRIM(a.WCHDESTINATION) || '-' || SUBSTR(CHAR(a.WCHARCHIVETIMESTAMP), 1, 13) AS Container#,
        a.WCHTOTALCUBES as H_Cubes,
        a.WCHCLOSEDUSER
    FROM ASHLEYARCW.TBL_WVCONTAINER_HDR_A a
    JOIN Parameters p ON 1 = 1
    WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a.WCHORIGIN IN ('35','33','36')
      AND (a.WCHACTUALARRIVALMAINTPROGRAM = 'SVCHECKIN' 
           OR (a.WCHACTUALARRIVALMAINTPROGRAM NOT IN ('SVCHECKIN') 
               AND a.WCHBUILDING IN ('B1','B2','V3','M3','K1','33','A2')))
      AND a.WCHBUILDING <> 'B5'
      AND a.WCHPOSTEDTIMESTAMP BETWEEN p.StartDate_Header AND p.EndDate_Header
      AND a.WCHCONTAINERNUMBER NOT LIKE 'AIR%'
      AND a.WCHDESTINATION NOT IN ('100', '101', '12', '131', '01', '3', '990')
      AND SUBSTR(TRIM(a.WCHCONTAINERNUMBER), 1, 4) NOT IN ('AAAR', 'AIIR', 'AAIR', 'AIRR', 'AIR_', 'AIR1', 'AAII', 'ARRR')
)
SELECT 
    d.WCIORIGIN,
    d.Container#,
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
    h.Container#,
    h.WCHPOSTEDTIMESTAMP,
    TO_CHAR(h.WCHPOSTEDTIMESTAMP, 'yyyy-mm-dd') AS Date,

    -- ★ 新增：Shift（D/N 班）
    CASE 
        WHEN (HOUR(h.WCHPOSTEDTIMESTAMP) * 10000 
              + MINUTE(h.WCHPOSTEDTIMESTAMP) * 100 
              + SECOND(h.WCHPOSTEDTIMESTAMP)) BETWEEN 70000 AND 185959
        THEN 'D'      -- 07:00:00 ~ 18:59:59
        ELSE 'N'      -- 19:00:00 ~ 次日 06:59:59
    END AS shift,

    -- ★ 新增：Shift_Date
    --   00:00:00 ~ 06:59:59 用前一天日期，其它用当天
    CASE 
        WHEN (HOUR(h.WCHPOSTEDTIMESTAMP) * 10000 
              + MINUTE(h.WCHPOSTEDTIMESTAMP) * 100 
              + SECOND(h.WCHPOSTEDTIMESTAMP)) BETWEEN 0 AND 65959
        THEN DATE(h.WCHPOSTEDTIMESTAMP) - 1 DAY
        ELSE DATE(h.WCHPOSTEDTIMESTAMP)
    END AS shift_date,

    CASE 
        WHEN TRIM(SUBSTR(h.WCHCONTAINERSIZE, 1, 2)) = '53' THEN d.Cubes / 3831
        WHEN TRIM(SUBSTR(h.WCHCONTAINERSIZE, 1, 2)) = '50' THEN d.Cubes / 3333
        WHEN TRIM(SUBSTR(h.WCHCONTAINERSIZE, 1, 3)) = '40H' THEN d.Cubes / 2650
        WHEN TRIM(SUBSTR(h.WCHCONTAINERSIZE, 1, 3)) = '40' THEN d.Cubes / 2383
        WHEN TRIM(SUBSTR(h.WCHCONTAINERSIZE, 1, 3)) = '45' THEN d.Cubes / 3058
        WHEN SUBSTR(h.WCHCONTAINERSIZE, 1, 1) = '2' THEN d.Cubes / 1191
        ELSE d.Cubes / 2650 
    END AS Utilization,
    CASE 
        WHEN d.Container# LIKE '36%' THEN 'WN5'
        WHEN d.Container# LIKE '31%' THEN 'WN1'
        WHEN d.Container# LIKE '33%' THEN 'WN2'
        WHEN d.Container# LIKE '35%' AND TRIM(h.WCHDOORNUMBER) LIKE '4%' THEN 'WN3'
        WHEN d.Container# LIKE '35%' AND TRIM(h.WCHDOORNUMBER) LIKE '9%' THEN 'WN2'
        WHEN d.Container# LIKE '35%' AND TRIM(h.WCHDOORNUMBER) LIKE '8%' THEN 'DC'
        WHEN d.Container# LIKE '35%' AND TRIM(h.WCHDOORNUMBER) LIKE '1%' THEN 'WN5'
        WHEN d.Container# LIKE '35%' AND h.WCHBUILDING IN ('B1', 'B2') THEN 'WN2'
        WHEN d.Container# LIKE '35%' AND h.WCHBUILDING = 'V3' THEN 'WN3'
        WHEN d.Container# LIKE '35%' AND h.WCHBUILDING = 'M3' THEN 'DC'
        WHEN d.Container# LIKE '35%' AND h.WCHBUILDING = 'K1' THEN 'WN5'
        ELSE 'CHECK'
    END AS WH
FROM ContainerDetails d
JOIN ContainerType t ON d.Container# = t.Container#
RIGHT JOIN HeaderDetails h ON d.Container# = h.Container#
WHERE d.Container# IS NOT NULL
ORDER BY d.WCIORIGIN, d.ContainerNumber, d.WCILASTMAINTENANCETIMESTAMP