
select top 10 * from t_item_uom
-- BULK,Letdown Issue Audit Query
select  item_number, equipment_class_id,class_id from t_item_uom where class_id = 'FLOOR' and equipment_class_id <> '5' GROUP BY item_number, equipment_class_id


select  item_number, equipment_class_id,class_id from t_item_uom where pick_put_id = 'PALLT' and equipment_class_id <> '5' GROUP BY item_number, equipment_class_id, class_id

