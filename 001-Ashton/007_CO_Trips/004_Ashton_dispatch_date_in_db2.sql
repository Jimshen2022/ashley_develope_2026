WITH trip_head AS (
    SELECT t.BHTRP#
        , t.BHWHS#
        , t.BHTRPS as trip_status
        , TRIM(t.BHCNTI)||TRIM(t.BHCNTN) as container_nbr
        , t.BHDOOR as loading_door
        , t.BHSEL1 as ctn_seal_nbr
        , t.BHTITM as trip_demand_qty
        , t.BHTSNS + t.BHTSNN  as total_sacnned_qty
        , (t.BHTSNS + t.BHTSNN)/t.BHTITM as "%cmp"
    FROM DISTLIB.BTTRIPH AS t
    WHERE t.BHWHS# = '335'
    )
SELECT
    t1.TO# AS trip_nbr,
    t1.CARRIR,
    t1.STATE1 AS STATE,
    t1.FLAG AS "CANCEL/OVER/SHORT FLAG",
    t1.HOUS AS WH,
    t1.USER,
    t1.TTYPE AS trip_type,
--     t1.STATUS AS "TRIP# STATUS",
--     t1.DSPDAT,
--     t1.DSPTIM,
    TIMESTAMP_FORMAT(
        DIGITS(DSPDAT) ||
        RIGHT('0000' || DIGITS(DSPTIM), 4),
        'YYYYMMDDHH24MI'
    ) AS DISPATCH_DATETIME,
    TO_DATE(CHAR(t1.DSPDAT), 'YYYYMMDD') AS Dispatch_Date,
     TO_DATE(CHAR(t1.LSCHDT), 'YYYYMMDD') AS Lastest_Load_date,
     t2.*
FROM (SELECT * FROM AFILELIB.ATOFILE AS t0
    WHERE t0.HOUS IN ('335') AND t0.INFLAG <>'Y') AS t1
LEFT JOIN trip_head AS t2 ON t1.TO# = t2.BHTRP#