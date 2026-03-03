WITH fill_trips AS
(
SELECT DISTINCT(LEFT(t1.control_number_2,7)*1) AS trip_nbr
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.start_tran_date > '2025-01-01'
  AND t1.tran_type IN ('347')
  AND t1.control_number_2 not like '%-00'
),
i as (
    SELECT 
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    WHERE t0.STID = '335' 
)
SELECT
	t1.start_tran_date,
	t1.tran_type,
	t1.description,
	t1.start_tran_date,
	t1.control_number_2,
	left(t1.control_number_2,7)*1 as trip_nbr,
	t1.item_number,
	ROW_NUMBER() OVER (
					PARTITION BY CAST(LEFT(t1.control_number_2,7) AS INT) ORDER BY CAST(LEFT(t1.control_number_2,7) AS INT)
					) AS rn,
	CASE WHEN ROW_NUMBER() OVER (PARTITION BY CAST(LEFT(t1.control_number_2,7) AS INT) ORDER BY CAST(LEFT(t1.control_number_2,7) AS INT)) = 1 THEN 1 ELSE 0 END AS trips_count, 
	case 
		when 
				CASE 
					WHEN  t1.control_number_2 like '%-00'  THEN
						0
					ELSE 
						ROW_NUMBER() OVER (PARTITION BY t1.control_number_2 ORDER BY t1.control_number_2)  
					END =1 then 1 ELSE 0 END AS sub_trips_count,

	CASE 
		WHEN t1.control_number_2 not like '%-00' THEN 'sub-trip'
		else 'main_trip' end as trip_type,
	sum(t1.tran_qty) as tran_qty,
	sum(t1.tran_qty) * i.B2Z95S as Cubes
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i on i.ITNBR = t1.item_number
WHERE t1.wh_id = '335'
  AND t1.start_tran_date > '2025-01-01'
  AND t1.tran_type IN ('347')
  AND EXISTS 
	(SELECT 1 FROM fill_trips as t2 where left(t1.control_number_2,7)*1 = t2.trip_nbr)  
GROUP BY 	
    t1.start_tran_date,
	t1.tran_type,
	t1.description,
	t1.start_tran_date,
	t1.control_number_2,
	left(t1.control_number_2,7)*1,
	t1.item_number,
	i.B2Z95S,
	CASE 
		WHEN t1.control_number_2 not like '%-00' THEN 'sub-trip'
		else 'main_trip' end
ORDER BY left(t1.control_number_2,7)*1, t1.start_tran_date