-- SCOOP
select top 10 * from t_item_master	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')
select top 10 * from t_item_uom	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')
select top 10 * from t_fwd_pick	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')
select top 10 * from t_item_plate_section	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')


select t.item_number, t.pick_put_id, t.class_id, t.description, t.uom, t.inventory_type, t.commodity_code, p.*
from t_item_master  as t 
inner join t_item_plate_section	as p  on t.item_number = p.item_number
where t.item_number IN ('P297-070','P572-821','P587-602A','P510-821')
