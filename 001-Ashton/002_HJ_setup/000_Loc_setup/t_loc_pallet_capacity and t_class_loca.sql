select top 10 * from t_location
select top 10 * from t_class_loca
select top 10 * from t_loc_pallet_capacity
select top 10 * from t_class_loca where location_id like 'A3011D%'
select * from t_class_loca where class_id like 'MATT%' AND location_id like 'A3%'

select top 10 * from t_location where location_id like 'A3018MP1%'
select top 10 * from t_class_loca where location_id like 'A3018MP1%'
select top 10 * from t_loc_pallet_capacity where location_id like 'A3018MP1%'
select top 10 * from t_loc_pallet_capacity where location_id like 'A3018DA1%'


/*   INSERT A3018MP1 class_id into A3018DA1 location_id  */

INSERT
t_class_loca
(wh_id,class_id,location_id,fill_seq,capacity_volume)
select wh_id, class_id, 'A3018DA1'  as location_id, fill_seq, capacity_volume
from t_class_loca where location_id ='A3018MP1' and class_id not in ('FLOOR','PAL5H','PTEMP','RUGS')


/*   INSERT A3018MP1 t_loc_pallet_capacity into A3018DA1 location_id  */

INSERT
t_loc_pallet_capacity
(wh_id,location_id,pallet_id,capacity)

(select  wh_id,'A3018DA1',pallet_id,'999'
from t_loc_pallet_capacity where location_id ='A3018MP1' and pallet_id not in (3,16,18))
/*

select wh_id, class_id, 'A3018DA1'  as location_id, fill_seq, capacity_volume
from t_class_loca where location_id like 'A3018MP1%'



select top 10 * from t_location where location_id like 'A3018DA1%'
select top 10 * from t_class_loca where location_id like 'A3018DA1%'
select top 10 * from t_loc_pallet_capacity where location_id like 'A3018DA1%'


select top 10 * from t_class_loca where location_id like 'A3011D%'
select * from t_class_loca where class_id like 'MATT%' AND location_id like 'A3%'



select top 10 * 
from t_loc_pallet_capacity as p
join t_class_loca  as c  on p.location_id = c.location_id
where p.location_id like 'A3011D%'


select  * from t_loc_pallet_capacity where location_id like 'A3025[CEGJL]%[34]'


select * from t_class_loca t0
join (select * from t_location where pick_area not like 'CA%') as t ON t0.location_id = t.location_id
where t0.location_id like 'A3025[CEGJL]%[34]' and t0.capacity_volume is null  and t0.location_id not like 'A3025[G][EFGH]%[23]' 

select * from t_class_loca t0
join (select * from t_location where pick_area  like 'CA%') as t ON t0.location_id = t.location_id
where t0.location_id like 'A3025[CEGJL]%[1234]' and t0.capacity_volume is null and class_id != 'PTEMP'