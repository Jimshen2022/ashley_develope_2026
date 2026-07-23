-- check putaway class not on current rules list:

SELECT * FROM t_class_loca WHERE location_id like 'A3038VR1%'
SELECT * FROM t_loc_pallet_capacity WHERE location_id like 'A3038VR1%'


SELECT * FROM t_class_loca  
WHERE location_id like 'A3%' 
and class_id NOT in ('MATT','PTEMP','UTEMP','UPHHV','UPHXH','UPHH','UPHL','UPHOT','UPHCH','UPHMHV','UPHMH','UPHML','UPHMLL','UPHMXH','PAL3H','PAL5H','RAILS','SMALL','FLOOR','RUGS','RUGSS')

select distinct wh_id, 'FLOOR' as class_id, location_id, fill_seq, 0 as capacity_volume
from t_class_loca
where location_id like 'A30[34][01289]VR1%'
