select top 10 * from t_replenishment_task_log 
select top 10 * from t_replenishment_allocation 
select top 10 * from t_replenishment_task_queue 
select top 10 * from t_replenishment_rule 
select  * from t_lookup 
select top 100 * from  t_work_q 
select top 100 * from t_work_types 
select top 100 * from t_issue_tracking 

t_work_q
t_work_types


-- repleishment task log by item
select * from t_replenishment_task_log as t where t.item_number = 'B752-96' and t.wh_id = '335' order by completed_datetime desc


