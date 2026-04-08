
SELECT TOP 10 * FROM  Distribution_Warehouse_Wholesale.t_stored_item as t

SELECT
        sto.item_number,
        sto.actual_qty,
        sto.status,
        sto.wh_id,
        sto.location_id,
        loc.TypeDescription,
        sto.type
    FROM Distribution_Warehouse_Wholesale.t_stored_item sto
    JOIN Distribution_Warehouse_Wholesale.t_location loc
        ON sto.location_id = loc.location_id
        AND sto.wh_id = loc.wh_id
    JOIN Distribution_Warehouse_Wholesale.t_item_master itm
        ON sto.item_number = itm.item_number
        AND sto.wh_id = itm.wh_id
    WHERE
        sto.wh_id = '335'
--         AND loc.TypeDescription IN ('I', 'M', 'P', 'X', 'S', 'D', 'V')
--         AND sto.status = 'A'
-- 		AND sto.item_number = 'R80121'