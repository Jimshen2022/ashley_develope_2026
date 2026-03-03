
select top 10 *  from t_class_loca where location_id like 'A302%[CEGJLNQSUXZ]%'
select top 10 *  from t_location where location_id like 'A302%[CEGJLNQSUXZ]%'
select top 10 *  from t_class_loca where capacity_volume in ('300000')
select location_id, location_id, capacity_volume
from t_class_loca
WHERE location_id like 'A302%[CEGJLNQSUXZ]%'

select distinct capacity_volume from t_class_loca 
where location_id in ('200000','100000','300000')

update t_location
set capacity_volume = 400000
where location_id in (select distinct location_id from t_class_loca
WHERE capacity_volume = 400000 )