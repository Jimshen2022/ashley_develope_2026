select t.tran_type,
	t.description,
	DATEADD(DAY, 6 - DATEPART(WEEKDAY, t.start_tran_date), t.start_tran_date) AS saturday_of_week,
	t.location_id,
	t.location_id_2,
	t2.pick_area,
	right(t.location_id,1) as tier,
	t3.pick_put_id,
	case 
		when t.location_id_2 like 'VS%' then 'OrderPicker'
		when t.location_id_2 like 'VR%' then 'ReachTruck'
		when t.location_id_2 like 'VF%' then 'Forklifer'
		when t.location_id_2 like 'VJ%' then 'PalletJack'
		when t.location_id_2 like 'VE%' then 'ClampTruck'
		else 'OnFoot' end as picking_equirement,
	sum(t.tran_qty) as picked_qty
from t_tran_log as t
join t_location as t2 on t2.location_id = t.location_id
join t_item_master as t3 on t3.item_number = t.item_number
where t.tran_type  = '363' 
group by t.tran_type,
	t.description,
	DATEADD(DAY, 6 - DATEPART(WEEKDAY, t.start_tran_date), t.start_tran_date),
	t.location_id,
	t.location_id_2,
	t2.pick_area,
	right(t.location_id,1),
	t3.pick_put_id,
		case 
		when t.location_id_2 like 'VS%' then 'OrderPicker'
		when t.location_id_2 like 'VR%' then 'ReachTruck'
		when t.location_id_2 like 'VF%' then 'Forklifer'
		when t.location_id_2 like 'VJ%' then 'PalletJack'
		when t.location_id_2 like 'VE%' then 'ClampTruck'
		else 'OnFoot' end
order by saturday_of_week