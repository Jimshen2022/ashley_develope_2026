SELECT r0.item_number
	, r0.location_id
	, r0.Racking_Qty
		, i0.ITCLS
		, i0.B2Z95S
		, i0.TIHIUNLD
		, i0.PICKPUT
		, i0.PUTAWAY_CLASS
		, i0.UNITSWIDE
		, i0.UNITLAYERS
		, i0.UNITSDEEP
		, i0.SCOOPQTY
		, i0.SKIDSIZE
        ,
    (CASE
        WHEN i0.SKIDSIZE = 1 THEN '5X5'
        WHEN i0.SKIDSIZE = 3 THEN '5X7'
        WHEN i0.SKIDSIZE = 4 THEN '3.5X5'
        WHEN i0.SKIDSIZE = 5 THEN '3.5X7'
        WHEN i0.SKIDSIZE = 16 THEN 'No Skid'
        WHEN i0.SKIDSIZE = 18 THEN '5X8'
        ELSE 'Check' END) AS Item_Pallet_Type
		,
	(CASE
		WHEN i0.ITCLS NOT LIKE 'Z%' THEN 'RP_racking_area'
		WHEN i0.PICKPUT = 'UPH' THEN 'UPH_racking_area'
		WHEN i0.PICKPUT = 'PALLT' AND i0.SKIDSIZE IN ('4') THEN 'CG_3.5X5_area'
		WHEN i0.PICKPUT = 'PALLT' AND i0.SKIDSIZE IN ('5') THEN 'CG_3.5X7_area'
		WHEN i0.PICKPUT = 'PALLT' AND i0.PUTAWAY_CLASS IN ('RAILS') THEN 'CG_rails_area'
		WHEN i0.PICKPUT = 'PALLT' AND i0.PUTAWAY_CLASS IN ('FLOOR','FLOOROP') THEN 'CG_bulk_stack_area'
		ELSE 'CG_racking_area' END) AS product_fit_Category,
		CONVERT(DECIMAL(10,2),r0.Racking_Qty*i0.B2Z95S*0.028317) AS Racking_Product_CBM,
	(CASE
		WHEN  i0.ITCLS NOT LIKE 'Z%' THEN 0.001
		WHEN  i0.PICKPUT = 'UPH' then 0
		WHEN  i0.PICKPUT = 'PALLT' AND i0.SCOOPQTY=0 THEN CEILING(r0.Racking_Qty/10)
	    ELSE CEILING(r0.Racking_Qty/i0.SCOOPQTY) END) AS Pallet_Qty,
    i0.WEGHT * 0.453592 as 'Unit_Weight(Kg)',
    f.LocationId as Primary_location
		--ELSE CEILING(r0.Racking_Qty/i0.SCOOPQTY) END) AS Pallet_Qty
FROM
(
SELECT t1.item_number, t1.location_id, COUNT(t1.serial_number) as Racking_Qty
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id  IN ('335') AND T1.location_id LIKE 'A3%' AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S')
--AND SUBSTRING(t1.location_id,4,2) IN ('10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25')
--AND SUBSTRING(t1.location_id,7,1) NOT IN ('1')
GROUP BY t1.item_number, t1.location_id
) AS r0

LEFT JOIN
(
SELECT i.ITNBR, i.ITCLS, i.B2Z95S, i1.TIHIUNLD, i1.PICKPUT,i.WEGHT, i1.PUTAWAY_CLASS, i1.UNITSWIDE, i1.UNITLAYERS, i1.UNITSDEEP, i1.SCOOPQTY, i1.SKIDSIZE
FROM (SELECT * FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID IN ('335'))  AS i,
(SELECT b.ITNBR, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID AS PUTAWAY_CLASS, b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE
FROM MasterData_ItemMaster_AFI.ITBEXT as b WHERE b.House in ('335')
) AS i1
WHERE i.ITNBR = i1.ITNBR
) as i0 ON r0.item_number = i0.ITNBR
LEFT JOIN
(SELECT * FROM  Distribution_Warehouse_Wholesale.t_forward_pick AS a WHERE a.wh_id IN ('335') and a.LocationId NOT IN ('A1001AA9','A1001AA1')) AS f
on r0.item_number = f.itemnumber


--
-- SELECT top 10 * FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID IN ('335')
--
-- SELECT top 1000 * FROM  Distribution_Warehouse_Wholesale.t_forward_pick AS a WHERE a.wh_id IN ('335')
