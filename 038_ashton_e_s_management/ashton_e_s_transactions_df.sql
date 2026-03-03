
  
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
		AND podMfrName IS NOT NULL
		AND LTRIM(RTRIM(podMfrName)) <> ''
	GROUP BY 
		[podwarehouse],
		[podordernum],
		[podvendornum],
		[podMfrName],
		[podMfrCountry],
		[podstatuscode],
		[podduedate]
),
sn_po AS (
	SELECT 
		t1.lot_number,
		t1.item_number,
		po.po_number,
		t1.wh_id,
		cy.[podvendornum],
		cy.[podMfrName],
		cy.[podMfrCountry],
		cy.[podstatuscode],
		cy.[podduedate],
		MIN(t1.start_tran_date) as start_tran_date
	FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
	CROSS APPLY (
		SELECT 
			CASE 
				WHEN t1.control_number_2 NOT LIKE 'P%' THEN t1.control_number
				ELSE t1.control_number_2 
			END AS po_number
	) AS po
	LEFT JOIN cy ON cy.[podordernum] = po.po_number
	WHERE 
		t1.wh_id = '335'
		AND (
			(LEN(t1.control_number_2) >= 4 AND t1.control_number_2 LIKE 'P%')
			OR (LEN(t1.control_number) >= 4 AND t1.control_number LIKE 'P%')
		)
		AND t1.lot_number IS NOT NULL
	GROUP BY
		t1.lot_number,
		t1.item_number,
		po.po_number,
		t1.wh_id,
		cy.[podvendornum],
		cy.[podMfrName],
		cy.[podMfrCountry],
		cy.[podstatuscode],
		cy.[podduedate]
)
SELECT 
	t1.start_tran_date,
	t1.tran_type,
	t1.description,
	t1.employee_id,
	t1.location_id_2,
	t1.wh_id,
	t1.location_id,
	t1.item_number,
	t1.lot_number,
	t1.tran_qty,
	sp.po_number,
	sp.[podvendornum],
	sp.[podMfrName],
	sp.[podMfrCountry],
	sp.[podstatuscode],
	sp.[podduedate]
FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
LEFT JOIN sn_po AS sp ON sp.lot_number = t1.lot_number
WHERE t1.tran_type IN ('202','152') 
	AND t1.wh_id = '335'
	AND t1.start_tran_date BETWEEN '2024-01-01' AND GETDATE()
	AND t1.location_id_2 IN ('EX001AA1','SH001AA1','EX001AA2') 
	AND sp.[podvendornum] IS NOT NULL
ORDER BY t1.start_tran_date;
  
  