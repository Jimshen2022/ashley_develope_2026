SELECT t1.wh_id, t1.location_id,  t1.TypeDescription, t1.location_barcode
FROM Distribution_Warehouse_Wholesale.t_location as t1
WHERE t1.wh_id IN ('335') AND t1.location_id IN ('A3014CJ1','A3014FT1','A3018EM1','A3018GE1')

SELECT *
FROM Distribution_Warehouse_Wholesale.t_location as t1
WHERE t1.wh_id IN ('335')


-- Check location cycle count class on Sep.23.2024
SELECT
  t1.wh_id,
  t1.location_id,
  t1.TypeDescription,
  t1.status,
  t1.cycle_count_class,
--  ROW_NUMBER() OVER (PARTITION BY t1.location_id ORDER BY t1.location_id) AS rownum -- Replace [YourOrderColumn] with the column you want to sort by
  ROW_NUMBER() OVER (ORDER BY (t1.location_id)) AS rownum
FROM
  Distribution_Warehouse_Wholesale.t_location AS t1
WHERE
  t1.wh_id IN ('335')
  AND t1.location_id NOT LIKE 'RP043%'
AND t1.location_id NOT LIKE 'RP043%'
  AND t1.TypeDescription IN ('A', 'I', 'M', 'P', 'X','ZZ')
  AND t1.cycle_count_class IS NULL
  AND t1.location_id NOT LIKE 'D%'
  AND t1.location_id NOT LIKE 'V%'


