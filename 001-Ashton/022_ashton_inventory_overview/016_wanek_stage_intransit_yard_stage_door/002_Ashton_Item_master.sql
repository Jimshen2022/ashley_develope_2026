WITH CTE_ItemInfo AS (
    SELECT
        T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T1.WHSLC, T1.QTSYR, T2.ITDSC,
        T4.MFPUS, T1.DOFLS, T1.QTSMO, T1.BEGIN, T1.RECMO,
        T1.MPUPQ AS OPEN_PO, T1.LDQOH, T4.PRDDDES, round(T2.B2Z95S * T1.MOHTQ*0.028317,2) AS Cubic_meters, T5.ITMCLSID, T5.PICKPUT
    FROM
        MasterData_ItemMaster_AFI.ITEMBL T1
        JOIN MasterData_ItemMaster_AFI.ITMRVA T2 ON T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR
        JOIN Wholesale_Purchasing_AFI.WHSMST T3 ON T2.STID = T3.STID AND T1.HOUSE = T3.WHID
        JOIN MasterData_ItemMaster_AFI.ITMEXT T4 ON T1.ITNBR = T4.ITNBR
        JOIN MasterData_ItemMaster_AFI.ITBEXT
 T5 ON t1.HOUSE = T5.HOUSE AND T1.ITNBR = T5.ITNBR
    WHERE
        T1.HOUSE = '335'
),
CTE_OpenOrders AS (
    -- 处理订单和发运需求的CTE
    SELECT
        y1.ITNBR,
        SUM(y1.OPEN_CO) AS OPEN_CO,
        SUM(y1.Trip_Qty) AS Trip_Qty
    FROM (
        SELECT
            a1.ITNBR,
            (a1.COQTY - a1.QTYSH) AS OPEN_CO,
            x1.BDITQT AS Trip_Qty
        FROM (
            SELECT
                t1.ITNBR, SUM(t1.COQTY) AS COQTY, SUM(t1.QTYSH) AS QTYSH
            FROM
                Wholesale_CODIS.CODATAN t1
                JOIN Wholesale_CODIS.EXTORD t2 ON t2.XORDNO = t1.ORDNO
                JOIN AFILELIB.ACUSMASJ t3 ON t3.CUSNO = t1.CCUSNO
                JOIN Wholesale_CODIS.COMAST t4 ON t1.ORDNO = t4.ORDNO
                JOIN MasterData_ItemMaster_AFI.ITMRVA t5 ON t1.ITNBR = t5.ITNBR
            WHERE
                t1.house = '335'
                AND t1.COQTY - t1.QTYSH <> 0
                AND t4.MPROR NOT IN ('F','L','C')
            GROUP BY
                t1.ITNBR
        ) a1
        LEFT JOIN (
            -- 发运需求
            SELECT
                t1.BDORD#, t1.BDITM#, SUM(t1.BDITQT) AS BDITQT
            FROM
                Wholesale_CODIS.BTTRIPD t1
                JOIN Wholesale_CODIS.BTTRIPH t2 ON t1.BDTRP# = t2.BHTRP#
            WHERE
                t2.BHWHS# = '335'
                AND t2.BHLDAT BETWEEN 20210101 AND 20381231
                AND t2.BHTRPS IN ('A','R','X')
            GROUP BY
                t1.BDORD#, t1.BDITM#
        ) x1 ON a1.ITNBR = x1.BDITM#
    ) y1
    GROUP BY
        y1.ITNBR
)
SELECT
    a.ITNBR, a.HOUSE, a.ITCLS, a.ITDSC,
CASE
   WHEN a.ITCLS NOT LIKE 'Z%' THEN 'RP'
   WHEN a.ITMCLSID LIKE 'UPH%' THEN 'UPH'
   WHEN a.ITDSC LIKE '%RUG%' THEN 'ACCESSORY'
   WHEN a.ITDSC LIKE '%RECLI%' THEN 'UPH'
   WHEN a.ITDSC LIKE '%SOFA%' AND  a.ITDSC NOT LIKE '%SOFA%TABLE%'  THEN 'UPH'
   WHEN a.ITDSC LIKE '%LOVE%' THEN 'UPH'
   WHEN a.ITMCLSID LIKE 'PAL%' THEN 'CG'
   WHEN a.ITMCLSID LIKE 'SMALL%' THEN 'CG'
   WHEN a.ITMCLSID LIKE 'FLOOR%' THEN 'BULK'
   WHEN a.ITMCLSID LIKE 'RUG%' THEN 'ACCESSORY'
   WHEN a.ITMCLSID LIKE 'RAILS%' THEN 'RAILS'
   WHEN a.ITNBR LIKE 'PA%' THEN 'UPH'
   WHEN SUBSTR(a.ITNBR, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
   WHEN SUBSTR(a.ITNBR, 1, 1) IN ('A', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W','Z') THEN 'CG'
   WHEN a.PICKPUT in ('PALLT') THEN 'CG'
   WHEN a.PICKPUT in ('UPH') THEN 'UPH'
    ELSE 'CHECK' END AS product_category
FROM
    CTE_ItemInfo a
    LEFT JOIN (SELECT ITNBR, MFPUS, HOUSE FROM AFILELIB.ITBEXT WHERE HOUSE = '335') b9 ON a.ITNBR = b9.ITNBR
    LEFT JOIN (SELECT pitem, PAMNT FROM AFILELIB.PRICE WHERE PRICCD = 'FOBARC') b ON a.ITNBR = b.pitem
    LEFT JOIN CTE_OpenOrders b2 ON a.ITNBR = b2.ITNBR
group by  a.ITNBR, a.HOUSE, a.ITCLS, a.ITDSC,
CASE
   WHEN a.ITCLS NOT LIKE 'Z%' THEN 'RP'
   WHEN a.ITMCLSID LIKE 'UPH%' THEN 'UPH'
   WHEN a.ITDSC LIKE '%RUG%' THEN 'ACCESSORY'
   WHEN a.ITDSC LIKE '%RECLI%' THEN 'UPH'
   WHEN a.ITDSC LIKE '%SOFA%' AND  a.ITDSC NOT LIKE '%SOFA%TABLE%'  THEN 'UPH'
   WHEN a.ITDSC LIKE '%LOVE%' THEN 'UPH'
   WHEN a.ITMCLSID LIKE 'PAL%' THEN 'CG'
   WHEN a.ITMCLSID LIKE 'SMALL%' THEN 'CG'
   WHEN a.ITMCLSID LIKE 'FLOOR%' THEN 'BULK'
   WHEN a.ITMCLSID LIKE 'RUG%' THEN 'ACCESSORY'
   WHEN a.ITMCLSID LIKE 'RAILS%' THEN 'RAILS'
   WHEN a.ITNBR LIKE 'PA%' THEN 'UPH'
   WHEN SUBSTR(a.ITNBR, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
   WHEN SUBSTR(a.ITNBR, 1, 1) IN ('A', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W','Z') THEN 'CG'
   WHEN a.PICKPUT in ('PALLT') THEN 'CG'
   WHEN a.PICKPUT in ('UPH') THEN 'UPH'
ELSE 'CHECK' END
ORDER BY
    a.ITNBR