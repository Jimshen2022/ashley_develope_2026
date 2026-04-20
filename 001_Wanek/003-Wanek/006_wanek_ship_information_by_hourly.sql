DECLARE @start_date date = '2025-01-01';
DECLARE @end_date   date = '2025-11-01';  
DECLARE @tran_type  varchar(10) = '361';


    SELECT 
        tl.wh_id,
        tl.routing_code,
        tl.control_number_2 as trip_nbr,
        -- ✅ 用 DATEADD 和 DATEDIFF 拼接日期 + 时间，避免类型冲突
        dt = max(CAST(tl.start_tran_date AS datetime) + CAST(tl.start_tran_time AS datetime)),
        sum(tl.tran_qty) AS trip_qty,
        count(distinct tl.item_number) AS sku_count
    FROM Distribution_Warehouse_Wholesale.TranLog AS tl
    WHERE tl.start_tran_date >= @start_date
      AND tl.start_tran_date <  @end_date
      AND tl.wh_id IN ('31', '33', '34', '35')
      and tl.tran_type = @tran_type
    GROUP BY 
        tl.wh_id,
        tl.routing_code,
        tl.control_number_2

