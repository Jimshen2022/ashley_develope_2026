WITH WA AS (
    SELECT *, 
        SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2
    FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t
    WHERE t.imported > DATEADD(DAY, -120, GETDATE())
        AND t.transaction_string LIKE 'L%' 
        AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <> '00'
),
sub_trip_imported AS (
    SELECT  
        *, 
        CAST(LEFT(trip_nbr_2, 7) AS INT) AS trip_nbr
    FROM WA
    --WHERE trip_nbr_2 LIKE '%46064%'
),
tran_with_datetime AS (
    SELECT 
        t1.tran_type,
        t1.description,
        t1.employee_id,
        t1.control_number_2,
        t1.start_tran_date,
		CONVERT(VARCHAR(8), t1.start_tran_time, 108) AS start_tran_time,
        t1.tran_qty,
        CAST(CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS DATETIME) AS start_tran_datetime
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id = '335'
        AND t1.start_tran_date > DATEADD(DAY, -90, GETDATE())
        AND t1.tran_type IN ('350')
	--	AND t1.control_number_2 LIKE '%46064%'
),
ranked_tran AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY tran_type, description, control_number_2
            ORDER BY start_tran_datetime
        ) AS rn
    FROM tran_with_datetime
),
fill as (
SELECT 
    tran_type,
    description,
    employee_id,
    control_number_2,
    start_tran_date,
    start_tran_time,
    start_tran_datetime,
    tran_qty	
FROM ranked_tran as a
WHERE rn = 1
)
SELECT t0.*,
	b.imported,
	--CONVERT(VARCHAR(10),b.imported,120) + ' ' + CONVERT(VARCHAR(8),b.imported,108)  as imported_into_HJ_time,
	b.trip_nbr,
	b.trip_nbr_2
FROM fill as t0
LEFT JOIN sub_trip_imported as b ON CAST(LEFT(t0.control_number_2,7) AS INT) = b.trip_nbr
WHERE b.trip_nbr_2 IS NOT NULL
ORDER BY b.trip_nbr_2