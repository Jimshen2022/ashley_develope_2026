With sn_current_loc AS
(SELECT
    Serial,
    LastAddDateTime,
    CASE 
        WHEN To_Location IS NULL 
             OR LTRIM(RTRIM(To_Location)) = '' 
             OR To_Location = '000 0'
             OR REPLACE(To_Location, ' ', '') = '0000'
    THEN From_Location
    ELSE To_Location 
    END AS current_Location,
    ScanCount
FROM (
    SELECT 
        t.Serial,
        CONVERT(DATETIME, 
            STUFF(STUFF(CAST(t.AddDate AS VARCHAR(8)), 5, 0, '-'), 8, 0, '-') + ' ' +
            STUFF(STUFF(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
        ) AS LastAddDateTime,
        CONCAT(
            t.ToArea, 
            RIGHT('000' + CAST(t.ToAisle AS VARCHAR(3)), 3), 
            t.ToSection, 
            t.ToTier
        ) AS To_Location,
       CONCAT(
            t.FromArea, 
            RIGHT('000' + CAST(t.FromAisle AS VARCHAR(3)), 3), 
            t.FromSection, 
            t.FromTier
        ) AS From_Location,
        COUNT(*) OVER (PARTITION BY t.Serial) AS ScanCount,
        ROW_NUMBER() OVER (
            PARTITION BY t.Serial 
            ORDER BY t.AddDate DESC, t.AddTime DESC
        ) AS rn
    FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
    WHERE t.Serial IS NOT NULL
        AND t.AddDate IS NOT NULL 
        AND t.AddTime IS NOT NULL
) AS ranked
WHERE rn = 1    
),
ctns AS (
    SELECT DISTINCT a.WCHCONTAINERNUMBER
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD a
    WHERE a.WCHCONTAINERSTATUS IN ('P','T')
    
    UNION
    
    SELECT DISTINCT a.WCHCONTAINERNUMBER
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA a
),
shipped_sn AS (
    SELECT 
        t.WCSCONTAINERNUMBER,
        t.WCSSERIALNUMBER,
        t.WCSITEMNUMBER,
        t.WCSORDER,
        t.WCSDESTINATION
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTSDA AS t
    WHERE t.WCSADDEDTIMESTAMP >= DATEADD(DAY, -360, GETDATE())
    
    UNION ALL
    
    SELECT 
        t.WCSCONTAINERNUMBER,
        t.WCSSERIALNUMBER,
        t.WCSITEMNUMBER,
        t.WCSORDER,
        t.WCSDESTINATION
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD AS t
    WHERE t.WCSADDEDTIMESTAMP >= DATEADD(DAY, -360, GETDATE())
),
s AS (
SELECT t.WCSSERIALNUMBER
FROM shipped_sn AS t
INNER JOIN ctns AS c ON c.WCHCONTAINERNUMBER = t.WCSCONTAINERNUMBER
),
emp AS (
    SELECT
        cast(t.EmployeeNumber as int) as EmployeeNumber,
        max(t.EmpReportName) as EmpReportName
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR as t
    Group by cast(t.EmployeeNumber as int)
),
itm AS (
SELECT
    c.ITNBR,
   c.ITCLS,
   c.B2Z95S,
   c.WEGHT,
   d.ITMCLSID,
   d.PICKPUT,
   e.ITMCQTY,
   (CASE WHEN c.ITCLS IN ('WPLS','PLST') THEN 'PLASTIC'   
    WHEN c.ITCLS IN ('PVN2') THEN 'RAW'   
    WHEN c.ITCLS IN ('TAF') THEN 'RP'   
    WHEN c.ITCLS IN ('FFR') THEN 'FFR'   
    WHEN c.ITCLS IN ('BBFR') THEN 'FR SOCK'   
    WHEN c.ITCLS IN ('ZDTP') THEN 'PILLOW'   
    WHEN c.ITCLS IN ('MVN') THEN 'QUILTING'   
    WHEN c.ITCLS IN ('ZKIZ') THEN 'ZIPPER COVER'   
    WHEN c.ITCLS IN ('WVHC','WVVG') THEN 'VERONA'   
    WHEN c.ITCLS IN ('CTA','MTA') THEN 'RP CGs'   
    WHEN c.ITCLS IN ('PVN') THEN 'FABRIC'   
    WHEN c.ITCLS IN ('WVCS') THEN 'FOUNDATION'   
    WHEN c.ITCLS IN ('ZABC','ZECD','ZDAA','ZECD','ZDWC','ZDAB','ZDAE','ZDAW','ZDBC','ZDWC','ZDAY','ZEBR') THEN 'CASEGOODS'   
    WHEN c.ITCLS IN ('ZAIS','ZKIS','ZNFR','ZKBP') THEN 'BEDDING'   
    WHEN c.ITCLS LIKE  'Z%K' THEN 'UNKITS'   
    ELSE 'Check' END) AS Product 
FROM MasterData_ItemMaster_MIL.ITMRVA AS c
INNER JOIN MasterData_ItemMaster_MIL.ITBEXT AS d on c.ITNBR = d.ITNBR and c.STID = d.HOUSE
INNER JOIN MasterData_ItemMaster_MIL.ITMEXT as e on e.ITNBR = c.ITNBR
WHERE c.STID = '51'
)
SELECT 
    t.ActivityCodeOne,
    t.ActivityCodeTwo,
    t.FromRegion,
    t.FromWhs,
    t.FromArea,
    t.FromAisle,
    t.FromSection,
    t.FromTier,
    t.ToRegion,
    t.ToWhs,
    t.ToArea,
    t.ToAisle,
    t.ToSection,
    t.ToTier,
    t.[Order],
    t.Item,
    t.Serial,
    t.LicensePlate,
    t.TransQty,
    t.Emp,
    CAST(t.EmpBadge AS INT) AS EmpBadge,
    t.SuprBadge,
    t.Scanner,
    t.Equipment,
    t.AddDate,
    t.AddTime,
    t.AddUser,
    t.AddProgram,
    t.Transfer,
    t.Trip,
    CAST(t.Serial AS VARCHAR(50)) AS SN,

    -- 合成位置信息判断
    CASE
        WHEN
            ActivityCodeOne = 'MV' AND CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2')
        THEN 'Receiving'
        WHEN 
            ActivityCodeOne = 'MV' AND CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4')
        THEN 'Receiving'
        WHEN ActivityCodeOne = 'CN' AND Equipment like 'UNK%' AND
            CAST(FromArea AS VARCHAR) +
            RIGHT('000' + CAST(FromAisle AS VARCHAR), 3) +
            CAST(FromSection AS VARCHAR) +
            CAST(FromTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2','HJ001AA3','HJ001AA4')
        THEN 'Unloading'
        ELSE NULL
    END AS pph_type,

    CASE
        WHEN
            ActivityCodeOne = 'MV' AND CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2')
        THEN 'B1'
        WHEN
            ActivityCodeOne = 'MV' AND CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA3')
        THEN 'B3'
        WHEN
            ActivityCodeOne = 'MV' AND CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4')
        THEN 'B4'
        WHEN ActivityCodeOne = 'CN' AND Equipment like 'UNK%' AND 
            CAST(FromArea AS VARCHAR) +
            RIGHT('000' + CAST(FromAisle AS VARCHAR), 3) +
            CAST(FromSection AS VARCHAR) +
            CAST(FromTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2','HJ001AA3','HJ001AA4')
        THEN 'B7'
        ELSE NULL
    END AS building,

    -- 时间与班次
    RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6) AS AddTime6,
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 7 AND 18
        THEN 'D'
        ELSE 'N'
    END AS Shift,

    -- 新增shift_date列
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 0 AND 6
        THEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -1, CAST(CAST(t.AddDate AS VARCHAR(8)) AS DATE)), 112) AS INT)
        ELSE t.AddDate
    END AS shift_date,

    -- 显示 emp 的所有列
    e.*,
    i.Product,
    i.ITMCQTY,
    CAST(1.0 * t.TransQty / NULLIF(i.ITMCQTY, 0) AS DECIMAL(15, 8)) AS Cartons,
    SN.LastAddDateTime,
    SN.current_Location,
    SN.ScanCount
FROM
    Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
LEFT JOIN emp AS e
    ON e.EmployeeNumber = CAST(t.EmpBadge AS INT)  -- 修正 JOIN 类型匹配
LEFT JOIN itm as i
    ON i.ITNBR = t.Item
LEFT JOIN sn_current_loc as sn
    ON sn.Serial = t.Serial
WHERE
    t.AddDate BETWEEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -90, GETDATE()), 112) AS INT)
        AND CAST(CONVERT(CHAR(8), GETDATE(), 112) AS INT)
    AND (t.ActivityCodeOne IN ('MV')
     OR (t.ActivityCodeOne IN ('CN') AND t.Equipment LIKE 'UNK%'))
    AND t.FromWhs = '51'
    AND t.ActivityCodeTwo = 'SN'
    AND t.FromArea IN ('RM','HJ') 
    AND ( t.ToArea = 'HJ' OR t.ToArea = '' OR t.ToArea IS NULL)
    AND t.Serial <> 0
    AND NOT EXISTS (SELECT 1 FROM s where s.WCSSERIALNUMBER = t.Serial ) -- 排除已发货的 SN
    -- ⭐ 这里新增：排除 Unloading
    AND NOT (
        t.ActivityCodeOne = 'CN'
        AND t.Equipment LIKE 'UNK%'
        AND CAST(t.FromArea AS VARCHAR) +
            RIGHT('000' + CAST(t.FromAisle AS VARCHAR), 3) +
            CAST(t.FromSection AS VARCHAR) +
            CAST(t.FromTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2','HJ001AA3','HJ001AA4')
    );