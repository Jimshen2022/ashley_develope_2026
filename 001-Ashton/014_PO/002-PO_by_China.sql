With mfrcountry as (
    SELECT
        [podwarehouse],
        [podordernum],
        [podvendornum],
        [podMfrName],
        [podMfrCountry],
        [poditemnum],
        [podqtyordered],
        [podstatuscode],
        [podduedate],
        [podcurrentprice],
        [podcubes],
        [podweight]
    FROM [Wholesale_ProductSourcing_AFI].[PoDetail]
    WHERE
        podwarehouse = '335'
    --     AND podstatuscode NOT IN ('10','20','30')
        AND podduedate > '2021-01-01'
        AND podMfrName IS NOT NULL
        AND LTRIM(RTRIM(podMfrName)) <> ''
         ),
sto as (
    SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id in ('335') AND  t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S')
    and t1.item_number != 'RP ORDER'
)
-- Main Quary ---
SELECT t1.wh_id,
       t1.item_number,
       t1.location_id,
       t1.serial_number,
       t1.po_number,
       t1.serial_no_status,
       t1.master_status,
       t1.received_date,
       t2.podvendornum,
       t2.podMfrName,
       t2.podMfrCountry,
       t2.podstatuscode,
       t2.podduedate
FROM sto  AS t1
LEFT JOIN mfrcountry as t2 ON t1.item_number = t2.poditemnum AND t1.po_number = t2.podordernum



