-- Predefine the warehouse IDs once in a CTE
WITH WhIDs AS (
    SELECT TRIM(value) AS wh_id
    FROM STRING_SPLIT(CAST('335,335' AS VARCHAR(500)), ',')
),
-- Define a reusable product logic CTE. 
ProductCalc AS (
    SELECT
        ITNBR,
        ITCLS,
        B2Z95S,
        CASE 
            WHEN LEFT(ITNBR, 4) = '100-' 
              OR LEFT(ITNBR, 1) IN ('A','B','D','H','L','Q','R','T','W','M','E')
              OR ITNBR IN ('7340321','9910160','4400021','4400022','7390160','5920230','1300021','1660021','6280260')
            THEN 'CG'
            ELSE 'UPH'
        END AS product_calc
    FROM MasterData_ItemMaster_AFI.ITMRVA
    WHERE STID = '335'
),
itm AS (
    SELECT DISTINCT
        t3.ITNBR AS item_number,
        t1.wh_id,
        t1.description,
        t1.commodity_code,
        t4.PICKPUT AS pick_put_id,
        t3.ITCLS,
        t3.B2Z95S,
        t3.B2Z95S * 0.028317 AS Unit_CBM,
        COALESCE(t3.product_calc, 
          CASE 
              WHEN LEFT(t3.ITNBR, 4) = '100-' 
                OR LEFT(t3.ITNBR, 1) IN ('A','B','D','H','L','Q','R','T','W','M','E')
                OR t3.ITNBR IN ('7340321','9910160','4400021','4400022','7390160','5920230','1300021','1660021','6280260')
              THEN 'CG'
              ELSE 'UPH'
          END) AS product,
        t4.TIHIUNLD,
        t4.ITMCLSID,
        t4.UNITSWIDE,
        t4.UNITLAYERS,
        t4.UNITSDEEP,
        t4.SCOOPQTY,
        t4.SKIDSIZE
    FROM ProductCalc AS t3
    LEFT JOIN Distribution_Warehouse_Wholesale.t_item_master AS t1
           ON t1.item_number = t3.ITNBR AND t1.wh_id = '335'
    LEFT JOIN (
         SELECT 
            a2.PICKPUT,
            a2.ITNBR,
            a2.TIHIUNLD,
            a2.ITMCLSID,
            a2.UNITSWIDE,
            a2.UNITLAYERS,
            a2.UNITSDEEP,
            a2.SCOOPQTY,
            a2.SKIDSIZE
         FROM MasterData_ItemMaster_AFI.ITBEXT AS a2
         WHERE a2.HOUSE = '335'
    ) AS t4 ON t3.ITNBR = t4.ITNBR
),
loc AS (
    SELECT 
        l.wh_id, 
        l.location_id, 
        l.status, 
        l.TypeDescription
    FROM Distribution_Warehouse_Wholesale.t_location AS l
    INNER JOIN WhIDs AS w ON l.wh_id = w.wh_id
),
em AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.t_employee
    WHERE wh_id = '335'
),
dept AS (
    -- Selecting only the columns from the department table to avoid duplicate wh_id from WhIDs.
    SELECT d.*
    FROM Distribution_Warehouse_Wholesale.Department AS d
    INNER JOIN WhIDs AS w ON d.wh_id = w.wh_id
),
grp AS (
    -- Similarly, select only the columns from the group table.
    SELECT g.*
    FROM Distribution_Warehouse_Wholesale.[Group] AS g
    INNER JOIN WhIDs AS w ON g.wh_id = w.wh_id
),
trx AS (
    SELECT
        t1.item_number,
        i.commodity_code,
        i.pick_put_id,
        ISNULL(t1.lot_number, 'no_sn') AS lot_number,
        t1.wh_id AS whse,
        t1.location_id AS from_loc,
        l.TypeDescription AS loc_type,
        t1.location_id_2 AS to_loc,
        l2.TypeDescription AS loc_type_2,
        t1.control_number AS wa_order,
        t1.control_number_2 AS reference,
        t1.tran_qty,
        t1.hu_id AS license_plate,
        t1.tran_type,
        t1.description,
        t1.employee_id,
        e.name AS emp_name,
        e.dept AS dept_nbr,
        d1.description AS deparment,
        e.group_nbr,
        g.Description AS group_name,
        e.supervisor_nbr,
        e.supervisor,
        t1.start_tran_date,
        t1.start_tran_time,
        t1.end_tran_date,
        t1.end_tran_time,
        t1.elapsed_time,
        t1.return_disposition AS backorder_reason,
        t1.employee_id_2,
        t1.routing_code,
        t1.hu_id_2,
        t1.log_id,
        t1.equipment_zone,
        CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS trx_date_time,
        CASE 
            WHEN i.product IS NOT NULL THEN i.product
            ELSE
                CASE 
                    WHEN LEFT(t1.item_number, 4) = '100-' 
                      OR LEFT(t1.item_number, 1) IN ('A','B','D','H','L','Q','R','T','W','M','E')
                      OR t1.item_number IN ('7340321','9910160','4400021','4400022','7390160','5920230','1300021','1660021','6280260')
                    THEN 'CG'
                    ELSE 'UPH'
                END
        END AS product,
        CASE 
            WHEN t1.tran_type = '951' THEN t1.tran_qty * -1
            ELSE t1.tran_qty
        END AS trx_qty,
        CASE 
            WHEN CAST(t1.start_tran_time AS TIME) >= '00:00:00'
                 AND CAST(t1.start_tran_time AS TIME) < '07:00:00'
            THEN DATEADD(DAY, -1, t1.start_tran_date)
            ELSE t1.start_tran_date
        END AS shift_date,
        CASE 
            WHEN CAST(t1.start_tran_time AS TIME) BETWEEN '07:00:00' AND '18:59:59'
            THEN 'D'
            ELSE 'N'
        END AS shift,
        CASE 
            WHEN t1.tran_type IN ('151','183','951') THEN 'Unloading'
            WHEN t1.tran_type IN ('321') THEN 'Loading'
            WHEN t1.tran_type = '363' 
                 AND (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')
                 AND t1.hu_id IS NOT NULL THEN 'Picking-SCOOP'
            WHEN t1.tran_type IN ('363','372') THEN 'Picking'
            WHEN t1.tran_type = '347' THEN 'Piece shipped'
            WHEN t1.tran_type IN ('252','262') THEN 'Replenishment'
            WHEN t1.tran_type = '254' AND t1.location_id_2 <> 'RP998XL3' THEN 'Put away'
            WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'DR%' THEN 'Put away'
            WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'CN%' AND t1.location_id_2 LIKE 'A%' THEN 'Unloading'
            WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'UL%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            ELSE 'not_pph_trx'
        END AS pph_type
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    INNER JOIN WhIDs AS w ON t1.wh_id = w.wh_id
    LEFT JOIN itm AS i 
           ON t1.item_number = i.item_number 
          AND t1.wh_id = i.wh_id
    LEFT JOIN loc AS l 
           ON t1.wh_id = l.wh_id 
          AND t1.location_id = l.location_id
    LEFT JOIN loc AS l2 
           ON t1.wh_id = l2.wh_id 
          AND t1.location_id_2 = l2.location_id
    LEFT JOIN em AS e 
           ON t1.wh_id = e.wh_id 
          AND t1.employee_id = e.emp_number
    LEFT JOIN dept AS d1 
           ON e.wh_id = d1.wh_id 
          AND e.dept = d1.department_code
    LEFT JOIN grp AS g 
           ON e.wh_id = g.wh_id 
          AND e.group_nbr = g.GroupNbr
    WHERE t1.tran_type IN (
            SELECT TRIM(value)
            FROM STRING_SPLIT(CAST('151,183,951,321,363,372,347,252,254,262,202' AS VARCHAR(500)), ',')
          )
      AND (CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME)) 
            BETWEEN CAST('2025-02-02 07:00:00.000' AS DATETIME)
        AND CAST('2025-02-15 06:59:59.997' AS DATETIME)
),
trx_2 AS (
    SELECT
        t.*,
        CASE 
            WHEN t.pph_type IN ('Put away','Replenishment') 
                 AND t.pick_put_id = 'PALLT'
            THEN ROW_NUMBER() OVER (
                     PARTITION BY t.start_tran_date,
                                  t.employee_id,
                                  t.item_number,
                                  t.from_loc,
                                  t.to_loc,
                                  t.wa_order,
                                  t.reference,
                                  t.tran_type
                     ORDER BY t.trx_date_time
                 )
            WHEN t.pph_type = 'Picking-SCOOP'
            THEN ROW_NUMBER() OVER (
                     PARTITION BY t.start_tran_date,
                                  t.employee_id,
                                  t.item_number,
                                  t.to_loc,
                                  t.license_plate
                     ORDER BY t.trx_date_time
                 )
            ELSE 0
        END AS rn,
        CASE 
            WHEN t.pph_type IN ('Put away','Replenishment') 
                 AND t.pick_put_id = 'PALLT'
            THEN ROW_NUMBER() OVER (
                     PARTITION BY t.start_tran_date,
                                  t.employee_id,
                                  t.item_number,
                                  t.lot_number
                     ORDER BY t.trx_date_time
                 )
            ELSE 0
        END AS row_num
    FROM trx AS t
    WHERE t.pph_type <> 'not_pph_trx'
)
SELECT
    t9.*,
    CASE WHEN t9.rn = 1 THEN 1 ELSE 0 END AS Pallet_Qty,
    CASE WHEN t9.row_num IN (0,1) THEN t9.trx_qty ELSE 0 END AS pieces,
    CONCAT(CAST(t9.shift_date AS VARCHAR(20)),'_',t9.employee_id,'_',t9.pph_type) AS emp_date_job_string,
    CONCAT(CAST(t9.shift_date AS VARCHAR(20)),'_',t9.employee_id) AS emp_date_string
FROM trx_2 AS t9
ORDER BY t9.trx_date_time,
         t9.employee_id,
         t9.item_number;