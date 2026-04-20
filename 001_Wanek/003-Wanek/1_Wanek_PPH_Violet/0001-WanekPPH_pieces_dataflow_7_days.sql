
-- Drop existing temp tables if they exist
IF OBJECT_ID('tempdb..#Warehouses') IS NOT NULL DROP TABLE #Warehouses;
IF OBJECT_ID('tempdb..#TransactionTypes') IS NOT NULL DROP TABLE #TransactionTypes;
IF OBJECT_ID('tempdb..#ItemMaster') IS NOT NULL DROP TABLE #ItemMaster;
IF OBJECT_ID('tempdb..#Locations') IS NOT NULL DROP TABLE #Locations;
IF OBJECT_ID('tempdb..#Employees') IS NOT NULL DROP TABLE #Employees;

-- Optimize variable declarations by combining them
DECLARE
    @wh_id_list VARCHAR(500) = '33,35,31',
    @tran_list VARCHAR(500) = '111,301,368,374,202',
    @StartDate DATETIME,
    @EndDate DATETIME;
SET @StartDate = DATEADD(DAY, -7, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
SET @EndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';


-- Create temp table for warehouse IDs
CREATE TABLE #Warehouses (
    wh_id VARCHAR(10)
);
INSERT INTO #Warehouses
SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ',');

-- Create temp table for transaction types
CREATE TABLE #TransactionTypes (
    tran_type VARCHAR(10)
);
INSERT INTO #TransactionTypes
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
        WHEN t3.ITCLS NOT LIKE 'Z%' THEN 'CG'
        WHEN t4.ITMCLSID LIKE 'UPH%' THEN 'UPH'
        WHEN t4.ITMCLSID IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG') THEN 'CG'
        WHEN t4.ITMCLSID IS NULL AND LEFT(t3.ITNBR, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
        WHEN t4.ITMCLSID IS NULL AND t4.PICKPUT = 'PALLT' THEN 'CG'
        WHEN t4.ITMCLSID IS NULL AND t4.PICKPUT = 'UPH' THEN 'UPH'
        ELSE 'CG'
    END AS product,
    t4.TIHIUNLD,
    t4.ITMCLSID,
    t4.UNITSWIDE,
    t4.UNITLAYERS,
    t4.UNITSDEEP,
    t4.SCOOPQTY,
    t4.SKIDSIZE
INTO #ItemMaster
FROM MasterData_ItemMaster_WNK.ITMRVA t3
LEFT JOIN Distribution_Warehouse_Wholesale.t_item_master t1
    ON t1.item_number = t3.ITNBR AND t1.wh_id = '35'
LEFT JOIN MasterData_ItemMaster_AFI.ITBEXT t4
    ON t3.ITNBR = t4.ITNBR AND t4.HOUSE = '35'
WHERE t3.STID = '35';

-- Create temp table for locations
SELECT
    wh_id,
    location_id,
    status,
    TypeDescription
INTO #Locations
FROM Distribution_Warehouse_Wholesale.t_location
WHERE wh_id IN (SELECT wh_id FROM #Warehouses);

-- Create temp table for employees
SELECT
    wh_id,
    emp_number,
    name,
    dept,
    group_nbr,
    supervisor_nbr,
    supervisor
INTO #Employees
FROM Distribution_Warehouse_Wholesale.t_employee
WHERE wh_id IN (SELECT wh_id FROM #Warehouses);

-- Optimize final query using temp tables
WITH TransactionBase AS (
    SELECT t1.*,
           CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS trx_date_time,
           CASE
               WHEN CAST(t1.start_tran_time AS TIME) >= '00:00:00'
                AND CAST(t1.start_tran_time AS TIME) < '07:00:00'
                   THEN DATEADD(DAY, -1, t1.start_tran_date)
               ELSE t1.start_tran_date
           END AS shift_date,
           CASE
               WHEN CAST(t1.start_tran_time AS TIME) BETWEEN '07:00:00' AND '18:59:59' THEN 'D'
               ELSE 'N'
           END AS shift,
           CASE
               WHEN t1.tran_type in ('111', '183', '951') THEN 'Production_Received'
               WHEN t1.tran_type = '368' AND t1.control_number_2 LIKE 'D9%' THEN 'BW_Loading'
               WHEN t1.tran_type = '368' THEN 'Loading_PPH'
               WHEN t1.tran_type = '301' THEN 'Picking_PPH'
               WHEN t1.tran_type = '374' THEN 'Picking'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'C%'THEN NULL -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'SA%'THEN NULL -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'SA%' and t1.control_number_2 like 'C%'THEN 'Temp_Cont_Loading'  -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'DK%'THEN 'Temp_Cont_Loading' -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'DR%'THEN 'Temp_Cont_Loading' -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'QA%'THEN 'Temp_Cont_Loading' -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'V3%'THEN 'Temp_Cont_Loading' -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' and t1.control_number_2 like 'NG%'THEN 'Temp_Cont_Loading' -- Liam confirmed on Nov.17.2025
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%' THEN 'Temp_Cont_Loading'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'UL%'
                    AND t1.control_number_2 LIKE 'C%' THEN 'DC_Unloading_PPH'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'P7%' THEN 'AFT_FG_Loading'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'M3%'
                    AND t1.control_number_2 LIKE 'UL%' THEN 'DC_Putaway'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'C%'
                    AND t1.control_number_2 LIKE 'UL9%' THEN 'BW_Unloading'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'B%'
                    AND t1.control_number_2 LIKE 'UL%' THEN 'BW_Putaway'
               WHEN t1.tran_type = '202' AND t1.location_id_2 LIKE 'CB%' THEN 'Temp_BW_Cont_Loading'
           END AS pph_type,
CASE
    -- Simple warehouse mappings
    WHEN t1.wh_id = '31' THEN 'WN1'
    WHEN t1.wh_id = '33' THEN 'WN2'
    -- Complex logic for wh_id = '35'
    WHEN t1.wh_id = '35' THEN
        CASE
            -- tran_type = '111'
            WHEN t1.tran_type = '111' THEN 'WN3'

            -- tran_type = '368'
            WHEN t1.tran_type = '368' AND t1.location_id_2 LIKE 'D4%' THEN 'WN3'
            WHEN t1.tran_type = '368' AND t1.location_id_2 LIKE 'D8%' THEN 'DC'

            -- tran_type = '374'
            WHEN t1.tran_type = '374' AND (t1.wh_id_2 LIKE 'M%' OR t1.wh_id_2 LIKE 'UL%') THEN 'DC'
            WHEN t1.tran_type = '374' THEN 'WN3'

            -- tran_type = '301'
            WHEN t1.tran_type = '301' AND (t1.location_id LIKE 'M%' OR t1.location_id LIKE 'UL%') THEN 'DC'
            WHEN t1.tran_type = '301' THEN 'WN3'

            -- tran_type = '202'
            WHEN t1.tran_type = '202' THEN
                CASE
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'DK%' THEN 'WN3'
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'DR%' THEN 'WN3'
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'QA%' THEN 'WN3'
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'V3%' THEN 'WN3'
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'NG%' THEN 'WN3'
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'M%' THEN 'DC'
                    WHEN t1.location_id_2 LIKE 'M%' AND t1.control_number_2 LIKE 'UL%' THEN 'DC'
                    WHEN t1.location_id_2 LIKE 'C%'AND t1.control_number_2 LIKE 'UL%' THEN 'DC'
                    WHEN t1.location_id_2 LIKE 'UL%' AND t1.control_number_2 LIKE 'C%' THEN 'DC'
                    WHEN t1.location_id LIKE 'VS%' AND t1.location_id_2 LIKE 'C%' THEN 'DC'
                    WHEN t1.location_id_2 LIKE 'C%' AND t1.control_number_2 LIKE 'C%' THEN
                        CASE
                            WHEN t1.equipment_zone LIKE 'M%' THEN 'DC'
                            WHEN t1.equipment_zone LIKE 'W%' THEN 'WN3'
                            ELSE 'CHECK'
                        END
                    ELSE 'CHECK'
                END
            ELSE 'CHECK'
        END
    ELSE 'CHECK'
END AS site
    FROM Distribution_Warehouse_Wholesale.TranLog t1
    WHERE t1.wh_id IN (SELECT wh_id FROM #Warehouses)
    AND t1.tran_type IN (SELECT tran_type FROM #TransactionTypes)
    AND CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME)
        BETWEEN @StartDate AND @EndDate
)
SELECT
    t.*,
    i.product,
    i.commodity_code,
    i.pick_put_id,
    l1.TypeDescription as loc_type,
    l2.TypeDescription as loc_type_2,
    e.name as emp_name,
    e.dept as dept_nbr,
    CONCAT(CAST(t.shift_date AS VARCHAR(20)), '_', t.employee_id, '_', t.pph_type) as emp_date_job_string,
    CONCAT(CAST(t.shift_date AS VARCHAR(20)), '_', t.employee_id) as emp_date_string
FROM TransactionBase t
LEFT JOIN #ItemMaster i ON t.item_number = i.item_number AND t.wh_id = i.wh_id
LEFT JOIN #Locations l1 ON t.wh_id = l1.wh_id AND t.location_id = l1.location_id
LEFT JOIN #Locations l2 ON t.wh_id = l2.wh_id AND t.location_id_2 = l2.location_id
LEFT JOIN #Employees e ON t.wh_id = e.wh_id AND t.employee_id = e.emp_number
WHERE t.pph_type IS NOT NULL;

-- Clean up temp tables
DROP TABLE #Warehouses;
DROP TABLE #TransactionTypes;
DROP TABLE #ItemMaster;
DROP TABLE #Locations;
DROP TABLE #Employees;