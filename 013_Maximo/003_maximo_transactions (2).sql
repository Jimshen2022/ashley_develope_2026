WITH unit_cost AS (
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
commodity as ( 
	select * from Manufacturing_Maximo.Commodities as t where t.itemsetid= 'VNMSET'
	)
SELECT *,
    CAST(t1.transdate AS DATE) AS transaction_date,
    YEAR(t1.transdate) AS transaction_year,
    MONTH(t1.transdate) AS transaction_month,
    CASE 
        WHEN t1.unitcost > 0 THEN t1.linecost
        WHEN t1.unitcost = 0 AND uc.unitcost > 0 THEN uc.unitcost * ABS(t1.quantity) 
        ELSE 0 
    END AS issued_cost
FROM Manufacturing_Maximo.MatUseTrans as t1
LEFT JOIN Manufacturing_Maximo.item AS t0 on t0.itemsetid = 'VNMSET' AND t1.itemnum = t0.itemnum
LEFT JOIN commodity as c on c.commodity = t0.commoditygroup
LEFT JOIN uc on uc.itemnum = t1.itemnum
WHERE t1.siteid = 'VNM.ASPM' 
ORDER BY t1.transdate DESC