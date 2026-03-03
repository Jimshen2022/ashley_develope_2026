SELECT TOP 10 * FROM Wholesale_Purchasing_AFI.POITEM t1 WHERE T1.HOUSE IN ('1')
SELECT TOP 10 * FROM  Wholesale_Purchasing_AFI.POMAST t2 WHERE T2.HOUSE IN ('1')
-- SELECT TOP 10 * FROM  MasterData_ItemMaster_AFI.ITMRVA t3
/*    SELECT
        t1.ORDNO,
        LTRIM(RTRIM(t1.ITNBR)) AS ITNBR,
        t1.HOUSE,
        t1.ITCLS,
        t1.DUEDT,
        t1.VNDNR,
        t2.PSTTS,
        t1.QTYOR,
        t1.ITDSC,
         CAST(t3.B2Z95S * 0.028317 AS DECIMAL(10, 2)) AS Unit_CBM,
         CAST(t3.B2Z95S * 0.028317 * t1.QTYOR AS DECIMAL(10, 2)) AS Product_CBM
    FROM
        Wholesale_Purchasing_AFI.POITEM t1
        INNER JOIN Wholesale_Purchasing_AFI.POMAST t2
            ON t1.ORDNO = t2.ORDNO AND t1.HOUSE = t2.HOUSE
        LEFT JOIN (select * from MasterData_ItemMaster_AFI.ITMRVA as a0 where a0.STID IN ('001')) t3
            ON trim(t1.ITNBR) = trim(t3.ITNBR)
    WHERE
        t1.HOUSE IN ('1')
        AND t2.PSTTS IN ('20', '30', '40', '50')
        AND t1.DUEDT >= '1241001'
*/

WITH BaseData AS (
    SELECT 
        t1.ORDNO, 
        LTRIM(RTRIM(t1.ITNBR)) AS ITNBR, 
        t1.HOUSE, 
        t1.ITCLS, 
        t1.DUEDT, 
        t1.VNDNR, 
        t2.PSTTS, 
        t1.QTYOR, 
        t1.ITDSC, 
        CAST(t3.B2Z95S * 0.028317 AS DECIMAL(10, 2)) AS Unit_CBM, 
        CAST(t3.B2Z95S * 0.028317 * t1.QTYOR AS DECIMAL(10, 2)) AS Product_CBM
    FROM 
        Wholesale_Purchasing_AFI.POITEM t1
        INNER JOIN Wholesale_Purchasing_AFI.POMAST t2 
            ON t1.ORDNO = t2.ORDNO AND t1.HOUSE = t2.HOUSE
        LEFT JOIN (select * from MasterData_ItemMaster_AFI.ITMRVA as a0 where a0.STID IN ('001')) t3
            ON t1.ITNBR = t3.ITNBR
    WHERE 
        t1.HOUSE IN ('1')
        AND t2.PSTTS IN ('20', '30', '40', '50') 
        AND t1.DUEDT >= '1241001'
),
GroupedData AS (
    SELECT 
        ORDNO, 
        ITNBR, 
        HOUSE, 
        ITCLS, 
        DUEDT, 
        VNDNR, 
        PSTTS, 
        ITDSC, 
        Unit_CBM,
        CASE
            WHEN ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN ITNBR LIKE '100-%' THEN 'CG'
            WHEN LEFT(ITNBR, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            WHEN LEFT(ITNBR, 1) = 'A' AND Unit_CBM >= 0.3 THEN 'CG'
            WHEN LEFT(ITNBR, 1) IN ('A','L','R','Q') THEN 'ACCESSORY'
            WHEN LEN(ITNBR) = 6 AND LEFT(ITNBR, 1) = 'M' THEN 'ACCESSORY'
            ELSE 'CG'
        END AS PRODUCT,
        CASE
            WHEN PSTTS = '20' THEN 'On-Order: New ASN Pending by Vendor'
            WHEN PSTTS = '30' THEN 'In-Transit: New ASN Accepted by Buyer'
            WHEN PSTTS = '40' THEN 'Rc. to Stk: PO is in Receipt To Stock Status'
            WHEN PSTTS = '50' THEN 'Receiver: PO is in Receiver Status'
            ELSE 'Check'
        END AS PO_STATUS,
        SUM(QTYOR) AS Open_PO,
        SUM(Product_CBM) AS Total_Product_CBM
    FROM 
        BaseData
    GROUP BY 
        ORDNO, 
        ITNBR, 
        HOUSE, 
        ITCLS, 
        DUEDT, 
        VNDNR, 
        PSTTS, 
        ITDSC, 
        Unit_CBM,
        CASE
            WHEN ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN ITNBR LIKE '100-%' THEN 'CG'
            WHEN LEFT(ITNBR, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            WHEN LEFT(ITNBR, 1) = 'A' AND Unit_CBM >= 0.3 THEN 'CG'
            WHEN LEFT(ITNBR, 1) IN ('A','L','R','Q') THEN 'ACCESSORY'
            WHEN LEN(ITNBR) = 6 AND LEFT(ITNBR, 1) = 'M' THEN 'ACCESSORY'
            ELSE 'CG'
        END,
        CASE
            WHEN PSTTS = '20' THEN 'On-Order: New ASN Pending by Vendor'
            WHEN PSTTS = '30' THEN 'In-Transit: New ASN Accepted by Buyer'
            WHEN PSTTS = '40' THEN 'Rc. to Stk: PO is in Receipt To Stock Status'
            WHEN PSTTS = '50' THEN 'Receiver: PO is in Receiver Status'
            ELSE 'Check'
        END
)
SELECT 
    ORDNO, 
    ITNBR, 
    HOUSE, 
    ITCLS, 
    DUEDT, 
    VNDNR, 
    PSTTS, 
    ITDSC, 
    Unit_CBM, 
    PRODUCT, 
    PO_STATUS, 
    Open_PO, 
    CAST(Total_Product_CBM AS DECIMAL(10, 2)) AS Product_CBM
FROM 
    GroupedData
ORDER BY 
    ORDNO, 
    ITNBR;
