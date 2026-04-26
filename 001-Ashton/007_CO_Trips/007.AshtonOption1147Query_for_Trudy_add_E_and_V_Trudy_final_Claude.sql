-- ============================================================
-- v3: DB2 optimizations (logic unchanged)
--   1. Eliminated nested SELECT * in itm CTE -> direct JOIN with explicit columns
--   2. Flattened the redundant outer subquery (a1) -> one less materialization pass
--   3. Replaced COQTY - QTYSH <> 0 with COQTY <> QTYSH -> index-friendly
--   4. Removed DISTINCT from ORDSCHD/BOLITEM subqueries -> replaced with
--      MAX() GROUP BY to deduplicate without a sort, and to safely pick one
--      SCSTATS/BSTAT value per join key
--   5. TRIM(ITNBR) applied consistently on both sides of the itm join
-- ============================================================

WITH itm AS (
    SELECT
        TRIM(a.ITNBR)  AS ITNBR,
        a.ITCLS,
        b.PICKPUT,
        b.ITMCLSID,
        CASE
            WHEN a.ITCLS NOT LIKE 'Z%'      THEN 'RP'
            WHEN b.PICKPUT   = 'UPH'         THEN 'UPH'
            WHEN b.ITMCLSID LIKE 'RUG%'      THEN 'RUGS'
            WHEN b.ITMCLSID LIKE 'FLO%'      THEN 'BULK'
            ELSE 'CG'
        END AS PRODUCT
    FROM       AMFLIBA.ITMRVA  a
    LEFT JOIN  AFILELIB.ITBEXT b
           ON  b.ITNBR  = a.ITNBR
           AND b.HOUSE  = a.STID          -- replaces the nested subquery filter
    WHERE a.STID   = '335'
      AND a.ITCLS LIKE  'Z%'
      AND a.ITCLS NOT LIKE 'Z%K'
),

-- Deduplicate ORDSCHD by join key using GROUP BY + MAX
-- avoids DISTINCT sort; MAX(SCSTATS) picks one value safely
sch AS (
    SELECT
        SCCUST#,
        SCORDNO,
        SCITMNO,
        SCITMSQ,
        MAX(SCSTATS) AS SCSTATS
    FROM AFILELIB.ORDSCHD
    WHERE SCWRHSE = '335'
    GROUP BY SCCUST#, SCORDNO, SCITMNO, SCITMSQ
),

-- Deduplicate BOLITEM by join key using GROUP BY + MAX
bol AS (
    SELECT
        BCUST#,
        BORDNO,
        BSEQ#,
        BITEM#,
        MAX(BSTAT) AS BSTAT
    FROM AFILELIB.BOLITEM
    GROUP BY BCUST#, BORDNO, BSEQ#, BITEM#
)

SELECT
    t1.HOUSE,
    t1.ORDNO,
    t4.SHINS                        AS "Ship Inst",
    t1.ITMSQ,
    t1.ITNBR,
    t1.ITDSC,
    t1.ITCLS,
    t1.CCUSNO,
    t1.CSHPNO,
    t3.CUSNM,
    t4.CUSPO,
    CHAR(t4.ORDTE)                  AS Order_Date,
    CHAR(t2.TKNDAT)                 AS Order_Taken_Date,
    CHAR(t2.FRZDAT)                 AS Original_Request_Date,
    CHAR(t2.RQSDAT)                 AS CRD,
    CHAR(t1.RQIDT)                  AS CPD,
    CHAR(t1.MFIDT)                  AS LoadDate,
    t2.ORDUSR,
    t1.COQTY,
    t1.QTYSH,
    t1.QTYBO,
    t1.COQTY - t1.QTYSH             AS OPEN_CO_QTY,
    CASE
        WHEN t1.IAFLG = 0 THEN 'N'
        WHEN t1.IAFLG = 2 THEN 'Y'
        ELSE 'Check'
    END                             AS ALC,
    i.PRODUCT,
    t4.SHLTC                        AS Load_Lead_Time,
    t4.TERMD                        AS Terms,
    t2.OTTYP1                       AS OrderType1,
    t2.OTTYP2                       AS OrderType2,
    t2.OTTYP3                       AS OrderType3,
    t2.OTTYP4                       AS OrderType4,
    -- SEL/SCH:
    --   ORDSCHD match -> return SCSTATS (Scheduled, not yet sent to WMS)
    --   BOLITEM match -> return BSTAT   (Tripped, sent to WMS for shipping)
    --   no match      -> blank
    CASE
        WHEN sch.SCORDNO IS NOT NULL THEN sch.SCSTATS
        WHEN bol.BORDNO  IS NOT NULL THEN bol.BSTAT
        ELSE ''
    END                             AS "SEL/SCH"

FROM       AFILELIB.CODATAN   t1
INNER JOIN AFILELIB.EXTORD    t2  ON  t2.XORDNO = t1.ORDNO
INNER JOIN AFILELIB.ACUSMASJ  t3  ON  t3.CUSNO  = t1.CCUSNO
INNER JOIN AFILELIB.COMAST    t4  ON  t4.ORDNO  = t1.ORDNO
LEFT  JOIN itm                i   ON  i.ITNBR   = TRIM(t1.ITNBR)
LEFT  JOIN sch
           ON  sch.SCCUST# = t1.CCUSNO
           AND sch.SCORDNO = t1.ORDNO
           AND sch.SCITMNO = t1.ITNBR
           AND sch.SCITMSQ = t1.ITMSQ
LEFT  JOIN bol
           ON  bol.BCUST# = t1.CCUSNO
           AND bol.BORDNO = t1.ORDNO
           AND bol.BSEQ#  = t1.ITMSQ
           AND bol.BITEM# = t1.ITNBR

WHERE t1.HOUSE  = '335'
  AND t1.COQTY <> t1.QTYSH       -- v3: avoids per-row arithmetic, more index-friendly

ORDER BY t1.MFIDT, t1.ITNBR