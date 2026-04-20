SELECT TOP 10 * FROM t_tran_log as t  WHERE t.start_tran_date between '2025-08-31' and '2025-09-15' And t.tran_type in ('347')







--- outbount
SELECT t.item_number as Item#, t.control_number_2 as Trip#, t.start_tran_date as [Date], t.routing_code as CTN#, SUM(t.tran_qty)  as Shipped_Qty,  CAST(CAST(SUBSTRING(control_number_2, 1, 7) AS INT) AS VARCHAR) AS Trip_Number
FROM t_tran_log as t  
WHERE t.start_tran_date between '2025-09-15' and '2025-10-15' 
	And t.tran_type in ('347')
	AND t.item_number in ('H769-21')

GROUP BY t.item_number,t.control_number_2,t.start_tran_date,t.routing_code, CAST(CAST(SUBSTRING(control_number_2, 1, 7) AS INT) AS VARCHAR)
ORDER BY t.start_tran_date

--- inbound
SELECT t.item_number as Item#, t.control_number_2 as Trip#, t.start_tran_date as [Date], t.routing_code as CTN#, SUM(t.tran_qty)  as Shipped_Qty
FROM t_tran_log as t  
WHERE t.start_tran_date between '2025-09-01' and '2025-10-15' 
	And t.tran_type in ('151','183','951')
	AND t.item_number in ('H769-21')

GROUP BY t.item_number,t.control_number_2,t.start_tran_date,t.routing_code
ORDER BY t.start_tran_date


-- 855 
select *
FROM t_tran_log as t
where t.item_number = 'D769-01' 
and t.tran_type = '855'
and t.start_tran_date between '2025-09-21' and '2025-10-15'


--sn
select *
FROM t_tran_log as t
where t.item_number = 'D769-01' 
and t.lot_number = '688075291412'
and t.start_tran_date between '2025-09-21' and '2025-10-15'
order by t.start_tran_date, t.start_tran_time 