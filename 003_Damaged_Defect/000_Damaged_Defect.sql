with itm AS (
select t.item_number,
	t.description,
	t.inventory_type,
	t.commodity_code,
	t.wh_id,
	t.class_id,
	t.pick_put_id
from Distribution_Warehouse_Wholesale.t_item_master as t where t.wh_id in ('335','51')
union all
select t.item_number,
	t.description,
	t.inventory_type,
	t.commodity_code,
	t.wh_id2 as wh_id,
	t.class_id,
	t.pick_put_id
from Distribution_Warehouse_Wholesale.t_item_master as t where t.wh_id2 in ('35')
)
select
	t.wh_id,
	t.tran_type,
	t.description,
	t.start_tran_date,
	DATEADD(DAY, 7 - DATEPART(WEEKDAY, t.start_tran_date), t.start_tran_date) as week_ending_saturday,
	MONTH(t.start_tran_date) as month,
	t.employee_id,
	t.item_number,
	t.lot_number,
	t.tran_qty,
	t.control_number_2 as from_location,
	t.location_id_2 as to_location,
    i.pick_put_id,
	case when i.pick_put_id = 'PALLT' then 'CG' ELSE 'UPH' END AS  product,
	case 
		when t.wh_id in ('35','33','31') and t.location_id_2 in ('NG001DC1') then 'DC'
		when t.wh_id in ('35','33','31') and t.location_id_2 in ('NG001UP1') then 'WN3_WN2'
		when t.wh_id in ('335') then 'Ashton'
		else 'MIL' END as site,
	case 
		when i.wh_id in ('51','35','33','31') then 'whse_damaged'
		when i.wh_id in ('335') and t.control_number_2 like 'RS%' then 'vendor_damaged' else 'whse_damaged' end as damaged_defect_type 
from Distribution_Warehouse_Wholesale.TranLog  as t
left join itm as i on i.wh_id = t.wh_id and i.item_number = t.item_number
where t.wh_id in ('335','51','35','33','31')  
	and t.location_id_2 in ('NG001UP1','NG001DC1', 'NG001CG1','DM001AA1')   
and start_tran_date > '2025-06-01' and  tran_type = '202'
order by t.start_tran_date