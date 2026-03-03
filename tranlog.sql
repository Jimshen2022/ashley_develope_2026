
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%item%master%'
select *
from t_tran_log as t
where 1=1
 and t.employee_id = '80054'


 select top 10 * from t_item_master
 select top 10 * from t_tran_log

select TOP 10 t.*, im.class_id
from t_tran_log as t
inner join t_item_master im on t.item_number = im.item_number
where 1=1
 and im.class_id = 'FLOOR'