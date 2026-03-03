With itm AS (
    select t1.item_number
	, t1.wh_id
	, t1.description
	, t1.uom
	, t1.commodity_code
	, t1.pick_put_id
    , t2.conversion_factor
    from (select * from Distribution_Warehouse_Wholesale.t_item_master as a1  where a1.wh_id = '335') as t1
    left join Distribution_Warehouse_Wholesale.t_item_uom as t2 on t1.item_number = t2.item_number and t1.wh_id = t2.wh_id
),
loc AS (
        select t1.wh_id, t1.location_id, t1.status, t1.TypeDescription
        from Distribution_Warehouse_Wholesale.t_location as t1
        where t1.wh_id = '335'
            ),
em AS (
        select top 10 *
            from Distribution_Warehouse_Wholesale.t_employee a where a.wh_id = '335'
	      ),
dept as (
        select  *
        from Distribution_Warehouse_Wholesale.Department as t1
        where t1.wh_id in ('335')
             ),
    grp as (
        select  *
        from Distribution_Warehouse_Wholesale.[Group] as t1
        where t1.wh_id in ('335')
    ),
Trx AS
    (SELECT *
     FROM Distribution_Warehouse_Wholesale.TranLog as a WHERE a.wh_id = '335')
-----------Main Query------------------
SELECT t1.item_number
               , i.commodity_code
               , i.pick_put_id
               , i.conversion_factor
               , t1.lot_number                      as serial_number
               , t1.wh_id                           as whse
               , t1.location_id                     as from_loc
               , l.TypeDescription                  as loc_type
               , t1.location_id_2                   as to_loc
               , l2.TypeDescription                 AS loc_type_2
               , t1.control_number                  as wa_order
               , t1.control_number_2                as reference
               , 0                                  as 'system_quantity'
               , t1.tran_qty
               , t1.hu_id                           as license_plate
               , t1.tran_type
               , t1.description
               , t1.employee_id
               , e.name                             as emp_name
               , e.dept                             as dept_nbr
               , d1.description                     as deparment
               , e.group_nbr
               , g.Description                      as group_name
               , e.supervisor_nbr
               , e.supervisor
               , t1.start_tran_date
               , t1.start_tran_time
               , t1.end_tran_date
               , t1.end_tran_time
               , t1.elapsed_time
               , t1.return_disposition              as backorder_reason
               , t1.line_number
               , t1.outside_id
               , t1.num_items
               , t1.uom
               , t1.wh_id_2
               , t1.verify_status
               , t1.employee_id_2
               , t1.routing_code
               , t1.hu_id_2
               , t1.log_id
               , t1.afi_package_rate
               , t1.Wh_id_3
               , t1.equipment_zone
               , CAST(t1.[start_tran_date] AS DATE) AS Trx_Date
               , CAST(t1.start_tran_time as time)   as Trx_Time
               , (CASE
                      WHEN SUBSTRING(t1.item_number, 1, 4) = '100-' THEN 'CG'
                      WHEN t1.item_number LIKE 'RP%' THEN 'RP'
                      WHEN SUBSTRING(t1.item_number, 1, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', 'U')
                          THEN 'UPH'
                      ELSE 'CG' END)                AS Product
               , CASE
                     WHEN t1.tran_type IN ('951') THEN t1.tran_qty * -1
                     ELSE t1.tran_qty END  AS Picked_Qty
           FROM Trx AS t1
           LEFT JOIN itm as i on t1.item_number = i.item_number and t1.wh_id = i.wh_id
           LEFT JOIN loc as l on t1.wh_id = l.wh_id and t1.location_id = l.location_id
           LEFT JOIN loc as l2 on t1.wh_id = l2.wh_id and t1.location_id_2 = l2.location_id
           LEFT JOIN em as e on t1.wh_id = e.wh_id and t1.employee_id = e.emp_number
           LEFT JOIN dept as d1 on e.wh_id = d1.wh_id and e.dept = d1.department_code
           LEFT JOIN grp as g on e.wh_id = e.wh_id and e.dept = g.Department and e.group_nbr = g.GroupNbr
          WHERE t1.wh_id IN ('335')
            AND t1.start_tran_date >= '2024-10-01'
            AND t1.tran_type IN ('363')