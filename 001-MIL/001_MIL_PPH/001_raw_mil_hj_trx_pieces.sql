-- Drop existing temp tables if they exist
IF OBJECT_ID('tempdb..#Warehouses_mil') IS NOT NULL DROP TABLE #Warehouses_mil;
IF OBJECT_ID('tempdb..#TransactionTypes_mil') IS NOT NULL DROP TABLE #TransactionTypes_mil;
IF OBJECT_ID('tempdb..#ItemMaster_mil') IS NOT NULL DROP TABLE #ItemMaster_mil;
IF OBJECT_ID('tempdb..#Locations_mil') IS NOT NULL DROP TABLE #Locations_mil;
IF OBJECT_ID('tempdb..#Employees_mil') IS NOT NULL DROP TABLE #Employees_mil;

-- Optimize variable declarations by combining them
DECLARE
    @wh_id_list VARCHAR(500) = '51',
    @tran_list VARCHAR(500) = '111,374',
    @StartDate DATETIME,
    @EndDate DATETIME;
SET @StartDate = DATEADD(DAY, -7, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
SET @EndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';

-- Create temp table for warehouse IDs
CREATE TABLE #Warehouses_mil (
    wh_id VARCHAR(10)
);
INSERT INTO #Warehouses_mil
SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ',');

-- Create temp table for transaction types
CREATE TABLE #TransactionTypes_mil (
    tran_type VARCHAR(10)
);
INSERT INTO #TransactionTypes_mil
SELECT TRIM(value) FROM STRING_SPLIT(@tran_list, ',');

-- Create temp table for item master data
SELECT DISTINCT
    t3.ITNBR as item_number,
    t1.wh_id,
    t1.description,
    t1.commodity_code,
    t4.PICKPUT as pick_put_id,
    t3.ITCLS,
    t3.B2Z95S,
    t3.B2Z95S * 0.028317 as Unit_CBM,
    CASE
        WHEN t3.ITCLS LIKE 'Z%' AND LEFT(t3.ITNBR,1) IN ('B','E','W','H')  THEN 'CG'
        WHEN t3.ITCLS LIKE 'Z%' AND LEFT(t3.ITNBR,1) IN ('M') THEN 'Bedding'
        ELSE 'CHECK'
    END AS product,
    t4.TIHIUNLD,
    t4.ITMCLSID,
    t4.UNITSWIDE,
    t4.UNITLAYERS,
    t4.UNITSDEEP,
    t4.SCOOPQTY,
    t4.SKIDSIZE
INTO #ItemMaster_mil
FROM (select * from MasterData_ItemMaster_MIL.ITMRVA as t0 where t0.STID = '51') as t3
LEFT JOIN (select * from Distribution_Warehouse_Wholesale.t_item_master  where wh_id = '51') as t1
    ON t1.item_number = t3.ITNBR
LEFT JOIN MasterData_ItemMaster_MIL.ITBEXT t4
    ON t3.ITNBR = t4.ITNBR
WHERE 

-- Create temp table for locations
SELECT distinct
    wh_id,
    location_id,
    status,
    TypeDescription
INTO #Locations_mil
FROM Distribution_Warehouse_Wholesale.t_location
WHERE wh_id IN (SELECT wh_id FROM #Warehouses_mil);

-- Create temp table for employees
SELECT Distinct
    wh_id,
    emp_number,
    name,
    dept,
    group_nbr,
    supervisor_nbr,
    supervisor
INTO #Employees_mil
FROM Distribution_Warehouse_Wholesale.t_employee
WHERE wh_id IN (SELECT wh_id FROM #Warehouses_mil);

-- Optimize final query using temp tables
WITH TransactionBase AS (
    SELECT t1.*,
           CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS trx_date_time,

           -- shift date
           CASE
               WHEN CAST(t1.start_tran_time AS TIME) >= '00:00:00'
                AND CAST(t1.start_tran_time AS TIME) < '07:00:00'
                   THEN DATEADD(DAY, -1, t1.start_tran_date)
               ELSE t1.start_tran_date
           END AS shift_date,

        -- Shift
           CASE
               WHEN CAST(t1.start_tran_time AS TIME) BETWEEN '07:00:00' AND '18:59:59' THEN 'D'
               ELSE 'N'
           END AS shift,

        -- PPH Type
           CASE
               WHEN t1.tran_type in ('111')  THEN 'Receiving'
               WHEN t1.tran_type = '301' THEN 'Picking'
               WHEN t1.tran_type = '374' THEN 'Picking'
               WHEN t1.tran_type = '368' THEN 'Loading'
           ELSE 'Check' END AS pph_type,

        -- Building
           CASE
               WHEN t1.tran_type in ('111') and LEFT(t1.item_number,1) IN ('B','E','W','H')  THEN 'B4'
               WHEN t1.tran_type in ('111') and LEFT(t1.item_number,1) IN ('M')  THEN 'B3'
               WHEN t1.tran_type = '301' AND LEFT(t1.location_id,2) in ('M7') THEN 'B7'
               WHEN t1.tran_type = '301' AND LEFT(t1.location_id,2) in ('M6') THEN 'B6'
               WHEN t1.tran_type = '301' AND LEFT(t1.location_id,2) in ('M5') THEN 'B5'
               WHEN t1.tran_type = '301' AND LEFT(t1.location_id,2) in ('M4') THEN 'B4'
               WHEN t1.tran_type = '301' AND LEFT(t1.location_id,2) in ('ND','DR') THEN 'B7'
               WHEN t1.tran_type = '374' AND LEFT(t1.wh_id_2,2) IN ('M7','DR','ND','PL') THEN 'B7'
               WHEN t1.tran_type = '374' AND LEFT(t1.wh_id_2,2) IN ('M4') THEN 'B4'
               WHEN t1.tran_type = '374' AND LEFT(t1.wh_id_2,2) IN ('M5') THEN 'B5'
               WHEN t1.tran_type = '374' AND LEFT(t1.wh_id_2,2) IN ('QC') THEN 'B5'
               WHEN t1.tran_type = '374'  and LEFT(t1.item_number,1) IN ('B','E','W','H') AND LEFT(t1.wh_id_2,2) IN ('US') THEN 'B4'
               WHEN t1.tran_type = '374'  and LEFT(t1.item_number,1) IN ('M') AND LEFT(t1.wh_id_2,2) IN ('US') THEN 'B3'
               WHEN t1.tran_type = '368' AND t1.location_id_2 LIKE 'D4%' THEN 'B4'
               WHEN t1.tran_type = '368' AND t1.location_id_2 LIKE 'D5%' THEN 'B5'
               WHEN t1.tran_type = '368' AND t1.location_id_2 LIKE 'D6%' THEN 'B6'
               WHEN t1.tran_type = '368' AND t1.location_id_2 LIKE 'D7%' THEN 'B7'
           ELSE 'CHECK'  END AS site
    FROM Distribution_Warehouse_Wholesale.TranLog t1
    WHERE t1.wh_id IN (SELECT wh_id FROM #Warehouses_mil)
    AND t1.tran_type IN (SELECT tran_type FROM #TransactionTypes_mil)
    AND CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME)
        BETWEEN @StartDate AND @EndDate
)
SELECT t.*,
                       i.product,
                       i.commodity_code,
                       i.pick_put_id,
                       l1.TypeDescription                                                             as loc_type,
                       l2.TypeDescription                                                             as loc_type_2,
                       e.name                                                                         as emp_name,
                       e.dept                                                                         as dept_nbr,
                       CONCAT(CAST(t.shift_date AS VARCHAR(20)), '_', t.employee_id, '_',
                              t.pph_type)                                                             as emp_date_job_string,
                       CONCAT(CAST(t.shift_date AS VARCHAR(20)), '_', t.employee_id)                  as emp_date_string
                FROM TransactionBase t
                         LEFT JOIN #ItemMaster_mil i ON t.item_number = i.item_number AND t.wh_id = i.wh_id
                         LEFT JOIN #Locations_mil l1 ON t.wh_id = l1.wh_id AND t.location_id = l1.location_id
                         LEFT JOIN #Locations_mil l2 ON t.wh_id = l2.wh_id AND t.location_id_2 = l2.location_id
                         LEFT JOIN #Employees_mil e ON t.wh_id = e.wh_id AND t.employee_id = e.emp_number

-- Clean up temp tables
DROP TABLE #Warehouses_mil;
DROP TABLE #TransactionTypes_mil;
DROP TABLE #ItemMaster_mil;
DROP TABLE #Locations_mil;
DROP TABLE #Employees_mil;
