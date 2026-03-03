IF OBJECT_ID('tempdb..#temp_stored_items') IS NOT NULL
    DROP TABLE #temp_stored_items;
IF OBJECT_ID('tempdb..#temp_locations') IS NOT NULL
    DROP TABLE #temp_locations;
IF OBJECT_ID('tempdb..#temp_constants') IS NOT NULL
    DROP TABLe #temp_constants;

-- Step 1: Create and populate temp tables for better performance
SELECT
    sequence,
    item_number,
    actual_qty,
    unavailable_qty,
    status,
    wh_id,
    location_id,
    fifo_date,
    expiration_date,
    reserved_for,
    lot_number,
    inspection_code,
    serial_number,
    type,
    put_away_location
INTO #temp_stored_items
FROM Distribution_Warehouse_Wholesale.t_stored_item
WHERE wh_id = '51' and location_id like 'M7%'

SELECT
    location_id,
    wh_id,
    TypeDescription
INTO #temp_locations
FROM Distribution_Warehouse_Wholesale.t_location
WHERE wh_id = '51';

-- Step 2: Create constants table for calculations
SELECT
    1.3260 as UPH_FACTOR,    -- Pre-calculated 46.828 * 0.028317
    0.2431 as CG_FACTOR,     -- Pre-calculated 8.592 * 0.028317
    0.01 as ACC_FACTOR,
    0.001 as RP_FACTOR
INTO #temp_constants;

-- Step 3: Main Query using temp tables
SELECT
    s.sequence,
    s.item_number,
    s.actual_qty,
    s.unavailable_qty,
    s.status,
    s.wh_id,
    s.location_id,
    l.TypeDescription,
    s.fifo_date,
    s.expiration_date,
    s.reserved_for,
    s.lot_number,
    s.inspection_code,
    s.serial_number,
    s.type,
    s.put_away_location,
    LEFT(s.item_number, 1) AS first5,
    CASE
        WHEN s.location_id LIKE 'M7%' THEN 'In Racking Location'
        WHEN s.location_id LIKE 'S%' THEN 'ShippingStage'
        WHEN s.location_id LIKE 'D%' THEN 'Loaded to Door'
        ELSE 'Others'
    END as Loc_Type

FROM #temp_stored_items s
CROSS JOIN #temp_constants c
LEFT JOIN #temp_locations l
    ON s.location_id = l.location_id
    AND s.wh_id = l.wh_id
ORDER BY s.location_id;

-- Step 4: Clean up temp tables
IF OBJECT_ID('tempdb..#temp_stored_items') IS NOT NULL
    DROP TABLE #temp_stored_items;
IF OBJECT_ID('tempdb..#temp_locations') IS NOT NULL
    DROP TABLE #temp_locations;
IF OBJECT_ID('tempdb..#temp_constants') IS NOT NULL
    DROP TABLE #temp_constants;
