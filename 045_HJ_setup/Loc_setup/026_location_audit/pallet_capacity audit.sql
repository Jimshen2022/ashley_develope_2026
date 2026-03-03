SELECT t.*
FROM t_location t
WHERE t.location_id LIKE 'A3021%'
  AND NOT EXISTS (
        SELECT 1
        FROM t_loc_pallet_capacity a
        WHERE a.location_id = t.location_id
  );
