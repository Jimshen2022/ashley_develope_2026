with ord AS (
    select 
        wh_id, 
        order_number, 
        customer_id
    from t_order 
),
trx as (
    select 
        t_tran_log.wh_id, 
        t_tran_log.item_number,
        tran_type,
        control_number,
        ord.customer_id,
        
        -- Shift Date 计算
        CASE 
            WHEN DATEPART(HOUR, start_tran_time) < 7 THEN DATEADD(DAY, -1, start_tran_date)
            ELSE start_tran_date 
        END AS shift_date,

        -- Shift 计算
        CASE 
            WHEN DATEPART(HOUR, start_tran_time) >= 7 AND DATEPART(HOUR, start_tran_time) < 19 THEN 'D'
            ELSE 'N' 
        END AS shift,
        
        sum(tran_qty) AS total_qty -- [修复3] 增加别名
        
    from t_tran_log 
    left join ord on ord.wh_id = t_tran_log.wh_id 
                  and ord.order_number = t_tran_log.control_number
    where tran_type in ('374', '368')
    group by 
        t_tran_log.wh_id, -- [修复2] Group By 也要明确表名
        t_tran_log.item_number,
        tran_type,
        control_number,
        ord.customer_id,
        -- Group By 中的计算逻辑必须完全一致
        CASE 
            WHEN DATEPART(HOUR, start_tran_time) < 7 THEN DATEADD(DAY, -1, start_tran_date)
            ELSE start_tran_date 
        END,
        CASE 
            WHEN DATEPART(HOUR, start_tran_time) >= 7 AND DATEPART(HOUR, start_tran_time) < 19 THEN 'D'
            ELSE 'N' 
        END
)
select *
from trx
where customer_id = '335'
order by shift_date;