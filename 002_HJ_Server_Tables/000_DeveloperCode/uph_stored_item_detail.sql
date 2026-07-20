/*
UPH stored-item detail rows behind the balance report.

Rules:
- item scope: dbo.t_item_master.pick_put_id = @pick_put_id
- include rows that feed sto_qty or shipping_stage_qty
- sto_qty source = type = 'STORAGE', excluding location_id LIKE 'EX%', 'SH%', 'NG%', and 'DM%'
- shipping stage source = location_id starts with S or D, excluding exception locations EX%, SH%, NG%, and DM%
- exception locations are not counted as shippable inventory or shipping stage
*/

DECLARE @wh_id VARCHAR(10) = '335';
DECLARE @pick_put_id VARCHAR(15) = 'UPH';

SELECT
    sto.wh_id,
    sto.item_number,
    itm.description,
    itm.pick_put_id,
    itm.class_id,
    sto.location_id,
    CASE
        WHEN sto.type = 'STORAGE'
         AND sto.location_id NOT LIKE 'EX%'
         AND sto.location_id NOT LIKE 'SH%'
         AND sto.location_id NOT LIKE 'NG%'
         AND sto.location_id NOT LIKE 'DM%' THEN 'Y'
        ELSE 'N'
    END AS is_sto_qty_source,
    CASE
        WHEN (sto.location_id LIKE 'S%' OR sto.location_id LIKE 'D%')
         AND sto.location_id NOT LIKE 'EX%'
         AND sto.location_id NOT LIKE 'SH%'
         AND sto.location_id NOT LIKE 'NG%'
         AND sto.location_id NOT LIKE 'DM%' THEN 'Y'
        ELSE 'N'
    END AS is_shipping_stage,
    sto.actual_qty,
    sto.unavailable_qty,
    sto.status,
    sto.type,
    sto.fifo_date,
    sto.expiration_date,
    sto.reserved_for,
    sto.lot_number,
    sto.serial_number,
    sto.put_away_location,
    sto.owner_id,
    sto.pod_status,
    sto.mapics_batch_lot,
    sto.po_number,
    sto.country_code,
    sto.position,
    sto.sequence
FROM dbo.t_stored_item sto WITH (NOLOCK)
INNER JOIN dbo.t_item_master itm WITH (NOLOCK)
    ON itm.wh_id = sto.wh_id
   AND itm.item_number = sto.item_number
WHERE sto.wh_id = @wh_id
  AND itm.pick_put_id = @pick_put_id
  AND sto.status = 'A'
  AND sto.actual_qty > 0
  AND (
        (
            sto.type = 'STORAGE'
        AND sto.location_id NOT LIKE 'EX%'
        AND sto.location_id NOT LIKE 'SH%'
        AND sto.location_id NOT LIKE 'NG%'
        AND sto.location_id NOT LIKE 'DM%'
        )
     OR (
            (sto.location_id LIKE 'S%' OR sto.location_id LIKE 'D%')
        AND sto.location_id NOT LIKE 'EX%'
        AND sto.location_id NOT LIKE 'SH%'
        AND sto.location_id NOT LIKE 'NG%'
        AND sto.location_id NOT LIKE 'DM%'
        )
  )
ORDER BY
    sto.item_number,
    sto.location_id,
    sto.lot_number,
    sto.serial_number,
    sto.sequence;



