SELECT 
    a1.HOUSE,
    a1.ORDNO,
    a1.ITMSQ,
    a1.ITNBR,
    a1.ITDSC,
    a1.ITCLS,
    a1.CCUSNO,
    a1.CSHPNO,
    CONVERT(DATE, CONVERT(VARCHAR(8), a1.TKNDAT), 112) AS Order_Taken_Date,
    CONVERT(DATE, CONVERT(VARCHAR(8), a1.FRZDAT), 112) AS Original_Request_Date,
    CONVERT(DATE, CONVERT(VARCHAR(8), a1.RQSDAT), 112) AS CRD,
    CONVERT(DATE, CONVERT(VARCHAR(8), a1.RQIDT), 112) AS CPD,
    CONVERT(DATE, CONVERT(VARCHAR(8), a1.MFIDT), 112) AS LoadDate,
    a1.ORDUSR,
    a1.COQTY,
    a1.QTYSH,
    a1.QTYBO,
    a1.OPEN_CO_QTY,
    a1.ALC,
    a1.Product,
    x1.BDTRP#,
    x1.BDISEQ,
    x1.BDITQT AS Trip_Qty,
    x1.BDITCT,
    x1.BDITWT,
    x1.BDREF#,
    x1.BHCDAT,
    x1.BHCTIM,
    x1.BHRDAT,
    x1.BHLDAT,
    x1.BHLTIM
FROM 
(
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
        CASE 
            WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN LEFT(t1.ITNBR, 4) = '100-' THEN 'CG'
            WHEN LEFT(t1.ITNBR, 1) IN ('A','B','D','E','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
            ELSE 'UPH' 
        END AS Product,
        t2.TKNDAT,
        t2.FRZDAT,
        t2.RQSDAT,
        t2.ORDUSR,
        t1.COQTY,
        t1.QTYSH,
        t1.QTYBO,
        t1.COQTY - t1.QTYSH AS OPEN_CO_QTY,
        CASE 
            WHEN t1.IAFLG = 0 THEN 'N'
            WHEN t1.IAFLG = 2 THEN 'Y'
            ELSE 'Check' 
        END AS ALC
    FROM 
        Wholesale_CODIS.CODATAN t1
    INNER JOIN 
        Wholesale_CODIS.EXTORD t2 ON t2.XORDNO = t1.ORDNO
    WHERE 
        t1.HOUSE IN ('335')
        AND t1.COQTY - t1.QTYSH <> 0
) AS a1
LEFT JOIN 
(
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
        t2.BHTRPS,
        t2.BHCDAT,
        t2.BHCTIM,
        t2.BHRDAT,
        t2.BHLDAT,
        t2.BHLTIM
    FROM 
        Wholesale_CODIS.BTTRIPD t1
    INNER JOIN 
        Wholesale_CODIS.BTTRIPH t2 ON t1.BDTRP# = t2.BHTRP#
    WHERE 
        t2.BHWHS# IN ('335')
        AND t2.BHTRPS IN ('A', 'R', 'X')
) AS x1 
ON a1.ORDNO = x1.BDORD#
   AND a1.ITMSQ = x1.BDISEQ
   AND a1.ITNBR = x1.BDITM#
   AND a1.CCUSNO = x1.BDCUS#
ORDER BY 
    a1.MFIDT, x1.BDTRP#, a1.ITNBR, x1.BDISEQ;


	/*
SELECT  *
FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown AS t1
WHERE t1.wh_id IN ('335') 
  AND EXISTS (
      SELECT 1
      FROM (
          SELECT CAST(SUBSTRING(a1.LoadID, 1, 7) AS VARCHAR(50)) AS LoadID
          FROM Distribution_Warehouse_Wholesale.TripReport AS a1
          WHERE a1.WhID IN ('335') AND a1.TripStatus NOT IN ('S', 'X')
      ) AS a2
      WHERE a2.LoadID = CAST(SUBSTRING(t1.order_number, 1, 7) AS VARCHAR(50))
		and t1.LoadID in ('0032184-00','0040646-00')
  );
  */