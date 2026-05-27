

select top 1000 * from t_tran_log where tran_type like '363'

SELECT 
    CAST(start_tran_date AS DATE) AS tran_date,
    DATEPART(HOUR, start_tran_time) AS tran_hour,
    COUNT(DISTINCT item_number) AS sku_count
FROM t_tran_log
WHERE tran_type LIKE '363' 
GROUP BY 
    CAST(start_tran_date AS DATE),
    DATEPART(HOUR, start_tran_time)
ORDER BY 
    tran_date,
    tran_hour