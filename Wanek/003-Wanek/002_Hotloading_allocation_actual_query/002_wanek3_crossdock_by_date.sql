WITH mo AS (
SELECT t1.item_number, 
	t1.lot_number, 
	t1.control_number_2 as mo_nbr,
	MIN(t1.start_tran_date) as start_tran_date
FROM [PowerBI_Distribution].[TranLog] AS t1 
WHERE t1.wh_id in ('35','34','31','33') 
	AND t1.tran_type = '111'
	AND t1.start_tran_date > DATEADD(DAY, - 720, GETDATE())
group by t1.item_number, 
	t1.lot_number, 
	t1.control_number_2	
),
trx as (
SELECT 
	MAX(t3.start_tran_date) AS start_tran_date ,
	t3.wh_id,  
    t3.control_number_2 AS destination,
    t3.item_number,
    t3.control_number as order_nbr,
	t3.lot_number,
	mo.mo_nbr
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN mo ON mo.item_number = t3.item_number and mo.lot_number = t3.lot_number
WHERE t3.wh_id in ('35','34','31','33')                          -- 可替换为你自己的仓库 ID
  AND t3.tran_type = '374'                     -- 可替换为你需要的交易类型
  AND t3.start_tran_date > DATEADD(DAY, -21, GETDATE())
GROUP BY
	t3.wh_id,  
    t3.control_number_2,
    t3.item_number,
    t3.control_number,
	t3.lot_number,
	mo.mo_nbr
)
SELECT  t.wh_id,
	t.destination,
	t.item_number,
	t.order_nbr,
	t.mo_nbr,
	COUNT(t.lot_number) as Qty,
	MAX(t.start_tran_date) as start_tran_date
FROM trx as t 
GROUP by 
	t.wh_id,
	t.destination,
	t.item_number,
	t.order_nbr,
	t.mo_nbr