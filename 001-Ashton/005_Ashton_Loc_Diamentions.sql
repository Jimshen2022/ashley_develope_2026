
--Ashton A3 location dimensions 
SELECT t0.wh_id, t0.location_id, t0.TypeDescription, t0.status, 
t0.width*0.0254 as 'width(m)', t0.height*0.0254 as 'Height(m)',  t0.length*0.0254 as 'Length(m)', 
t0.capacity_volume, CAST(t0.capacity_volume*0.000016 AS DECIMAL(10,2)) as CBM, 
t0.width as 'Width(inch)', 
t0.height as 'Height(inch)',
t0.length as 'Length(inch)'
FROM Distribution_Warehouse_Wholesale.t_location AS t0
WHERE t0.wh_id = '335' and t0.location_id LIKE 'A3%'
ORDER BY t0.location_id