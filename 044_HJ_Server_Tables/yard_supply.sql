select top 10 * from t_trailer


SELECT
    trl.equipment_id AS container_number,
    ad.item_number,
    ad.qty AS unreceived_qty,
    trl.entered_yard AS check_into_yard_time
FROM t_trailer trl WITH (NOLOCK)
JOIN t_trailer_asn tasn WITH (NOLOCK)
    ON trl.trailer_id = tasn.trailer_id
    AND trl.wh_id = tasn.wh_id
JOIN t_asn a WITH (NOLOCK)
    ON tasn.asn_id = a.asn_id
    AND tasn.wh_id = a.wh_id
JOIN t_asn_detail ad WITH (NOLOCK)
    ON a.asn_id = ad.asn_id
    AND a.wh_id = ad.wh_id
WHERE trl.wh_id = '335'  -- Ashton
  AND trl.status = 'IN YARD'
  AND a.status NOT IN ('RECEIVED', 'CANCELLED')
ORDER BY trl.entered_yard;