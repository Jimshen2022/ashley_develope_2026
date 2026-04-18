
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%performed%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%xdock%'


-- PIV check
select * from t_equipment_check_log where equipment_id  IN ('VJ1346') ORDER BY check_performed desc
select * from t_equipment_attributes where equipment_id  IN ('VJ1346')
select * from t_OSHA_attributes
select * from t_OSHA_checklist_attributes



select c.*,a.*
from t_OSHA_checklist_attributes c
inner join t_OSHA_attributes a on c.attribute_id = a.attribute_id and c.locale_id = a.locale_id

select top 10 * from t_OSHA_checklist_attributes
select top 10 * from t_employee_attribute
select top 10 * from t_equipment_attributes

select l.*, t.attribute_name, t.attribute_status, t.screen_prompt, t.locale_id
from t_equipment_check_log as l
LEFT JOIN t_OSHA_attributes as t on l.checklist_attribute_id = t.attribute_id
where l.employee_id   IN ('51001')
order by l.check_performed desc



select * from t_equipment_attributes
select top 10 * from t_equipment_attributes
select * from t_OSHA_attributes
select top 10 * from t_OSHA_checklist_attributes

select * from t_location where location_id IN ('VS720','VS787','VSJIM5')
select * from t_equipment_attributes where equipment_id  LIKE 'VS%'
select * from t_equipment_attributes where power_type LIKE 'LP%'

select * from t_equipment_check_log where equipment_id  IN ('VS787','VSJIM5')  and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where equipment_id  IN ('VS787','VSJIM5')  and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where equipment_id = 'VS720' and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where equipment_id = 'VS787' and check_performed >= '2026-04-01' order by check_performed desc
select * from t_equipment_check_log where  check_performed >= '2026-04-15' order by check_performed desc

