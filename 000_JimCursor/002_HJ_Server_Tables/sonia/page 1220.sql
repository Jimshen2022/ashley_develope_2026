--page 1220
select 
sto.sequence,sto.item_number,sto.actual_qty,sto.unavailable_qty,sto.status,sto.wh_id,sto.location_id, loc.type, sto.fifo_date,
sto.expiration_date,sto.reserved_for,sto.lot_number,sto.inspection_code,sto.serial_number,sto.type,
sto.put_away_location,sto.owner_id,sto.pod_status
from t_stored_item sto (nolock)
join t_location loc (nolock)
on sto.location_id = loc.location_id
and sto.wh_id=loc.wh_id 
and loc.type <> 'MA'
join t_item_master itm (nolock)
on sto.item_number = itm.item_number
and sto.wh_id=itm.wh_id  
where sto.wh_id = '~wh_id~'
  and sto.location_id like '~location_id~'
  and sto.item_number like '~item_number~'
  and sto.status like '~status~'
  and (('~lot_number~' = 'NULL' and sto.lot_number is null)
          or ('~lot_number~' = 'NOT NULL' and sto.lot_number is not null)
          or ('~lot_number~' = '%'))
  and sto.type like '~type~'
 and ISNULL(loc.building, '') like '~building~'
 and itm.pick_put_id like '~pick_put_id~' 
 and itm.commodity_code like '~inventory_type~' 
order by sto.item_number,sto.location_id

---page 1423 usp_trip_available_sto 

--sp_helptext'usp_trip_available_sto'
