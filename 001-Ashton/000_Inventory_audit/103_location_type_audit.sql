select top 10 * from Distribution_Warehouse_Wholesale.t_location 
Distribution_Warehouse_Wholesale.t_loc_pallet_capacity


select top 10 * from Distribution_Warehouse_Wholesale.t_location 


-- location type review for preventing be removed by trip available reprot 
SELECT
    t.wh_id,
    t.item_number,
    t.location_id,
    t.actual_qty,
    t.[status],
    t.[type],
    t0.TypeDescription
FROM Distribution_Warehouse_Wholesale.t_stored_item AS t
INNER JOIN Distribution_Warehouse_Wholesale.t_location AS t0
    ON t.wh_id = t0.wh_id
   AND t.location_id = t0.location_id
WHERE 1=1
  -- AND t.item_number = 'D631-01'
  AND t.wh_id = '335'
  AND t0.TypeDescription NOT IN ('I','P','M','X','Z','S','F','D','V','RS')
  AND t.location_id NOT LIKE 'RP998%';