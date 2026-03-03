WITH CTE_ItemInfo AS (
    SELECT  -- Removed DISTINCT as the natural keys should prevent duplicates
        T1.ITNBR,
        T1.HOUSE,
        T2.ITCLS,
        T1.MOHTQ,
        T1.WHSLC,
        T1.QTSYR,
        T2.ITDSC,
        T4.MFPUS,
        T1.DOFLS,
        T1.QTSMO,
        T1.BEGIN,
        T1.RECMO,
        T1.MPUPQ AS OPEN_PO,
        T1.LDQOH,
        T4.PRDDDES,
        DECIMAL(T2.B2Z95S * T1.MOHTQ * 0.028317, 10, 2) AS Cubic_meters, -- Simplified ROUND
        T5.ITMCLSID,
        T5.PICKPUT
    FROM AMFLIBA.ITEMBL T1
    INNER JOIN AMFLIBA.ITMRVA T2  -- Explicit INNER JOIN
        ON T1.HOUSE = T2.STID
        AND T2.ITNBR = T1.ITNBR
    INNER JOIN AMFLIBA.WHSMST T3
        ON T2.STID = T3.STID
        AND T1.HOUSE = T3.WHID
    INNER JOIN AFILELIB.ITMEXT T4
        ON T1.ITNBR = T4.ITNBR
    INNER JOIN AFILELIB.ITBEXT T5
        ON T1.HOUSE = T5.HOUSE
        AND T1.ITNBR = T5.ITNBR
    WHERE T1.HOUSE = '335'
),
product_category AS (  -- New CTE to handle complex CASE logic
    SELECT
        CI.*,
        CASE
            WHEN CI.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN CI.ITMCLSID LIKE 'UPH%' THEN 'UPH'
            WHEN CI.ITDSC LIKE '%RUG%' THEN 'ACCESSORY'
            WHEN CI.ITDSC LIKE '%TABLE%' OR
                 CI.ITDSC LIKE '%MIRROR%' OR
                 CI.ITDSC LIKE '%BOOKCASE%' THEN 'CG'
            WHEN CI.ITDSC LIKE '%RECLI%' OR
                 CI.ITDSC LIKE '%SOFA%' OR
                 CI.ITDSC LIKE '%LOVE%' THEN 'UPH'
            WHEN CI.ITMCLSID LIKE 'PAL%' OR
                 CI.ITMCLSID LIKE 'SMALL%' THEN 'CG'
            WHEN CI.ITMCLSID LIKE 'FLOOR%' THEN 'BULK'
            WHEN CI.ITMCLSID LIKE 'RUG%' THEN 'ACCESSORY'
            WHEN CI.ITMCLSID LIKE 'RAILS%' THEN 'RAILS'
            WHEN CI.ITNBR LIKE 'PA%' THEN 'UPH'
            WHEN SUBSTR(CI.ITNBR, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
            WHEN SUBSTR(CI.ITNBR, 1, 1) IN ('A', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
            WHEN CI.PICKPUT = 'PALLT' THEN 'CG'
            WHEN CI.PICKPUT = 'UPH' THEN 'UPH'
            ELSE 'CHECK'
        END AS product_category
    FROM CTE_ItemInfo CI
)
SELECT d1.*, p.product_category, p.pickput, p.ITMCLSID
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
       CASE
            WHEN t9.LSCHDT IS NULL THEN DATE(SUBSTR(a1.MFIDT,1,4)||'-'||Substr(a1.MFIDT, 5, 2)|| '-' ||substr(a1.MFIDT, 7, 2))
            ELSE DATE(Substr(t9.LSCHDT, 1, 4) || '-'||  Substr(t9.LSCHDT, 5, 2)|| '-' ||substr(t9.LSCHDT, 7, 2)) END as Latest_Load_Date,
       DATE(Substr(t9.LSCHDT,1,8)) as LSCHDT,
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
LEFT JOIN product_category as p ON p.ITNBR = d1.ITNBR