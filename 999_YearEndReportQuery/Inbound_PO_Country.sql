    WITH cy AS (
	SELECT
        [podwarehouse],
        [podordernum],
        [podvendornum],
        [podMfrName],
        [podMfrCountry],
        [podstatuscode],
        [podduedate],
        SUM([podqtyordered]) AS qtyordered
    FROM [Wholesale_ProductSourcing_AFI].[PoDetail]
    WHERE
        podwarehouse = '335'
    --     AND podstatuscode NOT IN ('10','20','30')
        AND podduedate > '2021-01-01'
        AND podMfrName IS NOT NULL
        AND LTRIM(RTRIM(podMfrName)) <> ''
	GROUP BY [podwarehouse],
        [podordernum],
        [podvendornum],
        [podMfrName],
        [podMfrCountry],
        [podstatuscode],
        [podduedate]
		)
SELECT t1.wh_id, 
	t1.item_number, 
	t1.location_id, 
	t1.po_number,
	t1.serial_no_status,
	cy.[podvendornum],
    cy.[podMfrName],
    cy.[podMfrCountry],
    cy.[podstatuscode],
	COUNT(t1.serial_number) AS Racking_Qty
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
LEFT JOIN cy on cy.[podordernum] = t1.po_number
WHERE t1.wh_id IN ('335') 
	AND t1.serial_no_status NOT IN ('O') 
	AND t1.master_status NOT IN ('S')
	AND t1.location_id in ('SH001AA1','EX001AA1')
GROUP BY t1.wh_id, 
	t1.item_number, 
	t1.location_id, 
	t1.po_number,
	t1.serial_no_status,
	cy.[podvendornum],
    cy.[podMfrName],
    cy.[podMfrCountry],
    cy.[podstatuscode]

