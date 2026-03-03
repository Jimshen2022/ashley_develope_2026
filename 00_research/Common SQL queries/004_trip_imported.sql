WITH WA AS (
    SELECT *, 
        SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2
    FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t
    WHERE t.imported > '2025-09-13' 
        AND t.transaction_string LIKE 'L%' 
        AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <> '00'
),
sub_trip_imported AS (
    SELECT  
        *, 
        CAST(LEFT(trip_nbr_2, 7) AS INT) AS trip_nbr
    FROM WA
    WHERE trip_nbr_2 LIKE '%46064%'
)
SELECT 
    t1.tran_type,
    t1.description,
    t1.employee_id,
    t1.control_number_2,
    CAST(LEFT(t1.control_number_2, 7) AS INT) AS trip_nbr,
    t1.start_tran_date,
	CONVERT(VARCHAR(8), t1.start_tran_time, 108) AS start_tran_time,
    t1.tran_qty,
    CAST(CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS DATETIME) AS start_tran_datetime,


FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN sub_trip_imported AS t2 
    ON CAST(LEFT(t1.control_number_2, 7) AS INT) = t2.trip_nbr
WHERE t1.wh_id = '335'
    AND t1.start_tran_date > '2025-01-01'
    AND t1.tran_type IN ('350')
    AND t1.control_number_2 LIKE '%46064%'