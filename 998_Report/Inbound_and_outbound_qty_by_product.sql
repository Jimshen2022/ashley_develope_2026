WITH ITMRVA_CTE AS (
    SELECT * 
    FROM MasterData_ItemMaster_AFI.ITMRVA 
    WHERE STID = '335'
),
ITEMBL_CTE AS (
    SELECT * 
    FROM MasterData_ItemMaster_AFI.ITEMBL 
    WHERE HOUSE = '335'
),
i AS (
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
WHERE t1.STID = '335'
)
SELECT 
	--t1.[start_tran_date]
	 --DATEPART(YYYY,t1.[start_tran_date])*100 +FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00') AS YearWeek,
	 --DATEADD(DAY, 6 - DATEPART(WEEKDAY, t1.[start_tran_date]), t1.[start_tran_date]) AS WeekSaturday,
	 DATEPART(YYYY,t1.[start_tran_date])*100 + DATEPART(MONTH, t1.[start_tran_date]) AS YearMonth
-- 	, t1.item_number
	, CASE WHEN t2.product_category is null then 'CG' ELSE t2.product_category END AS product_category
-- 	, t2.ITDSC
	, SUM(CASE
		WHEN t1.tran_type IN ('151','183') THEN t1.tran_qty
		WHEN t1.tran_type IN ('951') THEN - t1.tran_qty ELSE 0 END) AS Received_Qty
	, SUM(CASE
		WHEN t1.tran_type IN ('347') THEN t1.tran_qty
		ELSE 0 END) AS Shipped_Qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i AS t2 ON t1.item_number = t2.ITNBR
WHERE t1.wh_id IN ('335')
	  AND t1.start_tran_date >= '2025-01-01'
	  AND t1.tran_type IN ('347','151','183','951')
GROUP BY
	 --DATEPART(YYYY,t1.[start_tran_date])*100 +FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00'),
	-- DATEADD(DAY, 6 - DATEPART(WEEKDAY, t1.[start_tran_date]), t1.[start_tran_date]),
	 DATEPART(YYYY,t1.[start_tran_date])*100 + DATEPART(MONTH, t1.[start_tran_date]),
	 CASE WHEN t2.product_category is null then 'CG' ELSE t2.product_category END
ORDER BY YearMonth

