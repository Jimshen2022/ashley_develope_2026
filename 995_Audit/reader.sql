--select top 10 * from t_employee

-- Query current employee login Reader device and detailed information
DECLARE @in_EmployeeID VARCHAR(30) = 'YOUR_EMPLOYEE_ID_HERE'  -- Set employee ID parameter

SELECT 
    e.wh_id AS warehouse_id,
    e.id AS employee_id,
    e.name AS employee_name,
    e.device AS scanner_id,
    loc.location_id AS fork_location,
    loc.type AS location_type,
    -- Inventory details
    ISNULL(SUM(CASE WHEN sto.type <> 'STORAGE' THEN sto.actual_qty ELSE 0 END), 0) AS allocated_inv_qty,
    ISNULL(SUM(CASE WHEN sto.type = 'STORAGE' THEN sto.actual_qty ELSE 0 END), 0) AS non_allocated_inv_qty,
    MAX(CASE WHEN sto.type <> 'STORAGE' THEN sto.location_id ELSE '' END) AS allocated_inv_location,
    MAX(CASE WHEN sto.type = 'STORAGE' THEN sto.location_id ELSE '' END) AS non_allocated_inv_location,
    -- Work queue information
    (SELECT COUNT(1) 
     FROM dbo.t_work_q_assignment wqa (NOLOCK) 
     WHERE wqa.user_assigned = e.id 
     AND wqa.wh_id = e.wh_id) AS work_queue_count,
     dateadd(hour, 7, GETUTCDATE()) AS query_timestamp
FROM dbo.t_employee e (NOLOCK)
LEFT JOIN dbo.t_location loc (NOLOCK) 
    ON e.id = loc.c1
LEFT JOIN dbo.t_stored_item sto (NOLOCK) 
    ON loc.location_id = sto.location_id 
    AND e.wh_id = sto.wh_id
    AND loc.type IN ('F', 'CR')  -- F=Fork, CR=LTC Cart2
WHERE e.id LIKE '%'
  AND e.device IS NOT NULL  -- Only query employees logged into devices
GROUP BY 
    e.wh_id,
    e.id,
    e.name,
    e.device,
    loc.location_id,
    loc.type
