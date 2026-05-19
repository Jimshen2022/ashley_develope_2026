WITH itm AS (
    SELECT ITNBR, ITDSC
    FROM MasterData_ItemMaster_AFI.ITMRVA
    WHERE STID = '335' 
),
cy AS (
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
	t1.wh_id, 
	t1.item_number, 
	t1.location_id, 
	t1.po_number,
	t1.serial_no_status,
	t1.received_date,
	-- 计算 Pending Days
	DATEDIFF(DAY, t1.received_date, GETDATE()) AS pending_days,
	-- 按天数划分区间
	CASE 
		WHEN DATEDIFF(DAY, t1.received_date, GETDATE()) <= 7 THEN '(a) 0-7 days'
		WHEN DATEDIFF(DAY, t1.received_date, GETDATE()) BETWEEN 8 AND 30 THEN '(b) 8-30 days'
		WHEN DATEDIFF(DAY, t1.received_date, GETDATE()) BETWEEN 31 AND 90 THEN '(c) 31-90 days'
		ELSE '(d) 90+ days'
	END AS pending_range,
	sy.[podvendornum],
    sy.[podMfrName],
    sy.[podMfrCountry],
    sy.[podstatuscode],
	t1.serial_number,
	sy.po_number,
	i.ITDSC
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
LEFT JOIN sn_po as sy on sy.lot_number = t1.serial_number
LEFT JOIN itm as i on t1.item_number = i.ITNBR
WHERE t1.wh_id IN ('335') 
	--AND t1.serial_no_status NOT IN ('O') 
	--AND t1.master_status NOT IN ('S')
	AND (t1.location_id like 'NG%' OR t1.location_id like 'DM%' OR t1.location_id like 'SH00%' OR t1.location_id like 'EX%')
	AND t1.location_id NOT like 'NG%OP%'
