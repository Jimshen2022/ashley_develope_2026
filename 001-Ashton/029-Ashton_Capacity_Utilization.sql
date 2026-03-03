WITH LocationData AS (
    SELECT
        t.location_id,
        t.TypeDescription,
        t.status,
        t.capacity_volume,
        t.pick_area,
        t.location_tier,
        SUBSTRING(t.location_id, 4, 2) AS Aisle,
        CONVERT(DECIMAL(10, 2), t.length * 0.0254) AS Loc_length_m,
        CONVERT(DECIMAL(10, 2), t.width * 0.0254) AS Loc_width_m,
        CONVERT(DECIMAL(10, 2), t.height * 0.0254) AS Loc_height_m,
        CONVERT(DECIMAL(10, 2), (t.length * 0.0254) * (t.width * 0.0254) * (t.height * 0.0254)) AS Loc_CBM,
        SUBSTRING(t.location_id, 4, 2) AS AisleCode,
        SUBSTRING(t.location_id, 6, 1) AS SubLocation1,
        SUBSTRING(t.location_id, 6, 2) AS SubLocation2,
        SUBSTRING(t.location_id, 8, 1) AS SubLocation3
    FROM Distribution_Warehouse_Wholesale.t_location AS t
    WHERE
        t.wh_id = '335'
        AND t.location_id LIKE 'A3%'
        AND t.TypeDescription IN ('I', 'P', 'M', 'A', 'X')
        --AND SUBSTRING(t.location_id, 4, 2) IN ('10', '11', '12', '13', '14', '15', '16', '17', '18', '19')
),
ClassLoca AS (
    SELECT
        c.LocationId,
        MIN(c.CapacityVolume) AS CapacityVolume
    FROM Distribution_Warehouse_Wholesale.t_class_loca c
    WHERE
        c.WhId = '335'
        AND c.LocationId LIKE 'A3%'
    GROUP BY c.LocationId
),
ItemData AS (
    SELECT
        t1.item_number,
        t1.location_id,
        COUNT(t1.serial_number) AS Racking_Qty
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    WHERE
        t1.wh_id = '335'
        AND t1.location_id LIKE 'A3%'
        AND t1.serial_no_status NOT IN ('O')
        AND t1.master_status NOT IN ('S')
        --AND SUBSTRING(t1.location_id, 4, 2) IN ('10', '11', '12', '13', '14', '15', '16', '17', '18', '19')
    GROUP BY t1.item_number, t1.location_id
),
ItemMaster AS (
    SELECT
        i.ITNBR,
        i.ITCLS,
        i.B2Z95S,
        i1.TIHIUNLD,
        i1.PICKPUT,
        i1.ITMCLSID,
        i1.UNITSWIDE,
        i1.UNITLAYERS,
        i1.UNITSDEEP,
        i1.SCOOPQTY,
        i1.SKIDSIZE
    FROM MasterData_ItemMaster_AFI.ITMRVA AS i
    JOIN MasterData_ItemMaster_AFI.ITBEXT AS i1 ON i.ITNBR = i1.ITNBR
    WHERE i.STID = '335' AND i1.House = '335'
)
SELECT
    t.location_id,
    t.TypeDescription,
    t.status,
    t.capacity_volume,
    t.pick_area,
    t.location_tier,
    t.Aisle,
    t1.CapacityVolume,
    t.Loc_length_m,
    t.Loc_width_m,
    t.Loc_height_m,
    t.Loc_CBM,
    CASE
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 'CG_bulk_stack_area'
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation2 IN ('GG', 'GJ', 'GK', 'GM', 'GN', 'GQ', 'GR', 'GT', 'GU', 'GW', 'GX', 'GZ',
            'JA', 'JC', 'JD', 'JF', 'JG', 'JJ', 'JK', 'JM', 'JN', 'JQ', 'JR', 'JT', 'JU', 'JW', 'JX', 'JZ', 'LA', 'LC', 'LD', 'LF', 'LG', 'LJ', 'LK', 'LM', 'LN', 'LQ', 'LR', 'LT') THEN 'CG_bulk_stack_area'
        WHEN t.AisleCode = '11' AND t.SubLocation3 = '1' AND t.SubLocation2 IN ('FN', 'FP', 'FQ', 'FR', 'FS', 'FT', 'FU', 'FV', 'FW', 'FX', 'FY', 'FZ',
            'HA', 'HB', 'HC', 'HD', 'HE', 'HF', 'HG', 'HH', 'HJ', 'HK', 'HL', 'HM', 'HN', 'HP', 'HQ', 'HR', 'HS', 'HT', 'HU', 'HV', 'HW', 'HX', 'HY', 'HZ', 'KA', 'KB', 'KC', 'KD') THEN 'CG_bulk_stack_area'
        WHEN t.AisleCode = '15' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L', 'N', 'Q', 'S', 'U', 'W') THEN 'CG_rails_area'
        WHEN t.AisleCode = '17' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L', 'N', 'Q', 'S', 'U', 'W') THEN 'CG_3.5X7_area'
        WHEN t.AisleCode = '17' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M', 'P', 'R', 'T', 'V', 'X') THEN 'CG_3.5X5_area'
        WHEN t.AisleCode = '18' AND t.SubLocation1 IN ('C', 'D', 'E', 'F') THEN 'CG_bulk_stack_area'
        WHEN t.AisleCode = '18' AND t.SubLocation2 IN ('GA', 'GB', 'GC', 'GD', 'HA', 'HB', 'HC', 'HD') THEN 'CG_bulk_stack_area'
        WHEN t.AisleCode = '18' THEN 'UPH_racking_area'
        WHEN t.pick_area LIKE 'UPH%' THEN 'UPH_racking_area'
        ELSE 'CG_racking_area'
    END AS location_Category,
    CASE
        WHEN t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L', 'N', 'Q', 'S', 'U', 'W') THEN 'A'
        WHEN t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M', 'P', 'R', 'T', 'V', 'X') THEN 'B'
        ELSE 'Check'
    END AS Location_side,
    CASE
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 'NO_SKID'
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation2 IN ('GG', 'GJ', 'GK', 'GM', 'GN', 'GQ', 'GR', 'GT', 'GU', 'GW', 'GX', 'GZ',
            'JA', 'JC', 'JD', 'JF', 'JG', 'JJ', 'JK', 'JM', 'JN', 'JQ', 'JR', 'JT', 'JU', 'JW', 'JX', 'JZ', 'LA', 'LC', 'LD', 'LF', 'LG', 'LJ', 'LK', 'LM', 'LN', 'LQ', 'LR', 'LT') THEN 'NO_SKID'
        WHEN t.AisleCode = '10' AND t.SubLocation3 IN ('2', '3', '4') THEN '3.5X7'
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' THEN '5X8'
        WHEN t.AisleCode = '11' AND t.SubLocation3 = '1' AND t.SubLocation2 IN ('FN', 'FP', 'FQ', 'FR', 'FS', 'FT', 'FU', 'FV', 'FW', 'FX', 'FY', 'FZ',
            'HA', 'HB', 'HC', 'HD', 'HE', 'HF', 'HG', 'HH', 'HJ', 'HK', 'HL', 'HM', 'HN', 'HP', 'HQ', 'HR', 'HS', 'HT', 'HU', 'HV', 'HW', 'HX', 'HY', 'HZ', 'KA', 'KB', 'KC', 'KD') THEN 'NO_SKID'
        WHEN t.AisleCode = '11' THEN '5X7'
        WHEN t.AisleCode = '12' THEN '5X5'
        WHEN t.AisleCode = '13' THEN '5X7'
        WHEN t.AisleCode = '14' THEN '5X5'
        WHEN t.AisleCode = '15' THEN '5X7'
        WHEN t.AisleCode = '16' THEN '5X5'
        WHEN t.AisleCode = '17' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M', 'P', 'R') THEN '3.5X5'
        WHEN t.AisleCode = '17' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L', 'N', 'Q') THEN '3.5X7'
        ELSE 'NO_SKID'
    END AS Pallet_Type,
    CASE
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 0
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation2 IN ('GG', 'GJ', 'GK', 'GM', 'GN', 'GQ', 'GR', 'GT', 'GU', 'GW', 'GX', 'GZ',
            'JA', 'JC', 'JD', 'JF', 'JG', 'JJ', 'JK', 'JM', 'JN', 'JQ', 'JR', 'JT', 'JU', 'JW', 'JX', 'JZ', 'LA', 'LC', 'LD', 'LF', 'LG', 'LJ', 'LK', 'LM', 'LN', 'LQ', 'LR', 'LT') THEN 0
        WHEN t.AisleCode = '10' THEN 1
        WHEN t.AisleCode = '11' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 2
        WHEN t.AisleCode = '11' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 3
        WHEN t.AisleCode = '12' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 3
        WHEN t.AisleCode = '12' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 4
        WHEN t.AisleCode = '13' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 2
        WHEN t.AisleCode = '13' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 3
        WHEN t.AisleCode = '14' THEN 1
        WHEN t.AisleCode = '15' THEN 1
        WHEN t.AisleCode = '16' THEN 1
        WHEN t.AisleCode = '17' THEN 1
        ELSE 0
    END AS Capacity_by_pallet,
    CASE
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN CONVERT(INT, t.capacity_volume * 0.000016 * 0.7 / 0.93)
        WHEN t.AisleCode = '10' AND t.SubLocation3 = '1' AND t.SubLocation2 IN ('GG', 'GJ', 'GK', 'GM', 'GN', 'GQ', 'GR', 'GT', 'GU', 'GW', 'GX', 'GZ',
            'JA', 'JC', 'JD', 'JF', 'JG', 'JJ', 'JK', 'JM', 'JN', 'JQ', 'JR', 'JT', 'JU', 'JW', 'JX', 'JZ', 'LA', 'LC', 'LD', 'LF', 'LG', 'LJ', 'LK', 'LM', 'LN', 'LQ', 'LR', 'LT') THEN CONVERT(INT, t.capacity_volume * 0.000016 * 0.7 / 0.93)
        WHEN t.AisleCode = '10' THEN 11
        WHEN t.AisleCode = '11' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 2 * 11
        WHEN t.AisleCode = '11' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 3 * 11
        WHEN t.AisleCode = '12' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 3 * 11
        WHEN t.AisleCode = '12' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 4 * 11
        WHEN t.AisleCode = '13' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 2 * 11
        WHEN t.AisleCode = '13' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 3 * 11
        WHEN t.AisleCode = '14' THEN 1 * 11
        WHEN t.AisleCode = '15' AND t.SubLocation1 IN ('D', 'F', 'H', 'K', 'M') THEN 1 * 11
        WHEN t.AisleCode = '15' AND t.SubLocation1 IN ('C', 'E', 'G', 'J', 'L') THEN 1 * 15
        WHEN t.AisleCode = '16' THEN 1 * 11
        WHEN t.AisleCode = '17' THEN 1 * 11
        WHEN t.AisleCode = '18' AND t.SubLocation1 IN ('C', 'D', 'E', 'F') THEN CONVERT(INT, t.capacity_volume * 0.000016 * 0.7 / 0.93)
        WHEN t.AisleCode = '18' AND t.SubLocation2 IN ('GA', 'GB', 'GC', 'GD', 'HA', 'HB', 'HC', 'HD') THEN CONVERT(INT, t.capacity_volume * 0.000016 * 0.7 / 0.93)
        WHEN t1.CapacityVolume = 350000 THEN 7
        WHEN t1.CapacityVolume = 400000 THEN 8
        WHEN t1.CapacityVolume = 450000 THEN 9
        WHEN t1.CapacityVolume = 500000 THEN 10
        WHEN t1.CapacityVolume = 600000 THEN 12
        ELSE 0
    END AS Capacity_by_pieces,
    t2.item_number,
    t2.Racking_Qty,
    t2.Pallet_Type,
    t2.ITCLS,
    t2.B2Z95S,
    t2.TIHIUNLD,
    t2.PICKPUT,
    t2.ITMCLSID,
    t2.UNITSWIDE,
    t2.UNITLAYERS,
    t2.UNITSDEEP,
    t2.SCOOPQTY,
    t2.SKIDSIZE,
    t2.product_fit_Category,
    t2.Pallet_Qty,
    t2.Racking_Product_CBM,
    CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) AS Loc_UtilizationRate,
    CASE
        WHEN t2.Racking_Qty IS NULL THEN 'Empty location'
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.05 THEN '0 ~ 5% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.10 THEN '5 ~ 10% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.15 THEN '10 ~ 15% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.20 THEN '15 ~ 20% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.25 THEN '20 ~ 25% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.30 THEN '25 ~ 30% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.35 THEN '30 ~ 35% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.40 THEN '35 ~ 40% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.45 THEN '40 ~ 45% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.50 THEN '45 ~ 50% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.55 THEN '50 ~ 55% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.60 THEN '55 ~ 60% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.65 THEN '60 ~ 65% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.70 THEN '65 ~ 70% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.75 THEN '70 ~ 75% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.80 THEN '75 ~ 80% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.85 THEN '80 ~ 85% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 0.90 THEN '85 ~ 90% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 1 THEN '90 ~ 100% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 1.1 THEN '100 ~ 110% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 1.2 THEN '110 ~ 120% '
        WHEN CONVERT(DECIMAL(10, 2), (t2.Racking_Product_CBM / t.Loc_CBM)) < 1.3 THEN '120 ~ 130% '
        ELSE 'Over 130%'
    END AS Range_of_Loc_Utilization_Rate
FROM LocationData t
LEFT JOIN ClassLoca t1 ON t.location_id = t1.LocationId
LEFT JOIN (
    SELECT
        r0.item_number,
        r0.location_id,
        r0.Racking_Qty,
        i0.ITCLS,
        i0.B2Z95S,
        i0.TIHIUNLD,
        i0.PICKPUT,
        i0.ITMCLSID,
        i0.UNITSWIDE,
        i0.UNITLAYERS,
        i0.UNITSDEEP,
        i0.SCOOPQTY,
        i0.SKIDSIZE,
        CASE
            WHEN i0.ITCLS NOT LIKE 'Z%' THEN 'RP_racking_area'
            WHEN i0.PICKPUT = 'UPH' THEN 'UPH_racking_area'
            WHEN i0.PICKPUT = 'PALLT' AND i0.SKIDSIZE IN ('4') THEN 'CG_3.5X5_area'
            WHEN i0.PICKPUT = 'PALLT' AND i0.SKIDSIZE IN ('5') THEN 'CG_3.5X7_area'
            WHEN i0.PICKPUT = 'PALLT' AND i0.ITMCLSID IN ('RAILS') THEN 'CG_rails_area'
            WHEN i0.PICKPUT = 'PALLT' AND i0.ITMCLSID IN ('FLOOR', 'FLOOROP') THEN 'CG_bulk_stack_area'
            ELSE 'CG_racking_area'
        END AS product_fit_Category,
        CONVERT(DECIMAL(10, 2), r0.Racking_Qty * i0.B2Z95S * 0.028317) AS Racking_Product_CBM,
        CASE
            WHEN i0.ITCLS NOT LIKE 'Z%' THEN 0.001
            WHEN i0.PICKPUT = 'UPH' THEN 0
            WHEN i0.PICKPUT = 'PALLT' AND i0.SCOOPQTY = 0 THEN CEILING(r0.Racking_Qty / 10)
            ELSE CEILING(r0.Racking_Qty / i0.SCOOPQTY)
        END AS Pallet_Qty
    FROM ItemData r0
    LEFT JOIN ItemMaster i0 ON r0.item_number = i0.ITNBR
) t2 ON t.location_id = t2.location_id
ORDER BY t.location_id;
