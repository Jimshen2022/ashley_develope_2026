
select t.*,CAST(
        CAST(t.start_tran_date AS datetime) +
        CAST(CONVERT(time, t.start_tran_time) AS datetime)
        AS datetime
    ) AS start_datetime   
from Distribution_Warehouse_Wholesale.TranLog as t
where t.wh_id in ('35','33','31')
  and t.start_tran_date >= '2025-01-01'
  and t.tran_type in ('362')
  and t.wh_id_2 in ('C','CNW','IOR','AF')
  and t.control_number = '2Q3F30'

