SELECT *
FROM (
    SELECT
        a1.HOUSE,
        a1.ORDNO,
        a1.ITMSQ,
        a1.ITNBR,
        a1.ITDSC,
        a1.ITCLS,
        a1.CCUSNO,
        a1.CSHPNO,
        a1.CUSNM,
        CHAR(a1.TKNDAT) AS Order_Taken_Date,
        CHAR(a1.FRZDAT) AS Original_Request_Date,
        CHAR(a1.RQSDAT) AS CRD,
        CHAR(a1.RQIDT) AS CPD,
        CHAR(a1.MFIDT) AS LoadDate,
        a1.ORDUSR,
        a1.COQTY,
        a1.QTYSH,
        a1.QTYBO,
        a1.OPEN_CO_QTY,
        a1.ALC,
        a1.Product,
        CHAR(x1.BDTRP#) AS BDTRP#,
        x1.BDISEQ,
        x1.BDITQT AS Trip_Qty,
        x1.BDITCT,
        x1.BDITWT,
        x1.BDREF#,
        x1.BHCDAT,
        x1.BHCTIM,
        x1.BHRDAT,
        x1.BHLDAT,
        x1.BHLTIM,
         t9.DSPDAT,t9.DSPTIM,
       TO_DATE(t9.DSPDAT||' '||right('000000'||ltrim(t9.DSPTIM),6), 'yyyymmdd hh24:mi:ss') as Dispatch_Time2,
       DATE(Substr(t9.LSCHDT, 1, 4) || '-'||  Substr(t9.LSCHDT, 5, 2)|| '-' ||substr(t9.LSCHDT, 7, 2)) as Latest_Load_Date,
       t9.CARRIR as CARRIER
    FROM (
        SELECT
            t1.HOUSE,
            t1.ORDNO,
            t1.ITMSQ,
            t1.ITNBR,
            t1.ITDSC,
            t1.ITCLS,
            t1.CCUSNO,
            t3.CUSNM,
            t1.CSHPNO,
            t1.RQIDT,
            t1.MFIDT,
            t1.UNMSR,
            (CASE
                WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTR(t1.ITNBR, 1, 4) = '100-' THEN 'CG'
                WHEN SUBSTR(t1.ITNBR, 1, 1) IN ('A', 'B', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
                ELSE 'UPH'
            END) AS Product,
            t2.TKNDAT,
            t2.FRZDAT,
            t2.RQSDAT,
            t2.ORDUSR,
            t1.COQTY,
            t1.QTYSH,
            t1.QTYBO,
            t1.COQTY - t1.QTYSH AS OPEN_CO_QTY,
            (CASE
                WHEN t1.IAFLG = 0 THEN 'N'
                WHEN t1.IAFLG = 2 THEN 'Y'
                ELSE 'Check'
            END) AS ALC
        FROM
            AFILELIB.CODATAN t1
            JOIN AFILELIB.EXTORD t2 ON t2.XORDNO = t1.ORDNO
            JOIN AFILELIB.ACUSMASJ t3 ON t3.CUSNO = t1.CCUSNO
            JOIN AFILELIB.COMAST t4 ON t1.ORDNO = t4.ORDNO
            JOIN AMFLIBA.ITMRVA t5 ON t1.ITNBR = t5.ITNBR AND t1.HOUSE = t5.STID
        WHERE
            t1.HOUSE IN ('335')
            AND t1.IAFLG = 2
            AND t1.COQTY - t1.QTYSH <> 0
    ) AS a1
    LEFT JOIN (
        SELECT
            t1.BDTRP#,
            t1.BDORD#,
            t1.BDISEQ,
            t1.BDITM#,
            t1.BDITMD,
            t1.BDCUS#,
            t1.BDITQT,
            t1.BDITCT,
            t1.BDITWT,
            t1.BDREF#,
            t1.BDCDAT,
            t1.BDCTIM,
            t2.BHTRPS,
            t2.BHCDAT,
            t2.BHCTIM,
            t2.BHRDAT,
            t2.BHLDAT,
            t2.BHLTIM
        FROM
            DISTLIB.BTTRIPD t1
            JOIN DISTLIB.BTTRIPH t2 ON t1.BDTRP# = t2.BHTRP#

        WHERE
            t2.BHWHS# IN ('335')
            AND t2.BHLDAT BETWEEN 0 AND 29991231
            AND t2.BHTRPS IN ('A', 'R', 'X')
        ORDER BY
            t1.BDTRP#, t1.BDISEQ, t1.BDITM#
    ) x1 ON a1.ORDNO || a1.ITMSQ || a1.ITNBR || a1.CCUSNO = x1.BDORD# || x1.BDISEQ || x1.BDITM# || x1.BDCUS#
    LEFT JOIN AFILELIB.ATOFILE AS t9 ON x1.BDTRP#=t9.TO#

    ORDER BY
        a1.ITNBR, a1.MFIDT
) d1