-- change pick area

-- change putaway class

--- change zone

select * from t_zone_loca where location_id like 'A3020%1' and zone_id = 'RUGS'

--- change pallet location capacity


-- STORED
select * from t_class_loca where location_id like 'A3020%1' 
select * from t_stored_item where location_id like 'A3020%1' 


INSERT INTO t_class_loca (wh_id, class_id, location_id, fill_seq, capacity_volume)
VALUES
('335','UPHL','A3021CA2','005','400000')




select top 10 * from t_class where class_id LIKE 'RUGS%'

select * 
from t_class_loca as t
where t.location_id like 'A3018%1' and t.class_id <> 'RUGS' 
and (SUBSTRING(t.location_id, 6, 1) IN ('D','F','H','K','M') 
or SUBSTRING(t.location_id, 6, 1) IN ('C','E','G','J','L')) 


where location_id like 'A3018%1' and class_id <> 'RUGS' 
and SUBSTRING(location_id, 6, 1) IN ('C') 

where location_id like 'A3018%1' and class_id <> 'RUGS' 
and SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','C','E') 