-- This script is used to test the receiving process when there is an LP issue.

begin tran
insert into t_hu_master (hu_id,type,location_id,status,wh_id)
values ('00000039388093','IV','RS032AA1','A','335')
 
INSERT into t_hu_detail (hu_id,item_number,actual_qty,status,wh_id,storage_type)
values('00000039388093','P108-835',22,'A','335','STORAGE')
 
update t_serial_active 
  set hu_id='00000039388093'
where location_id='RS032AA1' and item_number='P108-835'
rollback tran


/* important note for receiving process:

if by LP:
then LP must exist (HUM, HUD, SNA) , HUM/SNA/STO location are same , 151 and 152 LP are same ,control_number_2 are same (verify_status is null-- hu_id,hu_id_2 )

put location 152(location) need H control, if I then LP is missing from HUM/HUD/SNA 
LP get from TRN (151)

if by SN:
   no HUM / HUD ,  
   SNA/STO location are smae , 
   151 and 152 control_number_2 are same (verify_status is null) 
   HUM (t_hu_master) type='IV
   HUD (t_hu_detail ) 


*/

-- HUM, HUD,SNA data should be inserted together, and the location should be same in those 3 tables,
-- and control_number_2 in SNA should be same as LP number in HUM/HUD, and verify_status in SNA should be null.


select top 10 * from t_hu_master where hu_id='00000039388093'
select top 10 * from t_hu_detail where hu_id='00000039388093'
select top 10000 * from t_serial_active where hu_id='00000039388093'
select top 10 * from t_stored_item where hu_id='00000039388093'
