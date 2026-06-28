SELECT TOP 10 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%loc%capa%'
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 't_loc_pallet_capacity';



select top 10 * from t_loc_pallet_capacity 
where location_id like 'A3011MP1%'


update 
set t.type = 'M'

UPDATE set t.type = 'M'
from t_location as t
where SUBSTRING(t.location_id, 6, 1) IN ('D','F','H','J','M','C','E') 
and t.location_id like 'A3018%1'
and t.type = 'I'
order by t.location_id


select  *
from t_location as t where t.location_id like 'A3018%1'
A3018GA1
A3018GB1
A3018GC1
A3018GD1

select *
from t_stored_item as s
where s.location_id in (
				select  t.location_id
				from t_location as t
				where SUBSTRING(t.location_id, 6, 1) IN ('D','F','H','J','L','M') 
				and t.location_id like 'A3018%1'
				and t.type = 'I'
				)


