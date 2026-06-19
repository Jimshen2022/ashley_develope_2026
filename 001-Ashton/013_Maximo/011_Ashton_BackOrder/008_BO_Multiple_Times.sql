-- 1) 明细口径（与 Query/400 “Matched only + 条件”一致）
WITH base AS (
    SELECT
        t01.nord# || t01.nitem               AS orditm,
        t01.nitem,
        t01.ncode,
        t01.ndate,
        t01.ntime,
        t02.BHWHS#                           AS house,
        t01.nqtyun,
        COALESCE(t03.cubes, 0)               AS cubes,
        t01.ntrip,
        t01.ndrop,
        t01.NORD#                            AS order_no,
        t04.MOHTQ,
        t04.DOFLS,
        t01.NCUSNO,
        t01.NCUSNM
    FROM DISTLIB.BTRSNCD4 t01
    JOIN DISTLIB.BTTRIPH  t02 ON t01.NTRIP = t02.BHTRP#
    JOIN AFILELIB.ITMEXT  t03 ON t01.nitem = t03.ITNBR
    JOIN AMFLIBA.ITEMBL   t04 ON t01.nitem = t04.ITNBR AND t04.HOUSE = t02.BHWHS#
    WHERE t01.ndate BETWEEN 20250101 AND DEC( VARCHAR_FORMAT(CURRENT_DATE - 1 DAY, 'YYYYMMDD'), 8, 0 )
      AND t01.NCODE NOT IN ('21','56','52','60','62')
      AND t01.nqtyun > 0
      AND t02.BHWHS# = '335'
),
-- 2) 与 “Summary only by ORDITEM” 相同的聚合
rk_mulcode AS (
    SELECT
        orditm                                   AS CNUBMERITM,
        MIN(nitem)                               AS SKU,          -- MODEL03
        COUNT(nitem)                             AS XBACKORDRD,   -- MODEL05
        MIN(ndate)                               AS MINDATE,      -- DATE03
        MAX(ndate)                               AS MAXDATE,      -- DATE04
        MIN(ncode)                               AS MINBOCODE,    -- CODE03
        MAX(ncode)                               AS MAXBOCODE,    -- CODE04
        MIN(house)                               AS DISTCENTER,   -- WAREHOUS03
        MIN(ntrip)                               AS MINTRIP,      -- TRIP#03
        MAX(ntrip)                               AS MAXTRIP,      -- TRIP#04
        DEC(AVG(MOHTQ),10,3)                     AS MAPICSONHD,   -- MOHTQ02
        DEC(AVG(DOFLS),7,0)                      AS LSTSALEDAT,   -- DOFLS02 (CYYMMDD)
        MIN(NCUSNO)                              AS CUSTMRNMBR,   -- NCUSNO03
        MIN(NCUSNM)                              AS CUSTMRNAME    -- NCUSNM03
    FROM base
    GROUP BY orditm
),
-- 3) 你的“Select Records”过滤
rk_filtered AS (
    SELECT *
    FROM rk_mulcode
    WHERE MAXDATE BETWEEN DEC(VARCHAR_FORMAT(CURRENT_DATE - 6 DAYS, 'YYYYMMDD'), 8, 0)
                  AND     DEC(VARCHAR_FORMAT(CURRENT_DATE,        'YYYYMMDD'), 8, 0)
      AND XBACKORDRD > 1
      AND CNUBMERITM <> ' '
      AND DISTCENTER <> '232'
      AND MINTRIP <> MAXTRIP
      AND SKU <> 'RPTRUCK'
)

-- 4) 连接 ATOFILE（用 HOUS + T0#）并落地所需字段

    SELECT
        s.CNUBMERITM,
        s.SKU,
        s.XBACKORDRD,
        s.MINDATE,
        s.MAXDATE,
        s.MINBOCODE,
        s.MAXBOCODE,
        s.DISTCENTER,
        s.MINTRIP,
        s.MAXTRIP,
        s.MAPICSONHD,
        s.LSTSALEDAT,
        s.CUSTMRNMBR,
        s.CUSTMRNAME,
        a.TTYPE                               AS TTYPE
    FROM rk_filtered s
   LEFT  JOIN AFILELIB.ATOFILE a
      ON a.HOUS = s.DISTCENTER               -- 仓库对仓库
     AND a.TO#  = s.MAXTRIP                  -- 车次/号对 MAXTRIP