SELECT
    r0.item_number,
    r0.location_id,
    r0.Racking_Qty,
    i0.ITCLS,
    i0.B2Z95S,
    i0.TIHIUNLD,
    i0.PICKPUT,
    i0.PUTAWAY_CLASS,
    i0.UNITSWIDE,
    i0.UNITLAYERS,
    i0.UNITSDEEP,
    i0.SCOOPQTY,
    i0.SKIDSIZE,
    -- Pallet type mapping
    CASE i0.SKIDSIZE
        WHEN 1 THEN '5X5'
        WHEN 3 THEN '5X7'
        WHEN 4 THEN '3.5X5'
        WHEN 5 THEN '3.5X7'
        WHEN 16 THEN 'No Skid'
        WHEN 18 THEN '5X8'
        ELSE 'Check'
    END AS Item_Pallet_Type,
    -- Product category classification
    CASE
        WHEN i0.ITCLS NOT LIKE 'Z%' THEN 'RP_racking_area'
        WHEN i0.PICKPUT = 'UPH' THEN 'UPH_racking_area'
        WHEN i0.PICKPUT = 'PALLT' AND i0.SKIDSIZE = '4' THEN 'CG_3.5X5_area'
        WHEN i0.PICKPUT = 'PALLT' AND i0.SKIDSIZE = '5' THEN 'CG_3.5X7_area'
        WHEN i0.PICKPUT = 'PALLT' AND i0.PUTAWAY_CLASS = 'RAILS' THEN 'CG_rails_area'
        WHEN i0.PICKPUT = 'PALLT' AND i0.PUTAWAY_CLASS IN ('FLOOR','FLOOROP') THEN 'CG_bulk_stack_area'
        ELSE 'CG_racking_area'
    END AS product_fit_Category,
    -- Calculate product volume in cubic meters
    CONVERT(DECIMAL(10,2), r0.Racking_Qty * i0.B2Z95S * 0.028317) AS Racking_Product_CBM,
    -- Calculate required pallet quantity
    CASE
        WHEN i0.ITCLS NOT LIKE 'Z%' THEN 0.001
        WHEN i0.PICKPUT = 'UPH' THEN 0
        WHEN i0.PICKPUT = 'PALLT' AND i0.SCOOPQTY = 0 THEN CEILING(r0.Racking_Qty/10)
        ELSE CEILING(r0.Racking_Qty/i0.SCOOPQTY)
    END AS Pallet_Qty,
    -- Convert weight to kilograms
    i0.WEGHT * 0.453592 AS 'Unit_Weight(Kg)',
    f.LocationId AS Primary_location,
    -- Weight category based on ranges
    CASE 
        WHEN (i0.WEGHT * 0.453592) < 5 THEN '0 - 5 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 5 AND (i0.WEGHT * 0.453592) < 10 THEN '5 - 10 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 10 AND (i0.WEGHT * 0.453592) < 20 THEN '10 - 20 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 20 AND (i0.WEGHT * 0.453592) < 30 THEN '20 - 30 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 30 AND (i0.WEGHT * 0.453592) < 40 THEN '30 - 40 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 40 AND (i0.WEGHT * 0.453592) < 50 THEN '40 - 50 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 50 AND (i0.WEGHT * 0.453592) < 60 THEN '50 - 60 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 60 AND (i0.WEGHT * 0.453592) < 70 THEN '60 - 70 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 70 AND (i0.WEGHT * 0.453592) < 80 THEN '70 - 80 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 80 AND (i0.WEGHT * 0.453592) < 90 THEN '80 - 90 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 90 AND (i0.WEGHT * 0.453592) < 100 THEN '90 - 100 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 100 AND (i0.WEGHT * 0.453592) < 120 THEN '100 - 120 Kg'
        WHEN (i0.WEGHT * 0.453592) >= 120 AND (i0.WEGHT * 0.453592) < 150 THEN '120 - 150 Kg'
        ELSE '150 Kg and above'
    END AS Weight_Category
FROM (
    -- Subquery to get active serial quantities by location
    SELECT
        t1.item_number,
        t1.location_id,
        COUNT(t1.serial_number) AS Racking_Qty
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS T1
    WHERE t1.wh_id = '335'
        AND T1.location_id LIKE 'A3%'
        AND t1.serial_no_status != 'O'
        AND t1.master_status != 'S'
    GROUP BY t1.item_number, t1.location_id
) AS r0
-- Join with item master data
LEFT JOIN (
    SELECT
        i.ITNBR,
        i.ITCLS,
        i.B2Z95S,
        i.WEGHT,
        i1.TIHIUNLD,
        i1.PICKPUT,
        i1.ITMCLSID AS PUTAWAY_CLASS,  -- Changed from PUTAWAY_CLASS to ITMCLSID
        i1.UNITSWIDE,
        i1.UNITLAYERS,
        i1.UNITSDEEP,
        i1.SCOOPQTY,
        i1.SKIDSIZE
    FROM MasterData_ItemMaster_AFI.ITMRVA i
    INNER JOIN MasterData_ItemMaster_AFI.ITBEXT i1
        ON i.ITNBR = i1.ITNBR
    WHERE i.STID = '335'
        AND i1.House = '335'
) AS i0 ON r0.item_number = i0.ITNBR
-- Join with forward pick locations
LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.t_forward_pick AS a WHERE a.wh_id IN ('335') AND a.LocationId NOT IN ('A1001AA9','A1001AA1')) AS f
    ON r0.item_number = f.itemnumber
WHERE i0.PICKPUT <> 'UPH' AND i0.PUTAWAY_CLASS NOT IN ('FLOOR');