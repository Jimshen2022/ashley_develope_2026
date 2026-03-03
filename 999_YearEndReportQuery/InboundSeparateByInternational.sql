-- Asthon inbound received by container and seperated by customers' country on Nov.24.2024 by Jim,Shen
WITH vd as (
SELECT a1.pomordernum, a1.pomvendornum, v0.VendorName,
       v0.Country, v0.[Vendor Import Domestic Flag]
FROM (SELECT a0.pomordernum, a0.pomvendornum, a0.pomcontainer
      FROM Wholesale_ProductSourcing_AFI.PoMaster AS a0
    WHERE a0.pomwarehouse = '335') as a1
LEFT JOIN PowerBI_SupplyChain.VendorMaster as v0 ON v0.VendorNumber = a1.pomvendornum
),
trx AS
(
SELECT
	t1.[start_tran_date],
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00') AS YearWeek,
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]) AS YearMonth,
	t1.item_number,
	t1.tran_type,
	t1.description,
	t1.control_number,
	t1.control_number_2,
	t1.hu_id_2,
	v6.pomvendornum,
	v6.VendorName,
	v6.Country,
	CASE
	    WHEN v6.pomvendornum IN ('900515','900639','600039') THEN 'WNK'
	    WHEN v6.pomvendornum IN ('624556','641068') THEN 'MIL'
	    WHEN v6.Country = 'VN' THEN 'Local'
	    WHEN V6.pomvendornum IN ('655613') THEN 'Local'
        ELSE 'International' END as 'Import_Type',
	ROW_NUMBER() OVER (PARTITION BY t1.control_number, t1.hu_id_2
                           ORDER BY t1.start_tran_date) AS row_num_receiving,
	SUM(CASE
		WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty
		WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE 0 END) AS Received_Qty
FROM (select * from Distribution_Warehouse_Wholesale.TranLog as t
               where t.wh_id IN ('335')
               -- and t.start_tran_date between '2024-05-24' AND '2024-12-24'
               and t.start_tran_date between DATEADD(month, -6, GETDATE()) AND GETDATE()
	  AND t.tran_type IN ('151', '183', '951'))  AS t1
LEFT JOIN vd AS v6 on v6.pomordernum = t1.control_number_2
GROUP BY
	t1.[start_tran_date],
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00'),
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]),
	t1.item_number,
	t1.tran_type,
	t1.description,
	t1.control_number,
	t1.control_number_2,
	t1.hu_id_2,
	v6.pomvendornum,
	v6.VendorName,
	v6.Country,
	CASE
	    WHEN v6.pomvendornum IN ('900515','900639','600039') THEN 'WNK'
	    WHEN v6.pomvendornum IN ('624556','641068') THEN 'MIL'
	    WHEN v6.Country = 'VN' THEN 'Local'
	    WHEN V6.pomvendornum IN ('655613') THEN 'Local'
        ELSE 'International' END
-- ORDER BY DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]);
)
SELECT  a1.YearMonth,
        a1.Import_Type
	, SUM(a1.Received_Qty) as Received_Qty
	, SUM(CASE WHEN a1.tran_type IN ('151','951','183') AND a1.row_num_receiving = 1 THEN 1 ELSE 0 END) AS Received_Containers_Qty
FROM trx as a1
GROUP BY a1.YearMonth, a1.Import_Type
ORDER BY a1.YearMonth


