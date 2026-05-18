SELECT 
    sto.sequence,
    sto.item_number,
    sto.actual_qty,
    sto.unavailable_qty,
    sto.status,
    sto.wh_id,
    sto.location_id,
    loc.type,
    sto.fifo_date,
    sto.expiration_date,
    sto.reserved_for,
    sto.lot_number,
    sto.inspection_code,
    sto.serial_number,
    sto.type,
    sto.put_away_location,
    sto.owner_id,
    sto.pod_status,
    -- 根据location_id判断sites
    case
        when sto.wh_id = '31' then 'Wanek1'
        when sto.wh_id = '33' then 'Wanek2'
        when sto.wh_id = '36' then 'Wanek5'
        when sto.wh_id = '35' and sto.location_id like 'DK%' then 'Wanek3'
        when sto.wh_id = '35' and sto.location_id like 'M%' then 'DC'
        when sto.wh_id = '35' and sto.location_id like 'UL%' then 'DC'
        when sto.wh_id = '35' and sto.location_id like 'S8%' then 'DC'
        when sto.wh_id = '35' and sto.location_id like 'D8%' then 'DC'
        when sto.wh_id = '35' and sto.location_id like 'VS%' then 'DC'
        when sto.location_id like 'C%' then 'DC In_Transit'
        else 'CHECK' end as site
FROM t_stored_item sto WITH (NOLOCK)
JOIN t_location loc WITH (NOLOCK)
    ON sto.location_id = loc.location_id
    AND sto.wh_id = loc.wh_id
    AND loc.type <> 'MA'
JOIN t_item_master itm WITH (NOLOCK)
    ON sto.item_number = itm.item_number
    AND sto.wh_id = itm.wh_id
WHERE sto.wh_id IN  ('35','33','31','36','34')
    AND sto.location_id LIKE '%'
    AND sto.item_number LIKE '%'
    AND sto.status LIKE '%'
    AND (
            ('%' = 'NULL' AND sto.lot_number IS NULL)
         OR ('%' = 'NOT NULL' AND sto.lot_number IS NOT NULL)
         OR ('%' = '%')
        )
    AND sto.type = 'STORAGE'
    AND ISNULL(loc.building, '') LIKE '%'
    AND itm.pick_put_id LIKE '%'
    AND itm.commodity_code Like 'Z%' and itm.commodity_code NOT Like '%K'

ORDER BY 
    sto.item_number,
    sto.location_id;