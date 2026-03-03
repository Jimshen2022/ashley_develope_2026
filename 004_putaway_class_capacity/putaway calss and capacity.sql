/*
SELECT top 10 * FROM t_location where len(location_id) = 8
select top 10 *  from  t_class_loca where location_id like 'A3010CA%'
select top 10 *  from  t_loc_pallet_capacity 
select * from t_loc_pallet_capacity where location_id like 'A3010%' AND SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','P','R','T')
select * from t_loc_pallet_capacity where location_id like 'A3010%' AND SUBSTRING(location_id, 6, 1) IN ('C','E','G','J','L','N','Q','S')
*/
-- putaway class 15
SELECT 
    t0.wh_id, 
    t0.location_id, 
    STUFF((
        SELECT DISTINCT ',' + class_id
        FROM t_class_loca t2
        WHERE t2.wh_id = t0.wh_id 
            AND t2.location_id = t0.location_id
            AND t2.location_id LIKE 'A3011CA1%'  
            AND SUBSTRING(t2.location_id, 6, 1) IN ('C','E','G','J','L','N','Q')
        FOR XML PATH('')
    ), 1, 1, '') AS class_ids
FROM t_location AS t0
LEFT JOIN t_class_loca t1 ON t0.location_id = t1.location_id
WHERE t0.location_id LIKE 'A3011CA1%'  
    AND SUBSTRING(t0.location_id, 6, 1) IN ('C','E','G','J','L','N','Q')
GROUP BY t0.wh_id, t0.location_id
ORDER BY t0.wh_id, t0.location_id


