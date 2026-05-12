/*  Jan.06.2026,  Defined of transactions created by Jim,Shen

151 --- Receiving
183 --- Receiving
951 --- undo lp receiving (negative receiving)
347 --- piece shipped
*/

DECLARE @tran_list AS VARCHAR(500);
DECLARE @StartDate DATETIME;
DECLARE @EndDate DATETIME;

SET @tran_list = '151,183,951,347';

SET @StartDate = DATEADD(DAY, -10, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
SET @EndDate = GETDATE();

With itm as (
    select distinct
        t3.item_number,
        t3.wh_id,
        t3.description,
        t3.commodity_code,
        t3.pick_put_id,
        t3.unit_volume,
        t3.unit_volume * 0.028317 as Unit_CBM,
        CASE
            WHEN t3.pick_put_id = 'UPH' THEN 'UPH'
            ELSE 'CG'
        END AS product,
        t4.class_id,
        t4.units_per_layer,
        t4.layers_per_uom,
        t4.max_in_layer,
        t4.std_hand_qty as scoop_qty,
        t4.pallet_id
    from (SELECT a1.wh_id, a1.item_number, a1.commodity_code, a1.unit_volume, a1.description, a1.pick_put_id FROM t_item_master(nolock) AS a1) as t3
    left join (SELECT a2.item_number,a2.class_id,a2.units_per_layer,a2.layers_per_uom,a2.max_in_layer,a2.std_hand_qty,a2.pallet_id
                      FROM t_item_uom(nolock) AS a2 where a2.uom = 'SCOOP') as t4
        ON t3.item_number = t4.item_number
),
loc AS (
    select
        t1.wh_id,
        t1.location_id,
        t1.status,
        t1.type
    from t_location(nolock) as t1
),
em AS (
    select *
    from t_employee(nolock) a
),
dept as (
    select *
    from t_department(nolock) as t1
),
grp as (
    select *
    from t_group(nolock) as t1
),
trx AS (
    SELECT
        t1.item_number,
        i.commodity_code,
        i.pick_put_id,
        case when t1.lot_number is null then 'no_sn' else t1.lot_number end as lot_number,
        t1.wh_id as whse,
        t1.location_id as from_loc,
        l.type as loc_type,
        t1.location_id_2 as to_loc,
        l2.type AS loc_type_2,
        t1.control_number as wa_order,
        t1.control_number_2 as reference,
        t1.tran_qty,
        t1.hu_id as license_plate,
        t1.tran_type,
        t1.description,
        t1.employee_id,
        e.name as emp_name,
        e.dept as dept_nbr,
        d1.description as deparment,
        e.group_nbr,
        g.description as group_name,
        e.supervisor_nbr,
        e.supervisor,
        t1.start_tran_date,
        t1.start_tran_time,
        t1.end_tran_date,
        t1.end_tran_time,
        t1.elapsed_time,
        t1.return_disposition as backorder_reason,
        t1.employee_id_2,
        t1.routing_code,
        t1.hu_id_2,
        t1.log_id,
        t1.equipment_zone,
        CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS trx_date_time,
        case when i.product is not null then i.product
            ELSE 'CG'
        END AS product,
        CASE
            WHEN t1.tran_type IN ('951') THEN t1.tran_qty * -1
            ELSE t1.tran_qty
        END AS trx_qty,
        CASE
            WHEN CAST(t1.start_tran_time AS TIME) >= '00:00:00' and CAST(t1.start_tran_time AS TIME) < '07:00:00' THEN DATEADD(DAY, -1, t1.start_tran_date)
            ELSE t1.start_tran_date
        END AS shift_date,
        CASE
            WHEN CAST(t1.start_tran_time AS TIME) BETWEEN '07:00:00' AND '18:59:59' THEN 'D'
            ELSE 'N'
        END AS shift,
        CASE
            WHEN t1.tran_type in ('151','183','951') then 'Inbound'
            WHEN t1.tran_type in ('347')             then 'Outbound'
            ELSE 'not_pph_trx'
        END AS pph_type,
        i.scoop_qty as SCOOPQTY
    FROM (
        SELECT *
        FROM t_tran_log(nolock)
        WHERE tran_type IN (SELECT TRIM(value) FROM STRING_SPLIT(@tran_list, ','))
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) >= @StartDate
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) <= @EndDate
    ) AS t1
    LEFT JOIN itm as i on t1.item_number = i.item_number and t1.wh_id = i.wh_id
    LEFT JOIN loc as l on t1.location_id = l.location_id
    LEFT JOIN loc as l2 on t1.location_id_2 = l2.location_id
    LEFT JOIN em as e on t1.employee_id = e.emp_number
    LEFT JOIN dept as d1 on e.dept = d1.department_code
    LEFT JOIN grp as g on e.group_nbr = g.group_nbr
),
trx_2 as (
    SELECT t.*,
        0 AS rn,
        ROW_NUMBER() OVER (
            PARTITION BY t.start_tran_date, t.employee_id, t.item_number, t.lot_number
            ORDER BY t.trx_date_time
        ) as row_num
    FROM trx AS t
    where t.pph_type in ('Inbound', 'Outbound')
),
trx_3 as (
    SELECT
        t9.*,
        0 AS Pallet_Qty,
        CASE
            WHEN t9.row_num in (0,1) THEN t9.trx_qty
            ELSE 0
        END AS pieces,
        CONCAT(CAST(t9.shift_date AS VARCHAR(20)),'_',t9.employee_id,'_', t9.pph_type) as emp_date_job_string,
        CONCAT(CAST(t9.shift_date AS VARCHAR(20)),'_',t9.employee_id) as emp_date_string
    FROM trx_2 AS t9
)
select
    d.item_number,
    d.commodity_code,
    d.pick_put_id,
    d.whse,
    d.tran_type,
    d.[description],
    d.employee_id,
    d.emp_name,
    d.dept_nbr,
    d.deparment,
    d.group_nbr,
    d.group_name,
    d.supervisor_nbr,
    d.supervisor,
    d.start_tran_date,
    d.product,
    d.shift_date,
    d.[shift],
    d.pph_type,
    d.SCOOPQTY,
    SUM(d.Pallet_Qty) as Pallet_Qty,
    SUM(d.pieces) as pieces
from trx_3 as d
where d.pieces > 0
group by
    d.item_number,
    d.commodity_code,
    d.pick_put_id,
    d.whse,
    d.tran_type,
    d.[description],
    d.employee_id,
    d.emp_name,
    d.dept_nbr,
    d.deparment,
    d.group_nbr,
    d.group_name,
    d.supervisor_nbr,
    d.supervisor,
    d.start_tran_date,
    d.product,
    d.shift_date,
    d.[shift],
    d.pph_type,
    d.SCOOPQTY
order by d.shift_date, d.item_number, d.pph_type, d.employee_id;