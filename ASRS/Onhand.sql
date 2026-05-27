
select oh.wh_id, oh.item_number, sum(oh.actual_qty) as onhand_qty
FROM Distribution_Warehouse_Wholesale.t_stored_item as oh
where oh.wh_id in  ('335') and (oh.location_id like 'A3%' OR oh.location_id like 'RS%')
group by oh.wh_id, oh.item_number