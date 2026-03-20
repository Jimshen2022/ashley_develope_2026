select itm.wh_id,itm.item_number,itm.unit_volume as cube,itm.length,itm.width,itm.height,
uom.length as Len1,uom.width as wid1,uom.height as hei1,uom.unit_volume,uom.nested_volume,
round(uom.length * uom.width * uom.height,0) , round(itm.unit_volume * 1728,0),
uom.nested_volume - round(itm.unit_volume * 1728,0)
from t_item_master (nolock) itm
join t_item_uom (nolock) uom  on itm.wh_id=uom.wh_id and itm.item_number=uom.item_number
and uom.uom=itm.uom
where itm.pick_put_id in ('UPH','PALLT')
--and (itm.length <> uom.length or itm.width <> uom.width  or itm.height <> uom.height)
and round(itm.unit_volume * 1728,0) <> uom.nested_volume
--and round(uom.length * uom.width * uom.height,0) <> uom.unit_volume and uom.unit_volume <> 0
order by itm.wh_id,itm.item_number