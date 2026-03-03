

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

where location_id like 'A3018%1' and class_id <> 'RUGS' 
and SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','C','E') 

where location_id like 'A3018%1' and class_id <> 'RUGS' 
and SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','C','E') 

where location_id like 'A3018%1' and class_id <> 'RUGS' 
and SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','C','E') 

where location_id like 'A3018%1' and class_id <> 'RUGS' 
and SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','C','E') 