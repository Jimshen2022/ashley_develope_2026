
-- replenishment check for item
select * from t_fwd_pick where capacity_qty >400

select top 10 * from t_item_master where item_number = 'A2000665'
select top 10 * from t_item_uom where item_number = 'A2000665'
select top 10 * from t_fwd_pick where item_number = 'A2000665'
select top 10 * from t_loc_pallet_capacity where location_id = 'A3012EA1'
select top 1000 * from t_work_q where item_number = 'A2000665'


select top 10 * from t_loc_pallet_capacity where location_id = 'A3012EA1'
select * from t_loc_pallet_capacity where capacity >50 and location_id like 'A3%'