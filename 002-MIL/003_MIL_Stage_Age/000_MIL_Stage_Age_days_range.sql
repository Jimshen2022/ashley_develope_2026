-- 参数区：只改这里就可以调整时间范围
DECLARE @AsOfDateTime         DATETIME = GETDATE();  -- 统计截止时间
DECLARE @SnLookbackDays       INT      = 360;        -- 发货 SN 回溯天数
DECLARE @ActivityLookbackDays INT      = 90;         -- ACTAUDT 交易回溯天数

-- 方便 AddDate BETWEEN 使用的整型日期
DECLARE @AsOfDateInt          INT = CAST(CONVERT(CHAR(8), @AsOfDateTime, 112) AS INT);
DECLARE @ActivityStartDateInt INT = CAST(CONVERT(CHAR(8), DATEADD(DAY, -@ActivityLookbackDays, @AsOfDateTime), 112) AS INT);

WITH sn_current_loc AS
(
    SELECT
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
    WHERE t.WCSADDEDTIMESTAMP >= DATEADD(DAY, -@SnLookbackDays, @AsOfDateTime)
    
    UNION ALL
    
    SELECT 
        t.WCSCONTAINERNUMBER,
        t.WCSSERIALNUMBER,
        t.WCSITEMNUMBER,
        t.WCSORDER,
        t.WCSDESTINATION
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD AS t
    WHERE t.WCSADDEDTIMESTAMP >= DATEADD(DAY, -@SnLookbackDays, @AsOfDateTime)
),
s AS (
    SELECT t.WCSSERIALNUMBER
    FROM shipped_sn AS t
    INNER JOIN ctns AS c ON c.WCHCONTAINERNUMBER = t.WCSCONTAINERNUMBER
),

-- ⭐ 这里是对 ACTAUDT 的“按 Serial 取最早一笔”准备
base_act AS (
    SELECT
        t.*,
        CONVERT(DATETIME, 
            STUFF(STUFF(CAST(t.AddDate AS VARCHAR(8)), 5, 0, '-'), 8, 0, '-') + ' ' +
            STUFF(STUFF(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
        ) AS received_datetime,
        ROW_NUMBER() OVER (
            PARTITION BY t.Serial
            ORDER BY t.AddDate, t.AddTime  -- 最早 = 最小的 AddDate+AddTime
        ) AS rn
    FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
    WHERE
        t.AddDate BETWEEN @ActivityStartDateInt AND @AsOfDateInt
        AND (t.ActivityCodeOne IN ('MV')
         OR (t.ActivityCodeOne IN ('CN') AND t.Equipment LIKE 'UNK%'))
        AND t.FromWhs = '51'
        AND t.ActivityCodeTwo = 'SN'
        AND t.FromArea IN ('RM','HJ') 
        AND (t.ToArea = 'HJ' OR t.ToArea = '' OR t.ToArea IS NULL)
        AND t.Serial <> 0
),

-- 只保留每个 Serial 的最早那一笔
filtered_act AS (
    SELECT *
    FROM base_act
    WHERE rn = 1
),

emp AS (
    SELECT
        CAST(t.EmployeeNumber AS INT) AS EmployeeNumber,
        MAX(t.EmpReportName) AS EmpReportName
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR AS t
    GROUP BY CAST(t.EmployeeNumber AS INT)
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
        (CASE 
            WHEN c.ITCLS IN ('WPLS','PLST') THEN 'PLASTIC'   
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
            WHEN c.ITCLS LIKE 'Z%K' THEN 'UNKITS'   
            ELSE 'Check' 
         END) AS Product 
    FROM MasterData_ItemMaster_MIL.ITMRVA AS c
    INNER JOIN MasterData_ItemMaster_MIL.ITBEXT AS d 
        ON c.ITNBR = d.ITNBR 
       AND c.STID = d.HOUSE
    INNER JOIN MasterData_ItemMaster_MIL.ITMEXT AS e 
        ON e.ITNBR = c.ITNBR
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

    -- pph_type
    CASE
        WHEN t.ActivityCodeOne = 'MV' AND 
             CAST(t.ToArea AS VARCHAR) +
             RIGHT('000' + CAST(t.ToAisle AS VARCHAR), 3) +
             CAST(t.ToSection AS VARCHAR) +
             CAST(t.ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2')
        THEN 'Receiving'
        WHEN t.ActivityCodeOne = 'MV' AND 
             CAST(t.ToArea AS VARCHAR) +
             RIGHT('000' + CAST(t.ToAisle AS VARCHAR), 3) +
             CAST(t.ToSection AS VARCHAR) +
             CAST(t.ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4')
        THEN 'Receiving'
        WHEN t.ActivityCodeOne = 'CN' AND t.Equipment LIKE 'UNK%' AND
             CAST(t.FromArea AS VARCHAR) +
             RIGHT('000' + CAST(t.FromAisle AS VARCHAR), 3) +
             CAST(t.FromSection AS VARCHAR) +
             CAST(t.FromTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2','HJ001AA3','HJ001AA4')
        THEN 'Unloading'
        ELSE NULL
    END AS pph_type,

    -- building
    CASE
        WHEN t.ActivityCodeOne = 'MV' AND 
             CAST(t.ToArea AS VARCHAR) +
             RIGHT('000' + CAST(t.ToAisle AS VARCHAR), 3) +
             CAST(t.ToSection AS VARCHAR) +
             CAST(t.ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2')
        THEN 'B1'
        WHEN t.ActivityCodeOne = 'MV' AND 
             CAST(t.ToArea AS VARCHAR) +
             RIGHT('000' + CAST(t.ToAisle AS VARCHAR), 3) +
             CAST(t.ToSection AS VARCHAR) +
             CAST(t.ToTier AS VARCHAR) IN ('HJ001AA3')
        THEN 'B3'
        WHEN t.ActivityCodeOne = 'MV' AND 
             CAST(t.ToArea AS VARCHAR) +
             RIGHT('000' + CAST(t.ToAisle AS VARCHAR), 3) +
             CAST(t.ToSection AS VARCHAR) +
             CAST(t.ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4')
        THEN 'B4'
        WHEN t.ActivityCodeOne = 'CN' AND t.Equipment LIKE 'UNK%' AND 
             CAST(t.FromArea AS VARCHAR) +
             RIGHT('000' + CAST(t.FromAisle AS VARCHAR), 3) +
             CAST(t.FromSection AS VARCHAR) +
             CAST(t.FromTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2','HJ001AA3','HJ001AA4')
        THEN 'B7'
        ELSE NULL
    END AS building,

    -- AddTime / Shift
    RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6) AS AddTime6,
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 7 AND 18
        THEN 'D'
        ELSE 'N'
    END AS Shift,

    -- shift_date
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 0 AND 6
        THEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -1, CAST(CAST(t.AddDate AS VARCHAR(8)) AS DATE)), 112) AS INT)
        ELSE t.AddDate
    END AS shift_date,

    -- 员工、物料
    e.EmpReportName,
    i.Product,
    i.ITMCQTY,
    CAST(1.0 * t.TransQty / NULLIF(i.ITMCQTY, 0) AS DECIMAL(15, 8)) AS Cartons,

    -- 最新扫描信息
    sn.LastAddDateTime,
    sn.current_Location,
    sn.ScanCount,

    -- 收货时间（已在 base_act 里算好的最早时间）
    t.received_datetime,

    -- Pending 小时数 / 天数
    ca2.pending_hours,

    -- Pending 区间（按天范围）
    CASE 
        WHEN ca2.pending_days BETWEEN 0 AND 6 THEN '0-7 days'
        WHEN ca2.pending_days BETWEEN 7 AND 13 THEN '7-14 days'
        WHEN ca2.pending_days BETWEEN 14 AND 29 THEN '14-30 days'
        WHEN ca2.pending_days BETWEEN 30 AND 89 THEN '1-3 months'
        WHEN ca2.pending_days BETWEEN 90 AND 179 THEN '3-6 months'
        WHEN ca2.pending_days BETWEEN 180 AND 269 THEN '6-9 months'
        WHEN ca2.pending_days BETWEEN 270 AND 364 THEN '9-12 months'
        WHEN ca2.pending_days BETWEEN 365 AND 729 THEN '1-2 years'
        WHEN ca2.pending_days BETWEEN 730 AND 1094 THEN '2-3 years'
        ELSE 'Over 3 years'
    END AS pending_in_whse_days_range

FROM
    filtered_act AS t   -- ⭐ 这里用的是“每个 Serial 最早那一笔”

    -- 用最早收货时间算 pending
    CROSS APPLY (
        SELECT
            pending_hours = DATEDIFF(HOUR, t.received_datetime, @AsOfDateTime),
            pending_days  = DATEDIFF(DAY,  t.received_datetime, @AsOfDateTime)
    ) AS ca2

LEFT JOIN emp AS e
    ON e.EmployeeNumber = CAST(t.EmpBadge AS INT)
LEFT JOIN itm AS i
    ON i.ITNBR = t.Item
LEFT JOIN sn_current_loc AS sn
    ON sn.Serial = t.Serial
WHERE
    -- 排除已发货 SN
    NOT EXISTS (
        SELECT 1 
        FROM s 
        WHERE s.WCSSERIALNUMBER = t.Serial
    )
    -- 排除 Unloading
    AND NOT (
        t.ActivityCodeOne = 'CN'
        AND t.Equipment LIKE 'UNK%'
        AND CAST(t.FromArea AS VARCHAR) +
            RIGHT('000' + CAST(t.FromAisle AS VARCHAR), 3) +
            CAST(t.FromSection AS VARCHAR) +
            CAST(t.FromTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2','HJ001AA3','HJ001AA4')
    );
