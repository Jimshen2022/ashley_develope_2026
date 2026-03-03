DECLARE @N INT = 60;  -- 设定天数，1=今天，2=昨天+今天，7=最近7天

With st as (
    select a.wh_id,
        a.serial_number, 
        a.item_number, 
        a.po_number, 
        a.location_id, 
        a.received_date,
          CASE
               WHEN a.item_number ='RP ORDER' and a.location_id = 'Shipped' then 'Shipped'
               WHEN a.serial_no_status = 'H' THEN 'Hold'
               WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
               WHEN a.serial_no_status = 'L' THEN 'Loaded'
               WHEN a.serial_no_status = 'S' THEN 'Shipped'
               WHEN a.serial_no_status = 'O' THEN 'Orphaned'
               ELSE 'Shipped'
             END AS serial_no_status
    from t_serial_active as a
    where a.wh_id = '335'
        
)
SELECT 
    t.wh_id,
    t.tran_type,
    t.description,
    t.exception_date,
    t.location_id as exception_loc,
    CAST(t.exception_date AS DATE) AS ExceptionDateOnly,  -- 新增：只保留日期部分
    t.item_number,
    t.class_id,
    t.lot_number,
    case 
        when s.serial_no_status is null then 'Shipped'
        when s.location_id = 'NG001OP3' then 'Moved to NG001OP3'
        else s.serial_no_status end as current_sn_status,
    s.location_id as current_sn_loc,
    t.mo_number,
    t.employee_id,
    MAX(t.exception_date) OVER() AS LatestRecord           -- 新增列：最大时间（含时分秒）
FROM t_exception_tran_log AS t
left join st as s on s.serial_number = t.lot_number
WHERE t.exception_date >= DATEADD(DAY, -(@N - 1), CAST(GETDATE() AS DATE)) 
  AND t.exception_date < DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) 
  AND t.tran_type = '99G'
  AND t.location_id NOT IN ('NG001OP3')
  --AND case 
  --      when s.serial_no_status is null then 'Shipped'
  --      when s.location_id = 'NG001OP3' then 'Moved to NG001OP3'
  --      else s.serial_no_status end <> 'Moved to NG001OP3'
ORDER BY t.exception_date;
