
begin tran
update t_stored_item set type='STORAGE', location_id='A3020GQ4' where item_number in ('5590335','2940202','2940211','2940217') and location_id='VS762'
Update t_serial_active set location_id='A3020GQ4' where item_number in ('5590335','2940202','2940211','2940217') and location_id='VS762'
update t_pick_detail set status='RELEASED', picked_quantity=0, user_assigned=NULL where item_number in ('5590335','2940202','2940211','2940217') and pick_id in('5137935','5137936','5137937','5137941')and order_number ='0057210-00:01'
rollback tran





select TOP 10 * from t_employee
select TOP 10 * from t_location
select TOP 10 * from t_stored_item
select TOP 10 * from t_pick_detail
select TOP 10 * from t_serial_active
select TOP 10 * from t_work_q
select TOP 10 * from t_work_q_assignment
select TOP 10 * from t_load_master
select TOP 10 * from t_hu_master 



select*from t_employee(nolock) where device='WA238H'
select *from t_location (nolock) where c1='50919'
select*from t_stored_item(nolock) where location_id='VS762'
select * from t_pick_detail(nolock) where order_number like '%57210%' and item_number in ('2940202','2940211','2940217','5590335')
select*from t_serial_active(nolock) where location_id='VS762' and serial_no_status<>'O'
select * from t_pick_detail (nolock) where order_number ='0057210-00:01' and item_number in ('5590335','2940202','2940211','2940217')
select*from t_pick_detail where user_assigned='50919'

select* from t_work_q(nolock) where work_q_id='06287135'
select*from t_work_q_assignment(nolock) where user_assigned='179069'
select*from t_load_master(nolock) where load_id='0003296-00'
select* from t_hu_master where location_id='VS762'

'