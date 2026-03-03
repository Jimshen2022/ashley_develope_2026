
--MIL Unit Volume
SELECT a1."House", a1."ItemNumber", a1.ITCLS, a1."MasterUnitCubes", a1."OnHand", 0 as "Open PO"
FROM
(SELECT t1.STID AS "House", t1.ITNBR as "ItemNumber", t1.ITCLS, t1.B2Z95S as "MasterUnitCubes", t2.MOHTQ as "OnHand"
FROM AMFLIBL.ITMRVA t1
LEFT JOIN AMFLIBL.ITEMBL t2 ON t1.ITNBR=t2.ITNBR and t1.STID=t2.HOUSE
WHERE t1.STID IN ('51') AND t1.ITCLS like 'Z%' and t1.ITCLS not like '%K' ) a1