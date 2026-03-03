-- item class
WITH itm AS
(SELECT t1.ITNBR, MAX(t1.ITCLS) AS ITCLS
FROM MasterData_ItemMaster_AFI.ITMRVA as T1
Group by t1.ITNBR),
-- Amount
amt AS
(SELECT *
FROM MasterData_ItemMaster_AFI.Price a
WHERE a.PRICCD in ('FOBARC')),
--disco
D AS
(SELECT a.ITNBR, a.CUBES, a.MFPUS  FROM MasterData_ItemMaster_AFI.ITMEXT AS a),
-- U status
U AS
(SELECT a.ITNBR,a.MFPUS FROM MasterData_ItemMaster_AFI.ITBEXT AS a  WHERE a.HOUSE IN ('335'))

-- Main Query ---
SELECT  t1.ItemNumber, t1.Warehouse, t1.DateWeekEnding, CAST(t1.OnHandQty AS INT) AS OnHandQty, itm.ITCLS,
(CASE
    WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
	WHEN itm.ITCLS IN ('ZBBF','ZBBA') THEN 'ACCESSORY'
	WHEN SUBSTRING(t1.ItemNumber,1,4)='100-' THEN 'CG'
	WHEN SUBSTRING(t1.ItemNumber,1,1) in ('A','B','D','E','H','L','P','Q','M','R','T','W','Z') THEN 'CG'
	ELSE 'UPH' END) as Product,
CAST(amt.PAMNT*t1.OnHandQty AS DECIMAL(10,2)) AS "AMT($USD)",
(CASE
	WHEN d.MFPUS IN ('N') THEN 'NewItem'
	WHEN d.MFPUS IN ('D','R') THEN 'Discontinued'
    WHEN u.MFPUS IN ('U','N') THEN 'U Status'  ELSE 'Active' END) AS Item_Status

FROM Inventory_Enh_History.ItemBalance AS t1
LEFT JOIN itm as itm on t1.ItemNumber = itm.ITNBR
LEFT JOIN amt as amt on t1.ItemNumber = amt.PITEM
LEFT JOIN D as d on t1.ItemNumber = d.ITNBR
LEFT JOIN U as u on t1.ItemNumber = u.ITNBR
WHERE t1.Warehouse = '335' and t1.DateWeekEnding>= '2023-01-01'
ORDER BY t1.DateWeekEnding DESC



