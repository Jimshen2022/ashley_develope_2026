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
    char(a1.ORDTE) as Order_Date,
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
    a1.Load_Lead_Time,
    a1.Terms,
    a1.OrderType1,
    a1.OrderType2,
    a1.OrderType3,
    a1.OrderType4,
    -- SEL/SCH column:
    --   If found in AFILELIB.ORDSCHD -> take SCSTATS value (Scheduled, before sent to WMS)
    --   If found in AFILELIB.BOLITEM -> take BSTAT value  (Tripped, sent to WMS for shipping)
    --   (blank) = neither scheduled nor tripped
    CASE
        WHEN sch.SCORDNO IS NOT NULL THEN sch.SCSTATS
        WHEN bol.BORDNO  IS NOT NULL THEN bol.BSTAT
        ELSE ''
    END AS "SEL/SCH"

FROM
(
    SELECT  
        t1.HOUSE, t1.ORDNO, t1.ITMSQ, t1.ITNBR, t1.ITDSC, t1.ITCLS, t1.CCUSNO,
        t3.CUSNM, T1.CSHPNO,t4.ORDTE,T1.RQIDT, T1.MFIDT, T1.UNMSR,
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

-- Join AFILELIB.ORDSCHD to detect "E" (Scheduled – before sent to WMS)
-- SCCUST# ↔ CCUSNO, SCORDNO ↔ ORDNO, SCITMNO ↔ ITNBR, SCITMSQ ↔ ITMSQ, SCWRHSE = '335'
LEFT JOIN (
    SELECT DISTINCT SCCUST#, SCORDNO, SCITMNO, SCITMSQ, SCSTATS
    FROM AFILELIB.ORDSCHD
    WHERE SCWRHSE = '335'
) AS sch
    ON  sch.SCCUST# = a1.CCUSNO
    AND sch.SCORDNO = a1.ORDNO
    AND sch.SCITMNO = a1.ITNBR
    AND sch.SCITMSQ = a1.ITMSQ

-- Join AFILELIB.BOLITEM to detect "V" (Tripped – sent to WMS for shipping)
-- BCUST# ↔ CCUSNO, BORDNO ↔ ORDNO, BSEQ# ↔ ITMSQ, BITEM# ↔ ITNBR
LEFT JOIN (
    SELECT DISTINCT BCUST#, BORDNO, BSEQ#, BITEM#, BSTAT
    FROM AFILELIB.BOLITEM
) AS bol
    ON  bol.BCUST# = a1.CCUSNO
    AND bol.BORDNO = a1.ORDNO
    AND bol.BSEQ#  = a1.ITMSQ
    AND bol.BITEM# = a1.ITNBR

ORDER BY a1.MFIDT, a1.ITNBR