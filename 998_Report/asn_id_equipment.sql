WITH asn_dtl as (
	SELECT *
	FROM Distribution_Warehouse_Wholesale.ASN_Detail AS t
	WHERE t.wh_id = '335'
),
tailer_asn AS  (
	SELECT t.AsnId,
		t.TrailerId,
		t.EquipmentId
	FROM Distribution_Warehouse_Wholesale.t_trailer_asn as t
	WHERE t.Wh_id = '335'
),
asn as (
	SELECT
            t.wh_id,
            t.asn_id,
            t.asn_number,
            t.vendor_id,
            t.carrier_id,
            t.expected_arrival,
            t.shipped,
            t.total_quantity,
            t.total_weight,
            t.total_volume,
            t.equipment_id,
            t.trailer_type_name,
            t.status
	FROM Distribution_Warehouse_Wholesale.t_asn AS t
	WHERE t.wh_id = '335'
		and t.status = 'CLOSED'
		and t.shipped > dateadd(day, -360, GETDATE())
)
SELECT  t1.wh_id,
	t1.asn_id,
	t1.asn_number,
	t1.vendor_id,
	t1.carrier_id,
	t1.expected_arrival,
	t1.shipped,
	t1.total_quantity,
	t1.total_weight,
	t1.total_volume,
	t1.equipment_id,
	t1.trailer_type_name,
	t1.status,
	t2.customer_po_number,
	t3.EquipmentId,
	t2.*
FROM asn as t1
LEFT JOIN asn_dtl as t2 ON t2.asn_id = t1.asn_id
LEFT JOIN tailer_asn as t3 ON t3.AsnId = t1.asn_id
