--select *
--from t_order_detail_breakdown AS obd
--where obd.order_number like '%41199%'
--  and obd.item_number = 'A2000679'

--select *
--FROM t_tran_log AS t
--where t.control_number_2 like '%41199%'
--  and t.tran_type = '347'
--  and t.item_number = 'A2000679'


with od AS (
    select 
        LEFT(obd.order_number, 7)  as trip_number,
        obd.item_number,
        obd.c_number,
        sum(obd.qty) as qty
    from t_order_detail_breakdown as obd
    group by 
        LEFT(obd.order_number, 7),
        obd.item_number,
        obd.c_number
),
sa as (
SELECT 
    LEFT(t.control_number_2, 7) AS trip_number,
    t.item_number, 
    SUM(t.tran_qty) AS trip_sa_qty, 
    MAX(t.end_tran_date + t.end_tran_time) AS last_tran_datetime
FROM t_tran_log AS t
WHERE t.tran_type = '347'
    AND (t.end_tran_date + t.end_tran_time) >= DATEADD(DAY, -15, GETDATE())  
GROUP BY LEFT(t.control_number_2, 7), t.item_number
)
select sa.*, od.*
from sa
left join od
    on sa.trip_number = od.trip_number
    and sa.item_number = od.item_number
order by sa.trip_number, sa.item_number