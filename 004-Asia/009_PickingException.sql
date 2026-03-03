WITH emp AS (
    SELECT t1.wh_id, t1.id, t1.name, t1.dept, t1.supervisor
FROM Distribution_Warehouse_Wholesale.t_employee AS t1
WHERE t1.wh_id IN ('335','35','31','33','34','51') AND t1.status IN ('A')
),
dpt AS (
    SELECT t1.wh_id, t1.department, t1.description, t1.department_code
FROM Distribution_Warehouse_Wholesale.Department as t1
WHERE t1.wh_id IN ('335','35','31','33','34','51')),
trx AS (
SELECT t1.wh_id, t1.employee_id, e1.name, e1.dept, d1.description
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN emp as e1 on e1.wh_id = t1.wh_id and e1.id = t1.employee_id
LEFT JOIN dpt as d1 on d1.wh_id = e1.wh_id and d1.department = e1.dept
WHERE t1.wh_id IN ('335','35','31','33','34','51')
GROUP BY t1.wh_id, t1.employee_id, e1.name, e1.dept, d1.description
)
-------------------------------Main Query ----------------------------------------
SELECT 	t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date
	--, CAST(t1.start_tran_time AS TIME(0)) as star_tran_time
	--, t1.end_tran_date
	--, CAST(t1.end_tran_time AS TIME(0)) as end_tran_time
	, t1.employee_id
    , e1.name
    , e1.dept
    , d1.description
	--, t1.control_number
	--, t1.line_number
	--, t1.control_number_2 as reference
	--, t1.hu_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.uom
	, t1.tran_qty
	, t1.location_id AS 'from Location'
	, t1.location_id_2 AS 'To Location'
	, t1.employee_id_2
    , t1.outside_id AS Creation_Transaction
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN emp as e1 on e1.wh_id = t1.wh_id and e1.id = t1.employee_id
LEFT JOIN dpt as d1 on d1.wh_id = e1.wh_id and d1.department = e1.dept
WHERE t1.wh_id IN ('335')
--     AND t1.start_tran_date > '2024-01-17'
--     AND t1.tran_type IN ('840')
--     AND t1.outside_id LIKE '3%'
    AND t1.employee_id like 'WA%'
ORDER BY t1.lot_number,t1.start_tran_date,t1.start_tran_time


/*
--SELECT t1.wh_id, t1.id, t1.name, t1.dept, t1.supervisor
SELECT *
FROM Distribution_Warehouse_Wholesale.t_employee AS t1
WHERE t1.wh_id IN ('335') and t1.id in ('33333')

SELECT TOP 10 *
FROM Distribution_Warehouse_Wholesale.Employee as t1
WHERE t1.wh_id IN ('335')

SELECT *
FROM Distribution_Warehouse_Wholesale.Department as t1
WHERE t1.wh_id IN ('335')

SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2024-01-01'
AND t1.employee_id LIKE '[0-9T]%'
AND t1.lot_number IS NOT null
AND t1.tran_type NOT IN ('001','002','402','403','404','408')


SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335')
--AND t1.start_tran_date > '2024-01-01'
AND t1.employee_id IN ('3333')


*/