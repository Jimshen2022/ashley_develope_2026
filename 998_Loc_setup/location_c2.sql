--select top 10 * from t_location as t
--select top 10 * from t_stored_item as t


SELECT TOP 1000 * 
from t_location AS l
WHERE 1=1
  and l.c2 is null 
  and l.location_id like 'A3%'
