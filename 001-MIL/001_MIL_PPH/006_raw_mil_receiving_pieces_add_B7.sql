WITH emp AS (
    SELECT
        t.Plant,
        cast(t.EmployeeNumber as int) as EmployeeNumber,
        t.EmpReportName,
        t.GroupNumber,
        t.Schedule,
        t.HomeDepartment,
        t.TerminationDate
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR as t
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
    CAST(1.0 * t.TransQty / NULLIF(i.ITMCQTY, 0) AS DECIMAL(15, 8)) AS Cartons

FROM
    Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
LEFT JOIN emp AS e
    ON e.EmployeeNumber = CAST(t.EmpBadge AS INT)  -- 修正 JOIN 类型匹配
LEFT JOIN itm as i
    ON i.ITNBR = t.Item
WHERE
    t.AddDate BETWEEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -7, GETDATE()), 112) AS INT)
        AND CAST(CONVERT(CHAR(8), GETDATE(), 112) AS INT)
    AND (t.ActivityCodeOne IN ('MV')
     OR (t.ActivityCodeOne IN ('CN') AND t.Equipment LIKE 'UNK%'))
    AND t.FromWhs = '51'
    AND t.ActivityCodeTwo = 'SN'
    AND t.FromArea IN ('RM','HJ') 
    AND ( t.ToArea = 'HJ' OR t.ToArea = '' OR t.ToArea IS NULL)
    AND t.Serial <> 0;