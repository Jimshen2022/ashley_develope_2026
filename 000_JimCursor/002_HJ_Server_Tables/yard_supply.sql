select top 10 * from t_trailer
select top 10 * from t_trailer_asn
select top 10 * from t_asn
select DISTINCT status from t_asn
select top 10 * from t_asn_detail


SELECT
    trl.equipment_id AS container_number,
    ad.item_number,
    ad.quantity_shipped - ad.quantity_received AS unreceived_qty,
    trl.entered_yard AS check_into_yard_time
FROM t_trailer trl WITH (NOLOCK)
JOIN t_trailer_asn tasn WITH (NOLOCK)
    ON trl.trailer_id = tasn.trailer_id
JOIN t_asn a WITH (NOLOCK)
    ON tasn.asn_id = a.asn_id
JOIN t_asn_detail ad WITH (NOLOCK)
    ON a.asn_id = ad.asn_id
WHERE
--trl.status = 'IN YARD'
   a.status IN ('CHECKED IN')
ORDER BY trl.entered_yard;