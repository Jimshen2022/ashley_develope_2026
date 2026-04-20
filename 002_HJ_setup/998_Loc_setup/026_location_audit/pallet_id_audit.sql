SELECT 
    t.wh_id, 
    t.location_id, 
    c.class_id, 
    c.fill_seq, 
    c.capacity_volume, 
    t.type,
    -- 检查是否同时存在pallet_id = '1' 和 '3'
    CASE WHEN 
        MAX(CASE WHEN p.pallet_id = '1' THEN 1 ELSE 0 END) = 1 
        AND MAX(CASE WHEN p.pallet_id = '3' THEN 1 ELSE 0 END) = 1 
    THEN 1 ELSE 0 END AS has_both_1_and_3,
    -- 获取pallet_id不等于'1'和'3'的值（用逗号分隔）
    STRING_AGG(
        CASE WHEN p.pallet_id NOT IN ('1', '3') 
             THEN p.pallet_id ELSE NULL END, 
        ', '
    ) WITHIN GROUP (ORDER BY p.pallet_id) AS other_pallet_ids,
    -- 获取对应的capacity（用逗号分隔）
    STRING_AGG(
        CASE WHEN p.pallet_id NOT IN ('1', '3') 
             THEN CAST(p.capacity AS VARCHAR(20)) ELSE NULL END, 
        ', '
    ) WITHIN GROUP (ORDER BY p.pallet_id) AS other_capacities
FROM t_location t 
LEFT JOIN t_class_loca c ON t.location_id = c.location_id 
LEFT JOIN t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3015[CEGJLNQSUWY]%' 
GROUP BY 
    t.wh_id, 
    t.location_id, 
    c.class_id, 
    c.fill_seq, 
    c.capacity_volume, 
    t.type
ORDER BY t.location_id