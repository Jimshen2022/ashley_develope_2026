SELECT
	t.tran_type,
	t.description,
	t.start_tran_date,
	t.control_number,
	t.control_number_2,
	t.item_number,
	SUM(case when t.tran_type = '951' then -t.tran_qty else t.tran_qty end) AS tran_qty
FROM [PowerBI_Distribution].[TranLog] AS t
WHERE t.wh_id = '335'
AND t.tran_type IN  ('951','151')
AND t.item_number ='T383-13'
AND t.start_tran_date > '2025-05-01'
GROUP BY
	t.tran_type,
	t.description,
	t.start_tran_date,
	t.control_number,
	t.control_number_2,
	t.item_number
ORDER BY t.item_number, t.start_tran_date DESC