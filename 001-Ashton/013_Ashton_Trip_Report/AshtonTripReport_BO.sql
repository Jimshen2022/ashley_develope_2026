-- Trip report with ship to and customer information on Feb.20.2025 by Jim,Shen
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
        --T1.BEGIN,
        T1.RECMO,
        T1.MPUPQ AS OPEN_PO,
        T1.LDQOH,
        T4.PRDDDES,
        CAST(CAST(T2.B2Z95S * T1.MOHTQ * 0.028317 AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS Cubic_meters, -- Changed DECIMAL to CAST
        T5.ITMCLSID,
        T5.PICKPUT
    FROM MasterData_ItemMaster_AFI.ITEMBL T1
    INNER JOIN MasterData_ItemMaster_AFI.ITMRVA T2
        ON T1.HOUSE = T2.STID
        AND T2.ITNBR = T1.ITNBR
    INNER JOIN Wholesale_Purchasing_AFI.WHSMST T3
        ON T2.STID = T3.STID
        AND T1.HOUSE = T3.WHID
    INNER JOIN MasterData_ItemMaster_AFI.ITMEXT T4
        ON T1.ITNBR = T4.ITNBR
    INNER JOIN MasterData_ItemMaster_AFI.ITBEXT T5
        ON T1.HOUSE = T5.HOUSE
        AND T1.ITNBR = T5.ITNBR
    WHERE T1.HOUSE = '335'
),
trip_as400 AS (
    SELECT
        a1.HOUSE,
        a1.ORDNO,
        a1.ITMSQ,
        a1.ITNBR,
        a1.ITDSC,
        a1.ITCLS,
        a1.CCUSNO,
        a1.CSHPNO,
        --a1.CUSNM,
        CONVERT(VARCHAR, a1.TKNDAT) AS Order_Taken_Date,
        CONVERT(VARCHAR, a1.FRZDAT) AS Original_Request_Date,
        CONVERT(VARCHAR, a1.RQSDAT) AS CRD,
        CONVERT(VARCHAR, a1.RQIDT) AS CPD,
        CONVERT(VARCHAR, a1.MFIDT) AS LoadDate,
        a1.ORDUSR,
        a1.COQTY,
        a1.QTYSH,
        a1.QTYBO,
        a1.OPEN_CO_QTY,
        a1.ALC,
        a1.Product,
        CONVERT(VARCHAR, x1.BDTRP#) AS [BDTRP#],
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
        x1.BHTCUB,
        t9.DSPDAT, t9.DSPTIM,
        TRY_CONVERT(DATETIME,
            CONVERT(VARCHAR, t9.DSPDAT) + ' ' + RIGHT('000000' + LTRIM(CONVERT(VARCHAR, t9.DSPTIM)), 6),
            112) AS Dispatch_Time2,
        CASE
            WHEN t9.LSCHDT IS NULL THEN
                CONVERT(DATE, SUBSTRING(CONVERT(VARCHAR, a1.MFIDT), 1, 4) + '-' +
                SUBSTRING(CONVERT(VARCHAR, a1.MFIDT), 5, 2) + '-' +
                SUBSTRING(CONVERT(VARCHAR, a1.MFIDT), 7, 2))
            ELSE
                CONVERT(DATE, SUBSTRING(CONVERT(VARCHAR, t9.LSCHDT), 1, 4) + '-' +
                SUBSTRING(CONVERT(VARCHAR, t9.LSCHDT), 5, 2) + '-' +
                SUBSTRING(CONVERT(VARCHAR, t9.LSCHDT), 7, 2))
        END AS Latest_Load_Date,
        t9.CARRIR AS CARRIER
    FROM (
        SELECT
            t1.HOUSE,
            t1.ORDNO,
            t1.ITMSQ,
            t1.ITNBR,
            t1.ITDSC,
            t1.ITCLS,
            t1.CCUSNO,
            t1.CSHPNO,
            t1.RQIDT,
            t1.MFIDT,
            t1.UNMSR,
            (CASE
                WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTRING(t1.ITNBR, 1, 4) = '100-' THEN 'CG'
                WHEN SUBSTRING(t1.ITNBR, 1, 1) IN ('A', 'B', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
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
            Wholesale_CODIS.CODATAN t1
            JOIN Wholesale_CODIS.EXTORD t2 ON t2.XORDNO = t1.ORDNO
            JOIN Wholesale_CODIS.COMAST t4 ON t1.ORDNO = t4.ORDNO
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
            t2.BHLTIM,
            t2.BHTCUB
        FROM
            Wholesale_CODIS.BTTRIPD t1
            JOIN Wholesale_CODIS.BTTRIPH t2 ON t1.BDTRP# = t2.BHTRP#
        WHERE
            t2.BHWHS# IN ('335')
            AND t2.BHLDAT BETWEEN 0 AND 29991231
            AND t2.BHTRPS IN ('A', 'R', 'X')
    ) x1 ON CONVERT(VARCHAR, a1.ORDNO) + CONVERT(VARCHAR, a1.ITMSQ) + a1.ITNBR + CONVERT(VARCHAR, a1.CCUSNO) =
            CONVERT(VARCHAR, x1.BDORD#) + CONVERT(VARCHAR, x1.BDISEQ) + x1.BDITM# + CONVERT(VARCHAR, x1.BDCUS#)
    LEFT JOIN Wholesale_CODIS.ATOFILE AS t9 ON x1.BDTRP# = t9.TO#
	WHERE x1.BDTRP# is not NULL
),
trip_report AS
(SELECT *,
        -- 计算 LoadDate 对应的周六
        DATEADD(DAY, 6 - DATEPART(WEEKDAY, t.LoadDate), t.LoadDate) AS SaturdayDate,
        -- 计算当前周六
        DATEADD(DAY, 6 - DATEPART(WEEKDAY, GETDATE()), GETDATE()) AS CurrentSaturday,
        CAST(LEFT(t.LoadID, 7) AS INT) AS trip_nbr  FROM Distribution_Warehouse_Wholesale.TripReport  as t  WHERE t.WhID = '335' AND t.TripStatus NOT IN ('S','X')
),
customer as
(SELECT  t.[Customer Account Number],
	t.[Customer Name],
	t.[Customer Shipto Number],
	t.[ShipTo Details]
FROM PowerBI_Distribution.Dimcustomers as t
),
LoadDispatch AS (
    SELECT *, CAST(LEFT(LoadId, 7) AS INT) AS trip_nbr FROM Distribution_Warehouse_Wholesale.LoadDispatch AS t where t.WhId = '335'),
AfoLoadView AS
         (SELECT *, CAST(LEFT(LoadID, 7) AS INT) AS trip_nbr FROM Distribution_Warehouse_Wholesale.AfoLoadView where WhId = '335')
-----------------------------------------------main query----------------------------------------------------
SELECT t1.WhID,
	t1.LoadID,
	t1.trip_nbr,
	t1.OrderType,
	t1.OrderTypeDescription,
	t1.TripStatus,
	t1.TripStatusDescription,
	t1.TrailerSize,
	t1.DoorLoc,
	t1.StageLoc,
	t1.TripType,
	t1.LoadDate,
	t1.DispatchDate,
	t1.TripCreateDate,
	t1.CarrierName,
	t1.TrailerNumber,
	t1.TotalPieces,
	t1.UphNeed,
-- 	t1.TotalCube,
	t3.*,
	t4.*,
	isnull(t5.DispatchConfirmed, 'N') AS dispatch_confirmed,
	t6.LoadablePct,
	CASE
        WHEN t6.LoadablePct >= 0 AND t6.LoadablePct < 10 THEN '0% ~ 10%'
        WHEN t6.LoadablePct >= 10 AND t6.LoadablePct < 20 THEN '10% ~ 20%'
        WHEN t6.LoadablePct >= 20 AND t6.LoadablePct < 30 THEN '20% ~ 30%'
        WHEN t6.LoadablePct >= 30 AND t6.LoadablePct < 40 THEN '30% ~ 40%'
        WHEN t6.LoadablePct >= 40 AND t6.LoadablePct < 50 THEN '40% ~ 50%'
        WHEN t6.LoadablePct >= 50 AND t6.LoadablePct < 60 THEN '50% ~ 60%'
        WHEN t6.LoadablePct >= 60 AND t6.LoadablePct < 70 THEN '60% ~ 70%'
        WHEN t6.LoadablePct >= 70 AND t6.LoadablePct < 80 THEN '70% ~ 80%'
        WHEN t6.LoadablePct >= 80 AND t6.LoadablePct < 90 THEN '80% ~ 90%'
        WHEN t6.LoadablePct >= 90 AND t6.LoadablePct < 92 THEN '90% ~ 92%'
        WHEN t6.LoadablePct >= 92 AND t6.LoadablePct < 94 THEN '92% ~ 94%'
        WHEN t6.LoadablePct >= 94 AND t6.LoadablePct < 96 THEN '94% ~ 96%'
        WHEN t6.LoadablePct >= 96 AND t6.LoadablePct < 98 THEN '96% ~ 98%'
	    WHEN t6.LoadablePct >= 98 AND t6.LoadablePct <= 100 THEN '98% ~ 100%'
        ELSE 'Out of Range'  -- 可选，处理异常值或超出 0-100 范围的情况
    END AS Loadable_Range,
    t1.PctLoaded,
	t6.CGPercentage,
	t6.UPHPercentage,
    CASE
        WHEN DATEDIFF(WEEK, t1.CurrentSaturday, t1.SaturdayDate) = 0 THEN 'W1'
        WHEN DATEDIFF(WEEK, t1.CurrentSaturday, t1.SaturdayDate) > 0 THEN 'W' + CAST(DATEDIFF(WEEK, t1.CurrentSaturday, t1.SaturdayDate) + 1 AS VARCHAR)
        WHEN DATEDIFF(WEEK, t1.CurrentSaturday, t1.SaturdayDate) < 0 THEN 'backlog_W' + CAST(ABS(DATEDIFF(WEEK, t1.CurrentSaturday, t1.SaturdayDate)) AS VARCHAR)
    END AS WeekCategory
FROM trip_report as t1
LEFT JOIN
(select DISTINCT t2.BDTRP#,
	t2.CCUSNO,
	t2.CSHPNO,
    t2.BHTCUB
	from trip_as400 as t2
) AS t3 ON t1.trip_nbr = t3.BDTRP#
LEFT JOIN customer AS t4 on t3.CCUSNO = t4.[Customer Account Number] AND t3.CSHPNO=t4.[Customer Shipto Number]
LEFT JOIN LoadDispatch  AS t5 on t1.trip_nbr = t5.trip_nbr
LEFT JOIN AfoLoadView AS t6 on t1.trip_nbr = t6.trip_nbr
ORDER BY t1.LoadID