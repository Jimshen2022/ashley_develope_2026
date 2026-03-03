SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%work%'
select top 10 *  from t_exception_tran_log  where exception_date >= '2025-10-04' and item_number = 'T970-6'

select top 10 *  from t_exception_tran_log  where exception_date > '2025-09-20' and tran_type = '99G' and location_id NOT IN ('NG001OP3')



select  *  from t_exception_tran_log  where exception_date > '2025-11-10' and tran_type = '100F2'  ORDER BY exception_date, exception_time














select top 10 *  from  t_class_loca where location_id like 'A3010CA%'
select top 10 *  from  t_loc_pallet_capacity 
-- pallet capacity
select *  from  t_loc_pallet_capacity 
where location_id like 'A3010%'  
	and location_id not in (select location_id from  t_loc_pallet_capacity where pallet_id in ('18'))
	and substring(location_id,6,1) in  ('C','E','G','J','L','N') 


select *  from t_location where location_id like 'A3015%'

-- putaway class 15
SELECT 
    wh_id, 
    location_id, 
    STUFF((
        SELECT DISTINCT ',' + class_id
        FROM t_class_loca t2
        WHERE t2.wh_id = t1.wh_id 
            AND t2.location_id = t1.location_id
            AND t2.location_id LIKE 'A3015%'  
            AND SUBSTRING(t2.location_id, 6, 1) IN ('D','F','H','K','M','P')
        FOR XML PATH('')
    ), 1, 1, '') AS class_ids
FROM t_class_loca t1
WHERE location_id LIKE 'A3015%'  
    AND SUBSTRING(location_id, 6, 1) IN ('D','F','H','K','M','P')
GROUP BY wh_id, location_id
ORDER BY wh_id, location_id


-- pallet capacity 15
select *  from  t_loc_pallet_capacity 
where location_id like 'A3015%'  
	--and location_id not in (select location_id from  t_loc_pallet_capacity where pallet_id in ('18'))
	and substring(location_id,6,1) in  ('C','E','G','J','L','N','Q','S','U','X','Z') 





-- by item
select  *  
from t_exception_tran_log as t
where t.item_number = 'M14141US'
order by t.exception_date, t.exception_time



-- HJ_SN
SELECT t1.item_number, t1.location_id, t1.received_date, CAST(t1.serial_number AS CHAR) as SN
FROM t_serial_active  AS t1
WHERE  t1.wh_id  IN ('335')
	AND t1.item_number in ('M14141US')
  --AND t1.serial_no_status IN ('R', 'L','H')
  --AND T1.location_id LIKE 'EX001AA1%'
  AND t1.serial_no_status NOT IN ('O','S')
Order by t1.location_id, t1.received_date



from t_location as t1
inner join t_class_loc

