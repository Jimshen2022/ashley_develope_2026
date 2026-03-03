-- Inventory on hand cretaed by Jim,Shen on Mar.27.2025
WITH  unit_cost AS (
    SELECT 
        t0.itemnum, 
        t0.unitcost,
        ROW_NUMBER() OVER (PARTITION BY t0.itemnum ORDER BY t0.transdate DESC) AS rn
    FROM Manufacturing_Maximo.MatUseTrans AS t0
    WHERE t0.siteid = 'VNM.ASPM' 
        AND t0.unitcost <> 0
),
uc as 
(
SELECT 
    itemnum,
    unitcost
FROM Unit_cost
WHERE rn = 1
),
LatestSnapshot AS (
    SELECT MAX(SnapshotDate) AS SnapshotDate 
    FROM Manufacturing_Maximo.invbalances 
    WHERE location = 'MROSTORE'
),
commodity as ( 
	select * from Manufacturing_Maximo.Commodities as t where t.itemsetid= 'VNMSET'
	)
SELECT t1.itemnum,
	t0.description,
	t0.orderunit,
	t0.issueunit,
	t0.commoditygroup,
	c.description,
	t0.itemtype,
	t0.status,
	t1.location,
	t1.binnum,
	t1.curbal as onhand,
	t1.curbal * uc.unitcost as [amount($VND)],
	t1.orgid,
	t1.siteid,
	t1.itemsetid,
	DATEADD(HOUR, 12, t1.SnapshotDate) AS SnapshotDate
FROM Manufacturing_Maximo.invbalances AS t1
JOIN LatestSnapshot ls 
    ON t1.SnapshotDate = ls.SnapshotDate
LEFT JOIN Manufacturing_Maximo.item AS t0 on t0.itemsetid = 'VNMSET' AND t1.itemnum = t0.itemnum
LEFT JOIN commodity as c on c.commodity = t0.commoditygroup
LEFT JOIN uc on uc.itemnum = t1.itemnum
WHERE t1.location LIKE 'MROSTORE%'
    AND t1.curbal > 0
    AND t1.siteid = 'VNM.ASPM'
ORDER BY t1.itemnum

