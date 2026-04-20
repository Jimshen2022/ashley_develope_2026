WITH emp AS (
    SELECT *
    FROM Manufacturing_ProductionPlanning_MIL.EMPMST
),
bg AS (
    SELECT 
        RIGHT('00000' + RTRIM(CAST(t.EmployeeNumber AS VARCHAR(10))), 5) AS employee_id,
        t.Company,
        t.Facility,
        t.EmpReportName,
        t.Schedule,
        t.Plant,
        t.GroupNumber,
        t.JobTitle,
        t.HomeDepartment,
        t.Supervisor,
        t.MfgDepartment,
        t.MfgWorkCenter,
        t.BadgeNumber AS as400_badge_user_id,
        t.ShiftNumber,
        t.BeginningDate,
        t.EffectivityDate,
        t.TerminationDate,
        t.DateRecordAdded,
        e.FirstName,
        e.LastName,
        e.BadgeNbr AS as400_badge_number,
        e.UserP   AS as400_badge_user_name
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR AS t
    LEFT JOIN emp AS e
        ON e.BadgeNbr = t.BadgeNumber
    WHERE (t.TerminationDate IS NULL OR t.TerminationDate < '1920-01-01')
),
ctn AS (
    SELECT 
        a.WCHCONTAINERNUMBER,
        a.WCHORIGIN,
        a.WCHDESTINATION,
        a.WCHCONTAINERSTATUS,
        a.WCHTOTALCARTONS,
        a.WCHTOTALCUBES,
        a.WCHPOSTEDTIMESTAMP,
        a.WCHTOTALWEIGHT,
        a.WCHCONTAINERSIZE,
        a.WCHBUILDING, 
        LTRIM(RTRIM(a.WCHORIGIN)) + '-' + LTRIM(RTRIM(a.WCHCONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCHDESTINATION)) AS [Container#]
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD a
    WHERE a.WCHORIGIN IN ('51')  
      AND a.WCHBUILDING LIKE 'B%'

    UNION ALL

    SELECT 
        a.WCHCONTAINERNUMBER,
        a.WCHORIGIN,
        a.WCHDESTINATION,
        a.WCHCONTAINERSTATUS,
        a.WCHTOTALCARTONS,
        a.WCHTOTALCUBES,
        a.WCHPOSTEDTIMESTAMP,
        a.WCHTOTALWEIGHT,
        a.WCHCONTAINERSIZE,
        a.WCHBUILDING, 
        LTRIM(RTRIM(a.WCHORIGIN)) + '-' + LTRIM(RTRIM(a.WCHCONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCHDESTINATION)) + '-' +
        SUBSTRING(CONVERT(VARCHAR(20), a.WCHARCHIVETIMESTAMP, 120), 1, 13) AS [Container#]
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA a
    WHERE a.WCHPOSTEDTIMESTAMP BETWEEN CONVERT(VARCHAR(10), DATEADD(DAY, -14, GETDATE()), 120) AND CONVERT(VARCHAR(10), GETDATE(), 120)
      AND a.WCHORIGIN IN ('51') 
      AND a.WCHBUILDING LIKE 'B%'
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
        CASE 
            WHEN c.ITCLS LIKE 'TAF%' THEN 'RP'
            WHEN c.ITCLS IN ('MTA','CTA','FFR','MVN') THEN 'RP'
            WHEN c.ITCLS IN ('PACS','ZACM','WVVG') THEN 'UnKits'
            WHEN c.ITCLS LIKE 'Z%K'  THEN 'UnKits'
            WHEN c.ITCLS IN ('ZDTP','ZKBP')  THEN 'Pillow'
            WHEN c.ITCLS IN ('ZASU','ZMLH','ZMLR','ZUSR','ZUSU','ZVUC','ZXUC','ZUSU','ZUMU','ZAMU','ZASM','ZASR','ZDMA','ZMUC','ZSUS','ZUMS','ZUSM','ZVMA','ZVUS','ZXLH','ZXLM','ZXLR','ZXMS','ZXMU') THEN 'UPH'
            WHEN c.ITCLS IN ('ZDAA','ZDAE','ZDWC','ZDAY','ZVAA','ZDAB','ZDAW','ZDYB','ZDBC','ZABC','ZECD','ZEBR') THEN 'CG'
            WHEN c.ITCLS IN ('ZBMA','ZKIS','ZAIS','ZKBA','ZNFR','ZKBP','ZNFR') THEN 'Bedding'		
            WHEN c.ITCLS IN ('WPLS') THEN 'Plastics'
            WHEN c.ITCLS IN ('WVBC','WVCS') THEN 'Foundation'		
            WHEN c.ITCLS IN ('PANL') THEN 'Panel'
            WHEN c.ITCLS IN ('ZKIZ','BBFR','WVHC') THEN 'ZipperCover'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RawMaterial' 
            ELSE 'Check' 
        END AS Product   
    FROM MasterData_ItemMaster_MIL.ITMRVA AS c
    INNER JOIN MasterData_ItemMaster_MIL.ITBEXT AS d 
        ON c.ITNBR = d.ITNBR AND c.STID = d.HOUSE
    INNER JOIN MasterData_ItemMaster_MIL.ITMEXT AS e 
        ON e.ITNBR = c.ITNBR
    WHERE c.STID = '51'
),
load_data AS (
    SELECT 
        LTRIM(RTRIM(a.WCICONTAINERNUMBER)) AS ContainerNumber, 
        a.WCIORIGIN, 
        a.WCIDESTINATION, 
        a.WCIORDER, 
        LTRIM(RTRIM(a.WCIITEMNUMBER)) AS ItemNumber, 
        a.WCIQUANTITYLOADED AS Qty, 
        a.WCILASTMAINTENANCETIMESTAMP, 
        a.WCILASTMAINTENANCEUSER,
        LTRIM(RTRIM(a.WCIORIGIN)) + '-' + LTRIM(RTRIM(a.WCICONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCIDESTINATION)) AS [Container#]
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTID AS a 
    WHERE a.WCIORIGIN IN ('51')  
      AND a.WCILASTMAINTENANCETIMESTAMP BETWEEN CONVERT(VARCHAR(10), DATEADD(DAY, -7, GETDATE()), 120) 
                                             AND CONVERT(VARCHAR(10), GETDATE(), 120)

    UNION ALL

    SELECT 
        LTRIM(RTRIM(a.WCICONTAINERNUMBER)) AS ContainerNumber, 
        a.WCIORIGIN, 
        a.WCIDESTINATION, 
        a.WCIORDER, 
        LTRIM(RTRIM(a.WCIITEMNUMBER)) AS ItemNumber, 
        a.WCIQUANTITYLOADED AS Qty, 
        a.WCILASTMAINTENANCETIMESTAMP, 
        a.WCILASTMAINTENANCEUSER,
        LTRIM(RTRIM(a.WCIORIGIN)) + '-' + LTRIM(RTRIM(a.WCICONTAINERNUMBER)) + '-' + LTRIM(RTRIM(a.WCIDESTINATION)) + '-' +
        SUBSTRING(CONVERT(VARCHAR(20), a.WCIARCHIVETIMESTAMP, 120), 1, 13) AS [Container#]
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTIDA AS a 
    WHERE a.WCIORIGIN IN ('51') 
      AND a.WCILASTMAINTENANCETIMESTAMP BETWEEN CONVERT(VARCHAR(10), DATEADD(DAY, -7, GETDATE()), 120) 
                                             AND CONVERT(VARCHAR(10), GETDATE(), 120)
)
SELECT 
    t.ContainerNumber,
    t.WCIORIGIN,
    t.WCIDESTINATION,
    t.WCIORDER,
    t.ItemNumber,
    t.Qty,
    t.WCILASTMAINTENANCETIMESTAMP,
    t.WCILASTMAINTENANCEUSER,
    i.ITMCQTY, 
    i.ITCLS,
    i.B2Z95S AS UnitCube, 
    i.WEGHT  AS UnitWeight,
    t.Qty * i.B2Z95S AS Cubes,
    CEILING(CAST(t.Qty AS FLOAT) / NULLIF(CAST(i.ITMCQTY AS FLOAT), 0)) AS Cartons,
    n.[Container#],
    n.WCHBUILDING,
    n.WCHCONTAINERSTATUS,
    n.WCHDESTINATION,
    n.WCHTOTALCARTONS,
    n.WCHTOTALCUBES,
    n.WCHPOSTEDTIMESTAMP,
    n.WCHTOTALWEIGHT,
    n.WCHCONTAINERSIZE, 
    CASE 
        WHEN DATEPART(HOUR, t.WCILASTMAINTENANCETIMESTAMP) BETWEEN 7 AND 18 THEN 'D'
        ELSE 'N'
    END AS Shift,
    CASE 
        WHEN DATEPART(HOUR, t.WCILASTMAINTENANCETIMESTAMP) BETWEEN 0 AND 6 
             THEN CAST(DATEADD(DAY, -1, t.WCILASTMAINTENANCETIMESTAMP) AS DATE)
        ELSE CAST(t.WCILASTMAINTENANCETIMESTAMP AS DATE)
    END AS shift_date,
    i.Product,
    'loading' AS pph_type,
    bg.employee_id,
    bg.EmpReportName,
    bg.as400_badge_user_name,
    bg.as400_badge_number,
    bg.HomeDepartment,
    bg.Supervisor,
    bg.GroupNumber
FROM load_data AS t
LEFT JOIN itm AS i 
    ON t.ItemNumber = LTRIM(RTRIM(i.ITNBR))
LEFT JOIN ctn AS n 
    ON n.[Container#] = t.[Container#]
LEFT JOIN bg 
    -- 若 SQL Server 版本较老不支持 TRIM()，用 LTRIM(RTRIM())
    ON LTRIM(RTRIM(bg.as400_badge_user_name)) = LTRIM(RTRIM(t.WCILASTMAINTENANCEUSER))
WHERE n.WCHBUILDING LIKE 'B%'
  AND i.Product NOT IN ('CG','Bedding')
ORDER BY bg.as400_badge_user_name;   -- 需要排序就在最终 SELECT 里排
