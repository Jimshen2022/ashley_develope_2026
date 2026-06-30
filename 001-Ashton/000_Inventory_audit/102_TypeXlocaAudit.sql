--select * from t_eil_xml_msg

-- type X locations



select l.location_id,l.status, l.type, sto.onhand, sto.SKUs
from t_location as l
left join (select location_id, sum(actual_qty) as onhand, count(distinct item_number) as SKUs from t_stored_item group by location_id) as sto on sto.location_id = l.location_id
where  l.type = 'X' and (sto.SKUs =1 or  sto.SKUs is null) and l.location_id like 'A3%'
