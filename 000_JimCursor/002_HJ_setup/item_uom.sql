select top 10 * from t_item_master	(NOLOCK) where item_number IN ('3550483')
select top 10 * from t_item_uom	(NOLOCK) where item_number IN ('3550483')



-- SCOOP
select top 10 * from t_item_master	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')
select top 10 * from t_item_uom	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')
select top 10 * from t_fwd_pick	(NOLOCK) where item_number IN ('P297-070','P572-821','P587-602A','P510-821')

select top 10 * from t_item_master	(NOLOCK) where item_number = 'M00304'


update t_item_master
set std_hand_qty = 13
where item_number = 'M00304'

select top 10 * from t_item_master	(NOLOCK) where item_number = 'M00204'
select top 10 * from t_fwd_pick	(NOLOCK) where item_number = 'M00204'
select top 10 * from t_item_uom (NOLOCK) where item_number = 'M00204'
update t_item_uom
set std_hand_qty = 13
where item_number = 'M00304' and uom = 'CS'

update t_item_uom
set std_hand_qty = 12, units_per_layer = 2, layers_per_uom = 3,  max_in_layer = 2
where item_number = 'M00204' and uom = 'SCOOP'

