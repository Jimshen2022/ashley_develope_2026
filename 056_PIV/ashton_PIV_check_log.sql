-- PIV check
select * from t_equipment_check_log where equipment_id  IN ('VJ1657')



select * from t_location where location_id IN ('VS720','VS787','VSJIM5')
select * from t_equipment_attributes where equipment_id  LIKE 'VS%'
select * from t_equipment_attributes where equipment_id  IN ('VSJIM5','VS787')

select * from t_equipment_check_log where equipment_id  IN ('VS787','VSJIM5')  and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where equipment_id = 'VS720' and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where equipment_id = 'VS787' and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where equipment_id = 'VSJIM5' and check_performed >= '2026-04-01' order by check_performed desc

