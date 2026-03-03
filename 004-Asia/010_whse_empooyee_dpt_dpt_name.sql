WITH emp AS (
    SELECT t1.wh_id, t1.id, t1.name, t1.dept, t1.supervisor
FROM Distribution_Warehouse_Wholesale.t_employee AS t1
WHERE t1.wh_id IN ('335','35','31','33','34','51')
),
dpt AS (SELECT t1.wh_id, t1.department, t1.description, t1.department_code
        FROM Distribution_Warehouse_Wholesale.Department as t1
        WHERE t1.wh_id IN ('335', '35', '31', '33', '34', '51')
        )
------------------- main --------------------------------------------------
SELECT t1.wh_id, t1.employee_id, e1.name, e1.dept, d1.description
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN emp as e1 on e1.wh_id = t1.wh_id and e1.id = t1.employee_id
LEFT JOIN dpt as d1 on d1.wh_id = e1.wh_id and d1.department = e1.dept
WHERE t1.wh_id IN ('335','35','31','33','34','51')
AND t1.start_tran_date > '2024-01-01'
AND t1.employee_id LIKE '[0-9T]%'
AND t1.lot_number IS NOT null
AND t1.tran_type NOT IN ('001','002','402','403','404','408')
GROUP BY t1.wh_id, t1.employee_id, e1.name, e1.dept, d1.description

