select top 10 * from t_stored_item

select item_number, location_id, sum(actual_qty) as total_actual_qty
from t_stored_item
where wh_id = '335' and location_id like 'A3%' and actual_qty > 0
group by item_number, location_id


select location_id, sum(actual_qty) as total_actual_qty
from t_stored_item
where wh_id = '335' and location_id like 'A3%' and actual_qty > 0
group by location_id