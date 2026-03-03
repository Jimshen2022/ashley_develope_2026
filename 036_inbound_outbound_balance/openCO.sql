-- File Path: D:\Documents\00-Query\00-AshtonQuery\Henry\Open order C and CNW_Query_version04.xlsb
-- Query Name: ASHTON OPEN ORDER QUERY FOR TRUDY
-- Created on: Oct 16, 2024, Version: 03
-- Modification History:
--  • Aug 06, 2025 – Added 'Ship Inst' column by Nguyen, Helen requirement
--  • Sep 24, 2025 – Added 'terms' Version by Nguyen, Helen

with itm as (
    select 
        trim(a.itnbr) as itnbr, 
        a.itcls, 
        b.pickput, 
        b.ITMCLSID, 
        case 
            when a.itcls not like 'Z%' then 'RP'
            when b.pickput = 'UPH' then 'UPH'
            when b.ITMCLSID like 'RUG%' then 'RUGS'
            when b.ITMCLSID like 'FLO%' then 'BULK'
            ELSE 'CG' 
        END as product 
    from (select * from AMFLIBA.ITMRVA where stid = '335' ) as a
    left join (SELECT * FROM AFILELIB.ITBEXT  WHERE HOUSE = '335') as b 
        on b.itnbr = a.itnbr and a.stid = b.house
    where a.itcls like 'Z%' and a.itcls not like 'Z%K'
),
dp as 
(
    SELECT *
    FROM AFILELIB.ATOFILE AS  T1
    where t1.HOUS = '335'
)
SELECT 
    a1.HOUSE,
    a1.ORDNO,
    a1.SHINS as "Ship Inst", 
    a1.ITMSQ,
    a1.ITNBR,
    a1.ITDSC,
    a1.ITCLS,
    a1.CCUSNO,
    a1.CSHPNO,
    a1.CUSNM,
    a1.CUSPO,
    char(a1.TKNDAT) as Order_Taken_Date,
    char(a1.FRZDAT) as Original_Request_Date,
    char(a1.RQSDAT) as CRD,
    char(a1.RQIDT) as CPD, 
    char(a1.MFIDT) as LoadDate,
    a1.ORDUSR,
    a1.COQTY,
    a1.QTYSH,
    a1.QTYBO,
    a1.OPEN_CO_QTY,
    a1.ALC,
    a1.Product,
    x1.BDTRP#,
    x1.BDISEQ, 
    x1.BDITQT as Trip_Qty,
    x1.BDITCT,
    x1.BDITWT,
    x1.BDREF#,
    x1.BHCDAT,
    x1.BHCTIM,
    x1.BHRDAT,
    x1.BHLDAT,
    x1.BHLTIM,
    a1.Load_Lead_Time,
    a1.Terms,
    a1.OrderType1,
    a1.OrderType2,
    a1.OrderType3,
    a1.OrderType4,
    
    -- [修改]: 强制转为 'YYYY-MM-DD' 字符串，避免 Excel 乱码
    CASE 
        WHEN d.PLNDDT > 0 THEN 
            VARCHAR_FORMAT(TIMESTAMP_FORMAT(CHAR(d.PLNDDT), 'YYYYMMDD'), 'YYYY-MM-DD')
        ELSE NULL 
    END as Dispatch_Date,

    -- [修改]: 计算日期后，强制转为 'YYYY-MM-DD' 字符串
    CASE 
        WHEN d.PLNDDT > 0 THEN 
            VARCHAR_FORMAT(
                DATE(TIMESTAMP_FORMAT(CHAR(d.PLNDDT), 'YYYYMMDD')) + 
                (6 - DAYOFWEEK_ISO(DATE(TIMESTAMP_FORMAT(CHAR(d.PLNDDT), 'YYYYMMDD')))) DAYS,
            'YYYY-MM-DD')
        ELSE NULL 
    END AS WeekSaturday

FROM
(
    SELECT  
        t1.HOUSE, t1.ORDNO, t1.ITMSQ, t1.ITNBR, t1.ITDSC, t1.ITCLS, t1.CCUSNO,
        t3.CUSNM, T1.CSHPNO, T1.RQIDT, T1.MFIDT, T1.UNMSR,
        t4.CUSPO, t4.SHINS, t4.TERMD as Terms,
        t4.SHLTC as Load_Lead_Time,
        i.product, 
        t2.TKNDAT, t2.FRZDAT, t2.RQSDAT, t2.ORDUSR,
        t1.COQTY, t1.QTYSH, t1.QTYBO, 
        T1.COQTY-T1.QTYSH AS OPEN_CO_QTY,
        (CASE
            WHEN t1.IAFLG=0 THEN 'N'
            WHEN t1.IAFLG = 2 THEN 'Y'
            ELSE 'Check' 
        END) AS ALC,
        t2.OTTYP1 as OrderType1,
        t2.OTTYP2 as OrderType2, 
        t2.OTTYP3 as OrderType3, 
        t2.OTTYP4 as OrderType4
    FROM AFILELIB.CODATAN t1
    INNER JOIN AFILELIB.EXTORD t2 ON t2.XORDNO = t1.ORDNO
    INNER JOIN AFILELIB.ACUSMASJ t3 ON t3.CUSNO = t1.CCUSNO
    INNER JOIN AFILELIB.COMAST t4 ON t1.ORDNO = t4.ORDNO
    LEFT JOIN itm i ON t1.ITNBR = i.ITNBR 
    WHERE t1.house IN ('335')
      AND t1.COQTY - t1.QTYSH <> 0
) as a1

LEFT JOIN
(
    SELECT  
        t1.BDTRP#, t1.BDORD#, t1.BDISEQ, t1.BDITM#, t1.BDITMD, t1.BDCUS#, t1.BDITQT,
        t1.BDITCT, t1.BDITWT, t1.BDREF#, t1.BDCDAT, t1.BDCTIM,
        t2.BHTRPS, t2.BHCDAT, t2.BHCTIM, t2.BHRDAT, t2.BHLDAT, t2.BHLTIM
    FROM DISTLIB.BTTRIPD t1, DISTLIB.BTTRIPH t2
    WHERE t2.BHWHS# IN ('335') 
      AND t2.BHLDAT BETWEEN 0 AND 20261231 
      AND t2.BHTRPS IN ('A','R','X') 
      AND t1.BDTRP# = t2.BHTRP#
    ORDER BY t1.BDTRP#, t1.BDISEQ, t1.BDITM#
) x1 ON a1.ORDNO||a1.ITMSQ||a1.ITNBR||a1.CCUSNO = x1.BDORD#||x1.BDISEQ||x1.BDITM#||x1.BDCUS#

LEFT JOIN dp d ON x1.BDTRP# = d.TO#

ORDER BY a1.MFIDT, x1.BDTRP#, a1.ITNBR, x1.BDISEQ