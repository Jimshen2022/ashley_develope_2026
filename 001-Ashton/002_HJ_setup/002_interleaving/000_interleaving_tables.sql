
select * from t_interleave_master 
select * from t_interleave_detail 
select * from t_work_types 



-- interleaving 
SELECT *
FROM t_interleave_master (NOLOCK)
WHERE interleave_master_id = 11;

SELECT *
FROM t_interleave_detail (NOLOCK)
WHERE interleave_master_id = 11;

SELECT *
FROM t_work_types (NOLOCK)
WHERE work_types_id IN (45, 63, 75);

-- WORKQ
select  * from t_work_q where work_type like '45%'
select  * from t_work_q where description like '%SCOOP%'


select * from t_order_detail where order_number like '%62918%'
select * from t_order_detail_breakdown where order_number like '%62918%'
