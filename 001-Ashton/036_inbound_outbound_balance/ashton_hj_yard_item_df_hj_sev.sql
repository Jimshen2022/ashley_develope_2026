WITH
tmp_RP_item_order AS (
    SELECT DISTINCT d.item_number, 'RP' AS item_type
    FROM dbo.t_order o WITH (NOLOCK)
    JOIN dbo.t_order_detail d WITH (NOLOCK)
      ON o.order_number = d.order_number
     AND o.wh_id        = d.wh_id
    WHERE o.type_id = '1159'
),
main_query AS (
    SELECT DISTINCT
        t.equipment_id,
        t.state,
        l.location_name,
        t_ya_work_q.zone,
        asn.disposition,
        d.customer_po_number,
        p.vendor_code,
        t.entered_yard,
        CASE WHEN l.[type] = 'DRAYAGE' THEN NULL ELSE 'Go To' END AS disposition_unit,
        asn.asn_number,
        d.item_number,

        SUM(d.quantity_shipped)  AS Qty_shipped,
        SUM(d.quantity_received) AS Qty_received,
        SUM(d.quantity_shipped) - SUM(d.quantity_received) AS Qty_remaining,

        -- 为保持与原导出一致
        SUM(d.quantity_received)                         AS Qty_rec,
        SUM(d.quantity_shipped) - SUM(d.quantity_received) AS Qty_rem,

        asn.trailer_type_name,
        tc.comments,

        CASE
            WHEN ((ita.inventory_type IN ('FG','RM') AND ita.commodity_code IN ('LA','TA'))
                  OR rpi.item_type = 'RP')
            THEN 'RP' ELSE 'OTHERS'
        END AS Item_Type
    FROM dbo.t_trailer t WITH (NOLOCK)
    LEFT JOIN dbo.t_trailer_asn trl WITH (NOLOCK)
           ON t.trailer_id = trl.trailer_id
    LEFT JOIN dbo.t_asn asn WITH (NOLOCK)
           ON trl.asn_id = asn.asn_id
          AND asn.equipment_id = t.equipment_id
    LEFT JOIN dbo.t_ya_work_q WITH (NOLOCK)
           ON t.trailer_id = t_ya_work_q.trailer_id
          AND t_ya_work_q.status = 'UNASSIGNED'
          AND t_ya_work_q.type   = '52'
    LEFT JOIN (
        SELECT t2.trailer_id, tc1.comments
        FROM dbo.t_trailer_comments tc1 WITH (NOLOCK)
        INNER JOIN (
            SELECT trailer_id, MAX(sequence) AS maxsequence
            FROM dbo.t_trailer_comments WITH (NOLOCK)
            GROUP BY trailer_id
        ) t2
          ON tc1.trailer_id = t2.trailer_id
         AND tc1.sequence   = t2.maxsequence
    ) tc
      ON t.trailer_id = tc.trailer_id
    JOIN dbo.t_asn_detail d WITH (NOLOCK)
      ON asn.asn_id = d.asn_id
    JOIN dbo.t_ya_location l WITH (NOLOCK)
      ON t.location_id = l.location_id
    JOIN dbo.t_area a WITH (NOLOCK)
      ON t.area_id = a.area_id
    JOIN dbo.t_po_master p WITH (NOLOCK)
      ON d.customer_po_number = p.po_number
    LEFT JOIN dbo.t_item_uom uom WITH (NOLOCK)
      ON uom.item_number = d.item_number
     AND uom.default_receipt_uom = 'YES'
    LEFT JOIN dbo.t_item_master itm WITH (NOLOCK)
      ON d.item_number = itm.item_number
    LEFT JOIN dbo.t_item_attributes ita WITH (NOLOCK)
      ON d.item_number = ita.item_number
    LEFT JOIN tmp_RP_item_order rpi
      ON d.item_number = rpi.item_number
    WHERE t.status NOT IN ('HISTORY','LOST')
    GROUP BY
        t.equipment_id, t.state, l.location_name, t_ya_work_q.zone, asn.disposition,
        d.customer_po_number, p.vendor_code, t.entered_yard, asn.asn_number, d.item_number,
        asn.trailer_type_name, tc.comments, l.[type],
        ita.inventory_type, ita.commodity_code, rpi.item_type
)
SELECT
    m.equipment_id        AS [Equipment Id],
    m.state               AS [State],
    m.location_name       AS [Location],
    m.zone                AS [Zone],
    m.disposition         AS [Disposition],
    m.customer_po_number  AS [PO#],
    m.vendor_code         AS [Vendor#],
    m.entered_yard        AS [Entered Yard],
    m.disposition_unit    AS [Schedule to Door],
    m.asn_number          AS [ASN Number],
    m.item_number         AS [Item Number],
    m.Qty_shipped         AS [Qty Shipped],
    m.Qty_received        AS [Qty Received],
    m.Qty_remaining       AS [Qty Remaining],
    m.Qty_rec             AS [Qty Rec],
    m.Qty_rem             AS [Qty Rem],
    m.trailer_type_name   AS [Trailer Type],
    m.comments            AS [Comments]
FROM main_query AS m
--WHERE m.Item_Type = 'RP'          -- 只要 RP
ORDER BY m.entered_yard;