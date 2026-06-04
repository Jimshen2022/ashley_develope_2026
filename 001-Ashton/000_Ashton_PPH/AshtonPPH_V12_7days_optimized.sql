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

Optimization notes (vs V12_7days):
1. STRING_SPLIT extracted into #wh_ids / #tran_types temp tables — evaluated once only.
2. loc CTE replaced by #tmp_loc temp table with index — avoids double CTE scan.
3. TranLog subquery: SELECT * -> explicit columns — reduces IO and memory.
4. TranLog date filter rewritten to sargable form — enables index seek on start_tran_date.
5. trx_3: removed emp_date_job_string / emp_date_string — not selected in final output.
6. trx_2: NOT IN ('not_pph_trx') -> <> 'not_pph_trx' — cleaner single-value filter.
*/

DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list  AS VARCHAR(500);
DECLARE @StartDate  DATETIME;
DECLARE @EndDate    DATETIME;

SET @wh_id_list = '335,335';
SET @tran_list  = '151,183,951,321,363,372,347,252,254,262,202';

--SET @StartDate = '2025-01-01 07:00:00.000';
SET @StartDate = DATEADD(DAY, -7, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
SET @EndDate   = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';

/* ── Opt 1: materialise list splits into temp tables — evaluated once ──────── */
IF OBJECT_ID('tempdb..#wh_ids')    IS NOT NULL DROP TABLE #wh_ids;
IF OBJECT_ID('tempdb..#tran_types') IS NOT NULL DROP TABLE #tran_types;

SELECT TRIM(value) AS wh_id    INTO #wh_ids     FROM STRING_SPLIT(@wh_id_list, ',');
SELECT TRIM(value) AS tran_type INTO #tran_types FROM STRING_SPLIT(@tran_list,  ',');

/* ── Opt 2: materialise loc with index — avoids two CTE scans ──────────────── */
IF OBJECT_ID('tempdb..#tmp_loc') IS NOT NULL DROP TABLE #tmp_loc;

SELECT
    t1.wh_id,
    t1.location_id,
    t1.status,
    t1.TypeDescription
INTO #tmp_loc
FROM Distribution_Warehouse_Wholesale.t_location AS t1
WHERE t1.wh_id IN (SELECT wh_id FROM #wh_ids);

CREATE INDEX ix_tmp_loc ON #tmp_loc (wh_id, location_id);

/* ─────────────────────────────────────────────────────────────────────────── */
WITH itm AS (
    SELECT DISTINCT
        t3.ITNBR              AS item_number,
        t3.STID               AS wh_id,
        t3.ITDSC              AS description,
        t3.ITCLS              AS commodity_code,
        t4.PICKPUT            AS pick_put_id,
        t3.ITCLS,
        t3.B2Z95S,
        t3.B2Z95S * 0.028317  AS Unit_CBM,
        CASE
            WHEN t4.PICKPUT = 'UPH' THEN 'UPH'
            ELSE 'CG'
        END AS product,
        t4.TIHIUNLD,
        t4.ITMCLSID,
        t4.UNITSWIDE,
        t4.UNITLAYERS,
        t4.UNITSDEEP,
        t4.SCOOPQTY,
        t4.SKIDSIZE
    FROM (
        SELECT a1.STID, a1.ITNBR, a1.ITCLS, a1.B2Z95S, a1.ITDSC
        FROM MasterData_ItemMaster_AFI.ITMRVA AS a1
        WHERE a1.STID IN ('335')
    ) AS t3
    LEFT JOIN (
        SELECT a2.ITNBR, a2.PICKPUT, a2.TIHIUNLD, a2.ITMCLSID,
               a2.UNITSWIDE, a2.UNITLAYERS, a2.UNITSDEEP, a2.SCOOPQTY, a2.SKIDSIZE
        FROM MasterData_ItemMaster_AFI.ITBEXT AS a2
        WHERE a2.HOUSE IN ('335')
    ) AS t4 ON t3.ITNBR = t4.ITNBR
),
em AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.t_employee AS a
    WHERE a.wh_id = '335'
),
dept AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.Department AS t1
    WHERE t1.wh_id IN (SELECT wh_id FROM #wh_ids)
),
grp AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.[Group] AS t1
    WHERE t1.wh_id IN (SELECT wh_id FROM #wh_ids)
),
trx AS (
    SELECT
        t1.item_number,
        i.commodity_code,
        i.pick_put_id,
        CASE WHEN t1.lot_number IS NULL THEN 'no_sn' ELSE t1.lot_number END AS lot_number,
        t1.wh_id                        AS whse,
        t1.location_id                  AS from_loc,
        l.TypeDescription               AS loc_type,
        t1.location_id_2                AS to_loc,
        l2.TypeDescription              AS loc_type_2,
        t1.control_number               AS wa_order,
        t1.control_number_2             AS reference,
        t1.tran_qty,
        t1.hu_id                        AS license_plate,
        t1.tran_type,
        t1.description,
        t1.employee_id,
        e.name                          AS emp_name,
        e.dept                          AS dept_nbr,
        d1.description                  AS deparment,
        e.group_nbr,
        g.Description                   AS group_name,
        e.supervisor_nbr,
        e.supervisor,
        t1.start_tran_date,
        t1.start_tran_time,
        t1.end_tran_date,
        t1.end_tran_time,
        t1.elapsed_time,
        t1.return_disposition           AS backorder_reason,
        t1.employee_id_2,
        t1.routing_code,
        t1.hu_id_2,
        t1.log_id,
        t1.equipment_zone,
        CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS trx_date_time,
        ISNULL(i.product, 'CG')         AS product,   -- fallback: item not in itm -> CG
        CASE
            WHEN t1.tran_type IN ('951') THEN t1.tran_qty * -1
            ELSE t1.tran_qty
        END AS trx_qty,
        CASE
            WHEN CAST(t1.start_tran_time AS TIME) >= '00:00:00'
             AND CAST(t1.start_tran_time AS TIME)  < '07:00:00'
            THEN DATEADD(DAY, -1, t1.start_tran_date)
            ELSE t1.start_tran_date
        END AS shift_date,
        CASE
            WHEN CAST(t1.start_tran_time AS TIME) BETWEEN '07:00:00' AND '18:59:59' THEN 'D'
            ELSE 'N'
        END AS shift,
        CASE
            WHEN t1.tran_type IN ('151','183','951') THEN 'Unloading'
            WHEN t1.tran_type IN ('321')             THEN 'Loading'
            WHEN t1.tran_type IN ('363')
                 AND (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')
                 AND t1.hu_id IS NOT NULL             THEN 'Picking-SCOOP'
            WHEN t1.tran_type IN ('363','372')        THEN 'Picking'
            WHEN t1.tran_type IN ('347')              THEN 'Piece shipped'
            WHEN t1.tran_type IN ('252','262')        THEN 'Replenishment'
            WHEN t1.tran_type IN ('254')
                 AND t1.location_id_2 <> 'RP998XL3'  THEN 'Put away'
            WHEN t1.control_number_2 LIKE 'RS%'
                 AND t1.location_id_2 LIKE 'A%'       THEN 'Put away'
            WHEN t1.control_number_2 LIKE 'RS%'
                 AND t1.location_id_2 LIKE 'DR%'      THEN 'Put away'
            WHEN t1.tran_type = '202'
                 AND t1.control_number_2 LIKE 'CN%'
                 AND t1.location_id_2   LIKE 'A%'     THEN 'Unloading'
            WHEN t1.tran_type = '202'
                 AND t1.control_number_2 LIKE 'UL%'
                 AND t1.location_id_2   LIKE 'A%'     THEN 'Put away'
            ELSE 'not_pph_trx'
        END AS pph_type,
        i.scoopqty
    FROM (
        /* ── Opt 3: explicit columns only — no SELECT * ─────────────────────── */
        /* ── Opt 4: sargable date filter — index seek on start_tran_date,      */
        /*           then precise datetime check in outer WHERE                  */
        SELECT
            wh_id, item_number, lot_number, location_id, location_id_2,
            control_number, control_number_2, tran_qty, hu_id, tran_type,
            description, employee_id, start_tran_date, start_tran_time,
            end_tran_date, end_tran_time, elapsed_time, return_disposition,
            employee_id_2, routing_code, hu_id_2, log_id, equipment_zone
        FROM Distribution_Warehouse_Wholesale.TranLog
        WHERE wh_id     IN (SELECT wh_id     FROM #wh_ids)
          AND tran_type IN (SELECT tran_type FROM #tran_types)
          AND start_tran_date >= CAST(@StartDate AS DATE)   -- sargable: index seek
          AND start_tran_date <= CAST(@EndDate   AS DATE)
          /* precise boundary check — row-level filter after index seek */
          AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) > @StartDate
          AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) < @EndDate
    ) AS t1
    LEFT JOIN itm      AS i  ON t1.item_number = i.item_number AND t1.wh_id = i.wh_id
    /* ── Opt 2: use indexed #tmp_loc instead of CTE ─────────────────────────── */
    LEFT JOIN #tmp_loc AS l  ON t1.wh_id = l.wh_id  AND t1.location_id   = l.location_id
    LEFT JOIN #tmp_loc AS l2 ON t1.wh_id = l2.wh_id AND t1.location_id_2 = l2.location_id
    LEFT JOIN em       AS e  ON t1.wh_id = e.wh_id  AND t1.employee_id   = e.emp_number
    LEFT JOIN dept     AS d1 ON e.wh_id  = d1.wh_id AND e.dept           = d1.department_code
    LEFT JOIN grp      AS g  ON e.wh_id  = g.wh_id  AND e.group_nbr      = g.GroupNbr
),
trx_2 AS (
    SELECT
        t.*,
        CASE
            WHEN t.pph_type IN ('Put away','Replenishment') AND t.pick_put_id = 'PALLT' THEN
                ROW_NUMBER() OVER (
                    PARTITION BY t.start_tran_date, t.employee_id, t.item_number,
                                 t.from_loc, t.to_loc, t.wa_order, t.reference, t.tran_type
                    ORDER BY t.trx_date_time
                )
            WHEN t.pph_type IN ('Picking-SCOOP') THEN
                ROW_NUMBER() OVER (
                    PARTITION BY t.start_tran_date, t.employee_id, t.item_number,
                                 t.to_loc, t.license_plate
                    ORDER BY t.trx_date_time
                )
            ELSE 0
        END AS rn,
        CASE
            WHEN t.pph_type IN ('Put away','Replenishment') AND t.pick_put_id = 'PALLT' THEN
                ROW_NUMBER() OVER (
                    PARTITION BY t.start_tran_date, t.employee_id, t.item_number, t.lot_number
                    ORDER BY t.trx_date_time
                )
            ELSE 0
        END AS row_num
    FROM trx AS t
    WHERE t.pph_type <> 'not_pph_trx'   -- Opt 6: <> cleaner than NOT IN for single value
),
trx_3 AS (
    SELECT
        t9.*,
        CASE WHEN t9.rn = 1 THEN 1 ELSE 0 END AS Pallet_Qty,
        CASE
            WHEN t9.row_num IN (0, 1) THEN t9.trx_qty
            ELSE 0
        END AS pieces,   -- eliminates duplicate serial number trx same day/item/employee
        CASE
            WHEN t9.pph_type IN ('Picking','Loading') THEN 'CG/UPH'
            ELSE t9.product
        END AS product_category
        /* Opt 5: removed emp_date_job_string / emp_date_string — not in final SELECT */
    FROM trx_2 AS t9
)
SELECT
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
    d.product_category,
    d.SCOOPQTY,
    SUM(d.Pallet_Qty) AS Pallet_Qty,
    SUM(d.pieces)     AS pieces
FROM trx_3 AS d
WHERE d.pieces > 0
GROUP BY
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
    d.product_category,
    d.SCOOPQTY
ORDER BY d.shift_date, d.item_number, d.pph_type, d.employee_id;