WITH ITMRVA_CTE AS (
    SELECT * 
    FROM MasterData_ItemMaster_AFI.ITMRVA
    WHERE STID = '335'
),
ITEMBL_CTE AS (
    SELECT *
    FROM MasterData_ItemMaster_AFI.ITEMBL
    WHERE HOUSE = '335'
)
SELECT 
    t1.ITNBR,
    t1.STID,
    t4.MOHTQ,
    t4.PLREQ AS Demand,
    t4.DOFLS AS date_of_last_sales,
    t4.LDQOH AS Last_date_affecting_onhand,
    t4.WHSLC,
    t4.ITCLS,
    t1.B2Z95S AS UnitCube,
    t1.ITDSC,
    t2.TIHIUNLD,
    t2.PICKPUT,
    CASE
        WHEN t2.PICKPUT ='UPH' THEN 'UPH'
        ELSE 'CG' END AS product_category,
    t2.ITMCLSID,
    t2.UNITSWIDE,
    t2.UNITLAYERS,
    t2.UNITSDEEP,
    t2.SCOOPQTY,
    t2.SKIDSIZE,
    t3.QTYCR,
    t3.NBSEAT,
    t3.CRTWIN,
    t3.CRTLIN,
    t3.CRTHIN,
    t3.PRDWIN,
    t3.PRDHIN,
    t3.PRDLIN,
    t3.ITMWEGHT,
    CAST(t3.ITMWEGHT * 0.453592 AS DECIMAL(10, 2)) AS [Unit_Weight(KG)],
    t4.MPUPQ AS OPEN_PO,
    CASE
        WHEN t4.MOHTQ / NULLIF(t2.SCOOPQTY, 0) <= 1 THEN 1
        ELSE ROUND(t4.MOHTQ / NULLIF(t2.SCOOPQTY, 0), 0)
    END AS PALLETS,
    CAST(t2.SCOOPQTY * t3.ITMWEGHT * 0.453592 AS DECIMAL(10, 2)) AS [SCOOP_Weight(KG)]
FROM ITMRVA_CTE AS t1
LEFT JOIN MasterData_ItemMaster_AFI.ITBEXT AS t2 ON t2.ITNBR = t1.ITNBR AND t2.HOUSE = t1.STID
LEFT JOIN MasterData_ItemMaster_AFI.ITMEXT AS t3 ON t3.ITNBR = t1.ITNBR
LEFT JOIN ITEMBL_CTE AS t4 ON t1.ITNBR = t4.ITNBR AND t1.STID = t4.HOUSE
WHERE t1.STID = '335';