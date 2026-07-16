-- FLOOR inventory age

with itm as 
(select item_number, class_id
 from t_item_master 
 where wh_id = '335' and class_id in ('FLOOR')
 group by item_number, class_id
 ),
 coo as (
 select wh_id, item_number, serial_number,  serial_no_status, country_code,
         CASE
            WHEN country_code IS NULL THEN 'vietnam local vendor'
            WHEN country_code COLLATE DATABASE_DEFAULT IN ('VN', 'VNM', 'VIETNAM', 'VIET NAM') THEN 'vietnam local vendor'
            ELSE 'international vendor'
        END AS vendor_coo
 from t_serial_master 
 where wh_id = '335' and serial_no_status not in ('S','O') 
 group by wh_id, item_number, serial_number,  serial_no_status, country_code
 
 ),
 sn_oh as (
 select s.item_number,s.serial_number, 1 as qty, s.serial_no_status, s.location_id, coo.vendor_coo
 from t_serial_active as s 
 left join coo on s.wh_id = coo.wh_id and s.item_number = coo.item_number and s.serial_number = coo.serial_number
 where s.serial_no_status not in ('S','O') and s.wh_id = '335' and s.item_number in (select item_number from itm) 
 ),
 forecast_1_30 AS (
    SELECT
        f.wh_id,
        f.item_number,
        SUM(f.forecast_demand) AS forecast_qty_1_60
    FROM dbo.t_item_forecast_daily f WITH (NOLOCK)
    INNER JOIN dbo.t_item_master itm WITH (NOLOCK)
        ON f.wh_id = itm.wh_id
       AND f.item_number = itm.item_number
    WHERE f.wh_id = '335'
          and itm.class_id = 'FLOOR'      
        AND f.pick_day BETWEEN 1 AND 60
    GROUP BY
        f.wh_id,
        f.item_number)

