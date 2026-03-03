/*
--maximo PO query
select top 10 * from Manufacturing_Maximo.Po  WHERE ponum = 'PF001194'
select top 10 * from Manufacturing_Maximo.PoLine  WHERE ponum = 'PF001194'
select top 10 * from Manufacturing_Maximo.Matrectrans where ponum = 'PF001194'

select top 10 * from Manufacturing_Maximo.Po  where  siteid = 'VNM.ASPM'  and ponum = 'PF001343'
select top 10 * from Manufacturing_Maximo.PoLine where siteid = 'VNM.ASPM'  and ponum = 'PF001343'
select top 100 * from Maximo_DW.DimMROPurchaseOrderDetails where [Purchase Order Number] = 'PF001343'
select top 100 * from Maximo_DW.FactMROPurchaseOrder  where [Purchase Order Number] = 'PF001343'
-- 先找出重复的 ponum
SELECT 
    t.ponum,
    COUNT(*) as 重复次数
FROM Manufacturing_Maximo.Po as t 
WHERE siteid = 'VNM.ASPM'
GROUP BY t.ponum
HAVING COUNT(*) > 1;  

-- 或者查看重复 ponum 的详细信息
SELECT 
    t.ponum,
    t.purchaseagent,
    t.description,
    t.orderdate,
    t.requireddate,
    t.potype,
    t.status,
    t.statusdate,
    t.vendor,
    t.totalcost
FROM Manufacturing_Maximo.Po as t 
WHERE siteid = 'VNM.ASPM'
    AND t.ponum IN (
        SELECT ponum
        FROM Manufacturing_Maximo.Po
        WHERE siteid = 'VNM.ASPM'
        GROUP BY ponum
        HAVING COUNT(*) > 1
    )
ORDER BY t.ponum;

*/

-- 相同的ponum, 保留 statusdate 最大的那行
SELECT 
    ponum,
    purchaseagent,
    description,
    orderdate,
    requireddate,
    potype,
    status,
    statusdate,
    vendor,
    totalcost
FROM (
    SELECT 
        t.ponum,
        t.purchaseagent,
        t.description,
        t.orderdate,
        t.requireddate,
        t.potype,
        t.status,
        t.statusdate,
        t.vendor,
        t.totalcost,
        ROW_NUMBER() OVER (PARTITION BY t.ponum ORDER BY t.statusdate DESC) as rn
    FROM Manufacturing_Maximo.Po as t 
    WHERE siteid = 'VNM.ASPM'
) as ranked
WHERE rn = 1 and 


-- PO query
select t.ponum,
	t.purchaseagent,
	t.description,
	t.orderdate,
	t.requireddate,
	t.potype,
	t.status,
	t.statusdate,
	t.vendor,
	t.totalcost
from Manufacturing_Maximo.Po as t where  siteid = 'VNM.ASPM' 
group by 
	t.ponum,
	t.purchaseagent,
	t.description,
	t.orderdate,
	t.requireddate,
	t.potype,
	t.status,
	t.statusdate,
	t.vendor,
	t.totalcost



