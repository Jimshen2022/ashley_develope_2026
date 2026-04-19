SELECT t.item_number as Item#,
	   t.control_number_2 as Container#,
	   t.control_number as PO#,
	   t.start_tran_date as [Date],	   
	   SUM(CASE 
			WHEN t.tran_type ='951' then -t.tran_qty
			ELSE t.tran_qty END)  as Received_Qty
FROM t_tran_log as t
WHERE t.start_tran_date between '2025-08-31' and '2025-09-15'
	and t.tran_type in ('151')
GROUP BY t.item_number,
	   t.control_number_2,
	   t.control_number,
	   t.start_tran_date

