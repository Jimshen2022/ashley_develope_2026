select trim(a.itnbr) as itnbr, a.itcls, b.pickput, b.ITMCLSID 
from AMFLIBA.ITMRVA as a
left join (SELECT * FROM AFILELIB.ITBEXT  WHERE HOUSE = '335')as b on b.itnbr = a.itnbr and a.stid = b.house
where a.stid = '335' and a.itcls like 'Z%' and a.itcls not like 'Z%K'
order by a.itnbr;










WITH
-- 1) 基表精简与预筛
ITEMBL_CTE AS (
    SELECT a.ITNBR, a.HOUSE, a.MOHTQ, a.WHSLC, a.ITCLS, a.QTSYR, a.MPUPQ, a.USEYR, a.LDQOH, a.DOFLS, a.PLREQ, a.RECPL, a.SAFTY
    FROM AMFLIBA.ITEMBL a
    WHERE a.MOHTQ > 0
      AND a.HOUSE IN ('335')
),
ITBEXT_CTE AS (
    SELECT b.ITNBR, b.HOUSE, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID,
           b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE, b.MFPUS, b.OVRFLWBLDG, b.TOHLD, b.ATPQT
    FROM AFILELIB.ITBEXT b
    WHERE b.HOUSE IN ('335')
),
ITMEXT_CTE AS (
    SELECT c.ITNBR, c.QTYCR, c.NBSEAT, c.CRTWIN, c.CRTLIN, c.CRTHIN,
           c.PRDWIN, c.PRDHIN, c.PRDLIN, c.ITMWEGHT, c.MFPUS, c.SERIES, c.UUCCIM, c.PRDDDES
    FROM AFILELIB.ITMEXT c
),
ITMRVA_CTE AS (
    SELECT d.ITNBR, d.B2Z95S, d.ITDSC, d.STID
    FROM AMFLIBA.ITMRVA d
    WHERE d.STID IN ('335')
),

-- 2) 统一关联合并
MERGED AS (
    SELECT
        t2.ITNBR,
        t2.HOUSE,
        t2.MOHTQ,
        t2.WHSLC,
        t2.ITCLS,
        t2.QTSYR,
        t2.MPUPQ AS OPEN_PO,
        t2.USEYR AS "Quantity used this year",
        t2.LDQOH AS "Last date affecting quantity on hand", 
        t2.DOFLS AS "Date of last sale", 
        t2.PLREQ as "Pick list requirements", 
        t2.RECPL as "Quantity received since last plan",
        t2.SAFTY AS "Safety stock",

        t4.B2Z95S,
        t4.ITDSC,

        t1.TIHIUNLD,
        t1.PICKPUT,
        t1.ITMCLSID,
        t1.UNITSWIDE,
        t1.UNITLAYERS,
        t1.UNITSDEEP,
        t1.SCOOPQTY,
        t1.SKIDSIZE,
        t1.MFPUS AS "Manu. Status Code", 
        t1.OVRFLWBLDG, 
        t1.TOHLD AS "Total_Hold_Qty", 
        t1.ATPQT, 

        t3.QTYCR,
        t3.NBSEAT,
        t3.CRTWIN,
        t3.CRTLIN,
        t3.CRTHIN,
        t3.PRDWIN,
        t3.PRDHIN,
        t3.PRDLIN,
        t3.ITMWEGHT,
        t3.MFPUS, 
        t3.SERIES, 
        t3.UUCCIM AS "Financial Division", 
        t3.PRDDDES AS "Dimension Description"
    FROM ITEMBL_CTE t2
    LEFT JOIN ITBEXT_CTE t1
        ON t1.ITNBR = t2.ITNBR
       AND t1.HOUSE = t2.HOUSE
    LEFT JOIN ITMEXT_CTE t3
        ON t3.ITNBR = t2.ITNBR
    LEFT JOIN ITMRVA_CTE t4
        ON t4.ITNBR = t2.ITNBR
       AND t4.STID  = t2.HOUSE
),

-- 3) 统一计算（全部重量转为 KG）
METRICS AS (
    SELECT
        m.*,

        -- 单位重量(kg)
        DECIMAL(m.ITMWEGHT * 0.453592, 18, 6) AS UNIT_WEIGHT_KG,

        -- 每 Scoop 重量(kg)
        DECIMAL(CASE
            WHEN m.SCOOPQTY IS NOT NULL AND m.ITMWEGHT IS NOT NULL
                 THEN m.SCOOPQTY * m.ITMWEGHT * 0.453592
            ELSE NULL
        END, 18, 6) AS SCOOP_WEIGHT_KG,

        -- 托盘数（至少 1 托）
        CASE
            WHEN m.SCOOPQTY IS NULL OR m.SCOOPQTY = 0 THEN NULL
            WHEN m.MOHTQ <= m.SCOOPQTY THEN 1
            ELSE CEIL( m.MOHTQ / NULLIF(m.SCOOPQTY, 0) )
        END AS PALLETS
    FROM MERGED m
)

-- 4) 最终选择 + 分档标签
SELECT
    -- 基本信息
    ITNBR,
    HOUSE,
    MOHTQ,
    WHSLC,
    ITCLS,
    QTSYR,
    OPEN_PO,

    -- ITEMBL 增加字段
    "Quantity used this year",
    "Last date affecting quantity on hand",
    "Date of last sale",
    "Pick list requirements",
    "Quantity received since last plan",
    "Safety stock",

    -- ITMRVA
    B2Z95S,
    ITDSC,

    -- ITBEXT 字段
    TIHIUNLD,
    PICKPUT,
    ITMCLSID,
    UNITSWIDE,
    UNITLAYERS,
    UNITSDEEP,
    SCOOPQTY,
    SKIDSIZE,
    "Manu. Status Code",
    OVRFLWBLDG,
    "Total_Hold_Qty",
    ATPQT,

    -- ITMEXT 字段
    QTYCR,
    NBSEAT,
    CRTWIN,
    CRTLIN,
    CRTHIN,
    PRDWIN,
    PRDHIN,
    PRDLIN,
    ITMWEGHT,
    SERIES,
    "Financial Division",
    "Dimension Description",

    -- 计算字段
    UNIT_WEIGHT_KG,
    PALLETS,
    SCOOP_WEIGHT_KG,

    -- 单位重量分档（KG）
    CASE
        WHEN UNIT_WEIGHT_KG < 10   THEN 'A. 0-10'
        WHEN UNIT_WEIGHT_KG < 20   THEN 'B. 10-20'
        WHEN UNIT_WEIGHT_KG < 30   THEN 'C. 20-30'
        WHEN UNIT_WEIGHT_KG < 40   THEN 'D. 30-40'
        WHEN UNIT_WEIGHT_KG < 50   THEN 'E. 40-50'
        WHEN UNIT_WEIGHT_KG < 60   THEN 'F. 50-60'
        WHEN UNIT_WEIGHT_KG < 70   THEN 'G. 60-70'
        WHEN UNIT_WEIGHT_KG < 80   THEN 'H. 70-80'
        WHEN UNIT_WEIGHT_KG < 90   THEN 'I. 80-90'
        WHEN UNIT_WEIGHT_KG < 100  THEN 'K. 90-100'
        WHEN UNIT_WEIGHT_KG < 110  THEN 'L. 100-110'
        WHEN UNIT_WEIGHT_KG < 120  THEN 'M. 110-120'
        WHEN UNIT_WEIGHT_KG < 130  THEN 'N. 120-130'
        WHEN UNIT_WEIGHT_KG < 140  THEN 'O. 130-140'
        WHEN UNIT_WEIGHT_KG < 150  THEN 'P. 140-150'
        WHEN UNIT_WEIGHT_KG < 160  THEN 'Q. 150-160'
        WHEN UNIT_WEIGHT_KG < 170  THEN 'R. 160-170'
        WHEN UNIT_WEIGHT_KG < 180  THEN 'S. 170-180'
        ELSE 'T. Over 180'
    END AS UNIT_WEIGHT_RANGE_KG,

    -- Scoop 总重分档（KG）
    CASE
        WHEN SCOOP_WEIGHT_KG < 100   THEN 'A. 0-100'
        WHEN SCOOP_WEIGHT_KG < 200   THEN 'B. 100-200'
        WHEN SCOOP_WEIGHT_KG < 300   THEN 'C. 200-300'
        WHEN SCOOP_WEIGHT_KG < 400   THEN 'D. 300-400'
        WHEN SCOOP_WEIGHT_KG < 500   THEN 'E. 400-500'
        WHEN SCOOP_WEIGHT_KG < 600   THEN 'F. 500-600'
        WHEN SCOOP_WEIGHT_KG < 700   THEN 'G. 600-700'
        WHEN SCOOP_WEIGHT_KG < 800   THEN 'H. 700-800'
        WHEN SCOOP_WEIGHT_KG < 900   THEN 'I. 800-900'
        WHEN SCOOP_WEIGHT_KG < 1000  THEN 'K. 900-1000'
        WHEN SCOOP_WEIGHT_KG < 1100  THEN 'L. 1000-1100'
        WHEN SCOOP_WEIGHT_KG < 1200  THEN 'M. 1100-1200'
        WHEN SCOOP_WEIGHT_KG < 1300  THEN 'N. 1200-1300'
        WHEN SCOOP_WEIGHT_KG < 1400  THEN 'O. 1300-1400'
        WHEN SCOOP_WEIGHT_KG < 1500  THEN 'P. 1400-1500'
        WHEN SCOOP_WEIGHT_KG < 1600  THEN 'Q. 1500-1600'
        WHEN SCOOP_WEIGHT_KG < 1700  THEN 'R. 1600-1700'
        WHEN SCOOP_WEIGHT_KG < 1800  THEN 'S. 1700-1800'
        WHEN SCOOP_WEIGHT_KG < 1900  THEN 'T. 1800-1900'
        WHEN SCOOP_WEIGHT_KG < 2000  THEN 'U. 1900-2000'
        WHEN SCOOP_WEIGHT_KG < 2100  THEN 'V. 2000-2100'
        ELSE 'W. Over 2100'
    END AS SCOOP_WEIGHT_RANGE_KG

FROM METRICS
WHERE PICKPUT = 'PALLT'