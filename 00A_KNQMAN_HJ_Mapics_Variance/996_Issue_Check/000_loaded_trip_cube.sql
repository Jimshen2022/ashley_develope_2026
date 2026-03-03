
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%dispatch%'
select * from t_item_master



select top 10 * from t_order  
select top 10 * from t_order  where order_number like '0071028-%'  -- unrelease
select top 10 * from t_order  where order_number like '0072031-%' --  released
select top 10 * from t_order  where order_number like '0070952-%'   -- W-RF
select top 10 * from t_order  where order_number like '0070955-%'  
select top 10 * from t_order_detail 
select top 10 * from t_order_detail where order_number like '0071028-%'
select top 10 * from t_order_detail where order_number like '0072031-%'
select top 10 * from t_order_detail where order_number like '0070952-%'
select top 10 * from t_order_detail where order_number like '0070955-%'
select top 10 * from t_pick_detail 
select top 10 * from t_order_detail_breakdown
select top 10 * from t_order_detail_breakdown where ship_status is null
select top 10 * from t_order_detail_breakdown where order_number like '0071028-%'
select top 10 * from t_order_detail_breakdown where order_number like '0072031-%'
select top 10 * from t_order_detail_breakdown where order_number like '0070952-%'
select  * from t_order_detail_breakdown where order_number like '0070955-%'
select distinct ship_status from t_order_detail_breakdown  
select top 10 * from t_load_dispatch

with itm as (
	select *
	from t_item_master where pick_put_id = 'Default'

)

select t.wh_id, left(t.order_number,7) as trip_nbr, 
	sum(qty) as planned_Qty, 
	sum(bo_qty) as bo_qty, 
	sum(remaining_qty)  as remaining_qty, 
	sum(t.item_price-t.item_discount) as Amount
from t_order_detail_breakdown as t
group by t.wh_id,left(t.order_number,7)


select order_number,ship_status, sum(qty) as qty from t_order_detail_breakdown group by ship_status, order_number
select ship_status, sum(qty) as qty from t_order_detail_breakdown group by ship_status

select top 10 * from t_load_dispatch


-- loaded cubes for trip# 
select  t.order_number, t.status, t.item_number,t.loaded_quantity, i.unit_volume, nested_volume, t.loaded_quantity *i.nested_volume as cubes, i.length, i.width, i.height
from t_pick_detail as t
join t_item_master as i on t.item_number = i.item_number
--where t.order_number like '%60381%' and t.picked_quantity>0
where  t.picked_quantity>0
order by t.item_number