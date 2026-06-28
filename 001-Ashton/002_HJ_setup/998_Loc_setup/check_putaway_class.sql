-- check putaway class not on current rules list:
SELECT * FROM t_class_loca  
WHERE location_id like 'A3%' 
and class_id NOT in ('MATT','PTEMP','UTEMP','UPHHV','UPHXH','UPHH','UPHL','UPHOT','UPHCH','UPHMHV','UPHMH','UPHML','UPHMLL','UPHMXH','PAL3H','PAL5H','RAILS','SMALL','FLOOR','RUGS','RUGSS')

