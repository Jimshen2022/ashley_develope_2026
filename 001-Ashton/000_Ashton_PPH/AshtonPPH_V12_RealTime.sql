/*  Jan.06.2026,  Defined of transactions created by Jim,Shen

151 --- Receiving
183 --- Receiving
951 --- undo lp receiving (negative receiving)
321 --- Loading
363 --- picking
372 --- picking (crossdock)
347 --- piece shipped
252 --- Replenishment
254 --- Put away
262 --- Replenishment
202 --- put away
Reference like 'RS%' and to_location like 'A%' ----- "Putting Away"
Reference like 'RS%' and to_location like 'DR%' ----- "Putting Away"
tran_code = '202' and reference like 'CN%' and  to_location like 'A%' ----- "Receiving"
tran_code = '202' and reference like 'CN%' and  to_location like 'UL%' ----- "Receiving"
tran_code = '202' and reference like 'UL%' and  to_location like 'A%' -----  "Putting Away"

select distinct pick_put_id from t_item_master where wh_id = '335'
*/

DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list AS VARCHAR(500);
DECLARE @StartDate DATETIME;
DECLARE @EndDate DATETIME;
SET @wh_id_list = '335,335';
SET @tran_list = '151,183,951,321,363,372,347,252,254,262,202';

--SET @StartDate = DATEADD(DAY, -31, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
--SET @StartDate = '2025-01-01 07:00:00.000';
SET @StartDate =  CAST(CAST(GETDATAE() AS DATE) AS DATETIME);
SET @EndDate = GETDATE();

With itm as (
    select distinct
        item_number,
        description,
        commodity_code,
        pick_put_id,
        CASE
            WHEN pick_put_id = 'UPH' THEN 'UPH'
            WHEN pick_put_id like '%RP%' THEN 'RP' 
            ELSE 'CG'
        END AS product
    from t_item_master(nolock)
),
trx AS (
    SELECT
        t1.item_number,
        i.commodity_code,
        i.pick_put_id,
        case when t1.lot_number is null then 'no_sn' else t1.lot_number end as lot_number,
        t1.wh_id as whse,
        t1.location_id as from_loc,
        t1.location_id_2 as to_loc,
        t1.control_number as wa_order,
        t1.control_number_2 as reference,
        t1.tran_qty,
        t1.hu_id as license_plate,
        t1.tran_type,
        t1.description,
        t1.employee_id,
        t1.start_tran_date,
        t1.start_tran_time,
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
            WHEN t1.tran_type in ('151','183','951') then 'Unloading'
            WHEN t1.tran_type in ('321') then 'Loading'
            WHEN t1.tran_type in ('363') and (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')  and t1.hu_id is not null then 'Picking-SCOOP'
            WHEN t1.tran_type in ('363','372') then 'Picking'
            WHEN t1.tran_type in ('347') then 'Piece shipped'
            WHEN t1.tran_type in ('252','262') then 'Replenishment'
            WHEN t1.tran_type in ('254') and t1.location_id_2 <> 'RP998XL3' then 'Put away'
            WHEN t1.control_number_2 like 'RS%' and t1.location_id_2 like 'A%' then 'Put away'
            WHEN t1.control_number_2 like 'RS%' and t1.location_id_2 like 'DR%' then 'Put away'
            WHEN t1.tran_type = '202' and t1.control_number_2 like 'CN%' and t1.location_id_2 like 'A%' then 'Unloading'
            WHEN t1.tran_type = '202' and t1.control_number_2 like 'UL%' and t1.location_id_2 like 'A%' then 'Put away'
            ELSE 'not_pph_trx'
        END AS pph_type,
        i.scoopqty
    FROM (
        SELECT *
        FROM t_tran_log (nolock)
        WHERE wh_id IN (SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ','))
            AND tran_type IN (SELECT TRIM(value) FROM STRING_SPLIT(@tran_list, ','))
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) > @StartDate
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) < @EndDate
    ) AS t1
    LEFT JOIN itm as i on t1.item_number = i.item_number and t1.wh_id = i.wh_id
),
trx_2 as (
    SELECT t.*,
       CASE
            WHEN t.pph_type in ('Put away','Replenishment') and t.pick_put_id = 'PALLT'  then
               ROW_NUMBER() OVER (
                   PARTITION BY t.start_tran_date, t.employee_id, t.item_number, t.from_loc, t.to_loc, t.wa_order, t.reference, t.tran_type
                   ORDER BY t.trx_date_time)
			WHEN t.pph_type in ('Picking-SCOOP') then
               ROW_NUMBER() OVER (
                   PARTITION BY t.start_tran_date, t.employee_id, t.item_number, t.to_loc, t.license_plate
                   ORDER BY t.trx_date_time)
            ELSE 0 END AS rn,
        CASE
            WHEN t.pph_type in ('Put away','Replenishment') and t.pick_put_id = 'PALLT' then
                ROW_NUMBER() OVER (
                    PARTITION BY t.start_tran_date, t.employee_id, t.item_number, t.lot_number
                    ORDER BY t.trx_date_time
                )
            ELSE 0
        END as row_num
    FROM trx AS t
    where t.pph_type not in ('not_pph_trx')
),
trx_3 as (
SELECT
   t9.*,
    CASE WHEN t9.rn = 1 THEN 1 ELSE 0 END AS Pallet_Qty,
    CASE
        WHEN t9.row_num in (0,1) THEN t9.trx_qty
        ELSE 0
    END AS pieces, -- get rid of duplicate serial numbers trx on same day for same item by same employee
    CASE
        WHEN t9.pph_type in ('Picking','Loading') THEN 'CG/UPH'
        ELSE t9.product END as product_category
FROM trx_2 AS t9
)
select d.item_number,
    d.commodity_code,
    d.pick_put_id,
    d.whse,
    d.tran_type,
    d.[description],
    d.employee_id,
    d.group_nbr,
    d.group_name,
    d.supervisor_nbr,
    d.supervisor,
    d.start_tran_date,
    d.product,
    d.shift_date,
    d.[shift],
    d.pph_type,
    d.product_category,
    d.SCOOPQTY,
    SUM(d.Pallet_Qty) as Pallet_Qty,
    SUM(d.pieces) as pieces
from trx_3 as d
where d.pieces > 0
group by d.item_number,
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
    d.product_category,
    d.SCOOPQTY
order by d.shift_date, d.item_number, d.pph_type, d.employee_id;