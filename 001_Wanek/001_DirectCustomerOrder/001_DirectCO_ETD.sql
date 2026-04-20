WITH etd AS (
SELECT 
	t.FBA3CD as wh_id,
	t.FBCVNB as co_nbr,
	t.FBCANB as customer_nbr,
	t.FBACDT as co_order_date,
	t.FBALDT as creation_date,
	t.FBAMDT as last_change_date,
	t.FBD0NB as co_request_date,
	t.FBB9CD as destination,
	t.FBDAVA as co_value,
	t.FBFGVA as invoice_amount,
	t.FBAOQT as co_cubes,
	t.FBAAQT as co_weight,
	t.FBFNST as co_status
FROM AMFLIBW.MBFBREP t
WHERE t.FBA3CD in ('35','33','31')

UNION ALL

SELECT 
	t.C6A3CD as wh_id,  --okay
	t.C6CVNB as co_nbr, --okay
	t.C6CANB as customer_nbr, --okay
	t.C6ACDT as co_order_date, --okay
	t.C6ALDT as creation_date, --okay
	t.C6AMDT as last_change_date, --okay
	t.C6D0NB as co_request_date, --okay
	t.C6B9CD as destination, --okay
	t.C6DCVA as co_value, --okay
	t.C6FGVA as invoice_amount,
	t.C6AOQT as co_cubes, --okay
	t.C6AAQT as co_weight, --okay
	t.C6FNST as co_status --okay
FROM AMFLIBW.MBC6REP as t
WHERE t.C6A3CD in ('35','33','31')
)

