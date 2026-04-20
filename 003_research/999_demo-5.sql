WITH mo AS (
SELECT t1.item_number, 
	t1.lot_number, 
	t1.control_number_2 as mo_nbr,
	MIN(t1.start_tran_date) as start_tran_date
FROM [PowerBI_Distribution].[TranLog] AS t1 
WHERE t1.wh_id in ('35','34','31','33') 
	AND t1.tran_type = '111'
	AND t1.start_tran_date > DATEADD(DAY, - 30, GETDATE())
group by t1.item_number, 
	t1.lot_number, 
	t1.control_number_2	
),
SELECT
    top 10
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    t3.control_number,
    t3.control_number_2,
    mo.mo_nbr,
    DATEPART(HOUR, t3.start_tran_time) AS TRAN_HOUR,
    SUM(t3.tran_qty) AS qty
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN mo ON mo.item_number = t3.item_number and mo.lot_number = t3.lot_number
WHERE t3.wh_id in ('35','31','31','34')
    AND t3.tran_type = '374'
    AND t3.start_tran_date >= CAST(GETDATE() - 21 AS DATE) -- 最近3周
    AND t3.start_tran_date <= CAST(GETDATE() AS DATE)
GROUP BY
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    t3.control_number,
    t3.control_number_2,
    mo.mo_nbr,
    DATEPART(HOUR, t3.start_tran_time)
ORDER BY
    t3.wh_id,
    t3.item_number,
    t3.start_tran_date,
    t3.control_number,
    TRAN_HOUR;        
