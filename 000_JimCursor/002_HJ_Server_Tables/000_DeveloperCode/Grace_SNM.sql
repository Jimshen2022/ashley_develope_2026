select snm.wh_id,snm.serial_number,snm.serial_no_status,sna.wh_id,sna.serial_no_status,* 
from t_serial_master (nolock) snm
join t_serial_active (nolock) sna on snm.serial_number=sna.serial_number
where 1=1
and snm.serial_no_status <> sna.serial_no_status
and sna.serial_no_status <>'O'
and snm.wh_id='335'
 
select * from t_tran_log (nolock) where 1=1 and lot_number='526404100479' order by log_id
select * from t_tran_log (nolock) where 1=1 and lot_number='503951849996' order by log_id


 
begin tran
update snm
  set snm.serial_no_status=sna.serial_no_status
from t_serial_master snm
join t_serial_active (nolock) sna on snm.serial_number=sna.serial_number
where 1=1
and snm.serial_no_status <> sna.serial_no_status
and sna.serial_no_status <>'O'
and snm.wh_id='335'
rollback tran