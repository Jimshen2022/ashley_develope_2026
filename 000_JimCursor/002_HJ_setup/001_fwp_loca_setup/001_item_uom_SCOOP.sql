SELECT 
    u.item_number,
    u.uom,
    u.conversion_factor,
    u.priority,
    u.class_id,
    u.pick_put_id,
    u.units_per_layer,
    u.layers_per_uom,
    u.max_in_layer,
    u.pallet_id,
    u.equipment_class_id,
    u.cube_factor,
    u.nested_volume,
    u.unit_volume,
    f.location_id,
    u.std_hand_qty,
    f.replen_level,
    f.capacity_qty,
    f.replen_qty,
    u.max_hand_qty,
    f.is_new_item,
    sum(si.actual_qty) as onhand,
    case 
        when u.std_hand_qty + f.replen_level <> f.capacity_qty then 'std_handling_qty + replen_level <> capacity_qty'
        else 'std_handling_qty + replen_level = capacity_qty' 
        end as check_scoop_setup_result
FROM t_item_uom AS u
LEFT JOIN t_stored_item AS si ON si.item_number = u.item_number
left join t_fwd_pick as f on f.item_number = u.item_number
left join t_item_master as m on m.item_number = u.item_number
WHERE u.uom = 'SCOOP' and m.inventory_type in ('FG') 
group by u.item_number, u.uom, u.conversion_factor, u.priority, u.class_id, u.pick_put_id, 
    u.units_per_layer, u.layers_per_uom, u.max_in_layer, u.std_hand_qty, u.max_hand_qty, 
    u.pallet_id, u.equipment_class_id, u.cube_factor, u.nested_volume, u.unit_volume,
    f.location_id, f.replen_qty, f.capacity_qty, f.is_new_item, f.replen_level
