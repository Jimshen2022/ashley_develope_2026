SELECT a1.HOUSE,
    a1.ORDNO,
    A1.ITMSQ,
    trim(a1.ITNBR) AS ITNBR,
    a1.ITDSC,
    a1.ITCLS,
    a1.CCUSNO,
    a1.CSHPNO,
    a1.CUSNM,
    to_date(char(a1.TKNDAT), 'yyyymmdd') Order_Taken_Date,
    to_date(char(a1.FRZDAT), 'yyyymmdd') Original_Request_Date,
    to_date(char(a1.RQSDAT), 'yyyymmdd') CRD,
    to_date(char(a1.RQIDT), 'yyyymmdd') CPD,
    to_date(char(a1.MFIDT), 'yyyymmdd') LoadDate,
    a1.ORDUSR,
    a1.COQTY,
    a1.QTYSH,
    a1.QTYBO,
    a1.OPEN_CO_QTY,
    a1.ALC,
    a1.Product,
    x1.BDTRP#, x1.BDISEQ, x1.BDITQT as Trip_Qty, x1.BDITCT, x1.BDITWT, x1.BDREF#, x1.BHCDAT, x1.BHCTIM, x1.BHRDAT, x1.BHLDAT, x1.BHLTIM,
    t9.DSPDAT,t9.DSPTIM,
       TO_DATE(t9.DSPDAT||' '||right('000000'||ltrim(t9.DSPTIM),6), 'yyyymmdd hh24:mi:ss') as Dispatch_Time2,
       DATE(Substr(t9.LSCHDT, 1, 4) || '-'||  Substr(t9.LSCHDT, 5, 2)|| '-' ||substr(t9.LSCHDT, 7, 2)) as Latest_Load_Date,
       t9.CARRIR as CARRIER

FROM (
        SELECT t1.HOUSE,
            t1.ORDNO,
            t1.ITMSQ,
            t1.ITNBR,
            t1.ITDSC,
            t1.ITCLS,
            t1.CCUSNO,
--             t3.CUSNM,
            T1.CSHPNO,
            T1.RQIDT,
            T1.MFIDT,
            T1.UNMSR,
            (
                CASE
                    WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'
                    WHEN SUBSTR(t1.ITNBR, 1, 4) = '100-' THEN 'CG'
                    WHEN SUBSTR(t1.ITNBR, 1, 1) in (
                        'A',
                        'B',
                        'D',
                        'E',
                        'H',
                        'L',
                        'M',
                        'P',
                        'Q',
                        'R',
                        'T',
                        'W',
                        'Z'
                    ) THEN 'CG'
                    ELSE 'UPH'
                END
            ) as Product,
            t2.TKNDAT,
            t2.FRZDAT,
            t2.RQSDAT,
            t2.ORDUSR,
            t1.COQTY,
            t1.QTYSH,
            t1.QTYBO,
            T1.COQTY - T1.QTYSH AS OPEN_CO_QTY,
            (
                CASE
                    WHEN t1.IAFLG = 0 THEN 'N'
                    WHEN t1.IAFLG = 2 THEN 'Y'
                    ELSE 'Check'
                END
            ) AS ALC
        FROM Wholesale_CODIS.CODATAN AS t1
            Wholesale_CODIS.EXTORD t2,
--             AFILELIB.ACUSMASJ t3,
            Wholesale_CODIS.COMAST t4,
            MasterData_ItemMaster_AFI.ITMRVA as  t5
        WHERE t2.XORDNO = t1.ORDNO
--             AND t3.CUSNO = t1.CCUSNO
            AND t1.ORDNO = t4.ORDNO
            AND t1.ITNBR = T5.ITNBR
            AND t1.house = T5.STID
            AND t1.house IN ('335')
            AND t1.COQTY - t1.QTYSH <> 0
    ) as a1
    LEFT JOIN (
        SELECT t1.BDTRP#, t1.BDORD#, t1.BDISEQ, t1.BDITM#, t1.BDITMD, t1.BDCUS#, t1.BDITQT,
            t1.BDITCT,
            t1.BDITWT,
            t1.BDREF#, t1.BDCDAT, t1.BDCTIM, t2.BHTRPS, t2.BHCDAT, t2.BHCTIM, t2.BHRDAT, t2.BHLDAT, t2.BHLTIM
        FROM Wholesale_CODIS.BTTRIPD t1,
            Wholesale_CODIS.BTTRIPH t2
        WHERE t2.BHWHS# IN ('335') AND t2.BHTRPS IN ('A','R','X') AND t1.BDTRP# = t2.BHTRP#
        ORDER BY t1.BDTRP#, t1.BDISEQ, t1.BDITM#) x1
            ON a1.ORDNO||a1.ITMSQ||a1.ITNBR||a1.CCUSNO = x1.BDORD#||x1.BDISEQ||x1.BDITM#||x1.BDCUS#
    LEFT JOIN
             AFILELIB.ATOFILE AS t9 ON x1.BDTRP#=t9.TO#

 -- where t9.DSPDAT between 20230101  and   int(substr(trim(char(CURRENT DATE + 14 DAYS)),1,4)||substr(trim(char(CURRENT DATE + 14 DAYS)),6,2)||substr(trim(char(CURRENT DATE + 14 DAYS )),9,2))
        ORDER BY a1.MFIDT,
            x1.BDTRP#, a1.ITNBR, x1.BDISEQ

