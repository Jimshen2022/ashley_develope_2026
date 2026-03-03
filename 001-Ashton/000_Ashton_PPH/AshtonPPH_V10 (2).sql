/*  Nov.18.2024,  Defined of transactions created by Jim,Shen

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
*/

DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list AS VARCHAR(500);
DECLARE @StartDate DATETIME;
DECLARE @EndDate DATETIME;
SET @wh_id_list = '335,335';
SET @tran_list = '151,183,951,321,363,372,347,252,254,262,202';

--SET @StartDate = DATEADD(DAY, -31, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
SET @StartDate = '2025-09-01 07:00:00.000';
SET @EndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';

With itm as (
    select distinct
        t3.ITNBR as item_number,
        t1.wh_id,
        t1.description,
        t1.commodity_code,
        t4.PICKPUT as pick_put_id,
        t3.ITCLS,
        t3.B2Z95S,
        t3.B2Z95S * 0.028317 as Unit_CBM,
        CASE
            WHEN LEFT(t3.ITNBR, 4) = '100-'
                OR LEFT(t3.ITNBR, 1) IN ('A', 'B', 'D', 'H', 'L', 'Q', 'R', 'T', 'W', 'M', 'E')
                OR t3.ITNBR IN ('7340321', '9910160', '4400021', '4400022', '7390160',
                                '5920230', '1300021', '1660021', '6280260')
            THEN 'CG'
            ELSE 'UPH'
        END AS product,
        t4.TIHIUNLD,
        t4.ITMCLSID,
        t4.UNITSWIDE,
        t4.UNITLAYERS,
        t4.UNITSDEEP,
        t4.SCOOPQTY,
        t4.SKIDSIZE
    from (SELECT a1.ITNBR, a1.ITCLS, a1.B2Z95S FROM MasterData_ItemMaster_AFI.ITMRVA AS a1 WHERE a1.STID IN ('335')) as t3
    left join (select a1.item_number, a1.wh_id, a1.description, a1.commodity_code from Distribution_Warehouse_Wholesale.t_item_master as a1 where a1.wh_id = '335') as t1
        on t1.item_number = t3.ITNBR
    left join (SELECT a2.ITNBR,a2.PICKPUT,a2.TIHIUNLD,a2.ITMCLSID,a2.UNITSWIDE,a2.UNITLAYERS,a2.UNITSDEEP,a2.SCOOPQTY,a2.SKIDSIZE
                      FROM MasterData_ItemMaster_AFI.ITBEXT AS a2 WHERE a2.HOUSE IN ('335')) as t4
        ON t3.ITNBR = t4.ITNBR
),
loc AS (
    select
        t1.wh_id,
        t1.location_id,
        t1.status,
        t1.TypeDescription
    from Distribution_Warehouse_Wholesale.t_location as t1
    where t1.wh_id IN (SELECT trim(value) FROM string_split(@wh_id_list, ','))
),
em AS (
    select *
    from Distribution_Warehouse_Wholesale.t_employee a
    where a.wh_id = '335'
),
dept as (
    select *
    from Distribution_Warehouse_Wholesale.Department as t1
    where t1.wh_id IN (SELECT trim(value) FROM string_split(@wh_id_list, ','))
),
grp as (
    select *
    from Distribution_Warehouse_Wholesale.[Group] as t1
    where t1.wh_id IN (SELECT trim(value) FROM string_split(@wh_id_list, ','))
),
trx AS (
    SELECT
        t1.item_number,
        i.commodity_code,
        i.pick_put_id,
        case when t1.lot_number is null then 'no_sn' else t1.lot_number end as lot_number,
        t1.wh_id as whse,
        t1.location_id as from_loc,
        l.TypeDescription as loc_type,
        t1.location_id_2 as to_loc,
        l2.TypeDescription AS loc_type_2,
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
        g.Description as group_name,
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
            WHEN LEFT(t1.item_number, 4) = '100-'
                OR LEFT(t1.item_number, 1) IN ('A', 'B', 'D', 'H', 'L', 'Q', 'R', 'T', 'W', 'M', 'E')
                OR t1.item_number IN ('7340321', '9910160', '4400021', '4400022', '7390160',
                                '5920230', '1300021', '1660021', '6280260') THEN 'CG'
            ELSE 'UPH'
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
        END AS pph_type
    FROM (
        SELECT *
        FROM Distribution_Warehouse_Wholesale.TranLog
        WHERE wh_id IN (SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ','))
            AND tran_type IN (SELECT TRIM(value) FROM STRING_SPLIT(@tran_list, ','))
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) > @StartDate
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) < @EndDate
    ) AS t1
    LEFT JOIN itm as i on t1.item_number = i.item_number and t1.wh_id = i.wh_id
    LEFT JOIN loc as l on t1.wh_id = l.wh_id and t1.location_id = l.location_id
    LEFT JOIN loc as l2 on t1.wh_id = l2.wh_id and t1.location_id_2 = l2.location_id
    LEFT JOIN em as e on t1.wh_id = e.wh_id and t1.employee_id = e.emp_number
    LEFT JOIN dept as d1 on e.wh_id = d1.wh_id and e.dept = d1.department_code
    LEFT JOIN grp as g on e.wh_id = g.wh_id and e.group_nbr = g.GroupNbr
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
)
SELECT
   t9.*,
    CASE WHEN t9.rn = 1 THEN 1 ELSE 0 END AS Pallet_Qty,
    CASE
        WHEN t9.row_num in (0,1) THEN t9.trx_qty
        ELSE 0
    END AS pieces,
     CONCAT(CAST(t9.shift_date AS VARCHAR(20)),'_',t9.employee_id,'_', t9.pph_type) as emp_date_job_string,
     CONCAT(CAST(t9.shift_date AS VARCHAR(20)),'_',t9.employee_id) as emp_date_string
FROM trx_2 AS t9
Order by t9.trx_date_time, t9.employee_id, t9.item_number