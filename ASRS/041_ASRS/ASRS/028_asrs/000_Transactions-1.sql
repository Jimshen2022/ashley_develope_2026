WITH itm AS
(SELECT
     a.item_number
    ,a.description
    ,a.uom
    ,a.inventory_type
    ,a.commodity_code
    ,a.wh_id
    ,a.class_id
    ,a.unit_weight
    ,a.unit_volume
    ,a.nested_volume
    ,a.pick_put_id
    ,a.pallet_id
    ,a.std_hand_qty
    ,CASE
        WHEN a.pick_put_id =  'UPH' THEN 'UPH'  -- RP
        ELSE 'CG'
    END AS product
FROM Distribution_Warehouse_Wholesale.t_item_master AS a
WHERE a.wh_id = '335'
)
SELECT
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    itm.product,
    itm.pallet_id,
    SUM(t3.tran_qty) AS qty
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN itm ON itm.item_number = t3.item_number
WHERE t3.wh_id in ('335')
    AND t3.tran_type = '347'
    AND t3.start_tran_date >= CAST(GETDATE() - 91 AS DATE) -- 最近3周
    AND t3.start_tran_date <= CAST(GETDATE() AS DATE)
GROUP BY
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    itm.product,
    itm.pallet_id
ORDER BY
    t3.wh_id,
    t3.item_number,
    t3.start_tran_date


