
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%sto%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%active%'



select top 100 * from t_serial_active as t
select top 100 * from t_location as t

select t.*, l.type, l.pick_area
from t_serial_active as t 
inner join t_location as l
	on t.location_id = l.location_id
where 1=1 
  and l.type in ('X')
  and l.location_id not like 'A3025%'
  and l.pick_area = 'UPHOLSTERY'


select l.location_id, l.location_aisle, l.type, l.pick_area
from t_location as l
where 1=1 
  and l.type in ('X')
  and l.pick_area = 'UPHOLSTERY'



