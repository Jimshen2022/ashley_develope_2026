--insert into t_lookup 
--select wh_id,'HotLoad_ATP_SKIP',1,1033,'AF','AF HOT','TRSFWHID'
--	from t_whse 
--union 
--select wh_id,'HotLoad_ATP_SKIP',1,1033,'IOR','IOR HOT','TRSFWHID'
--	from t_whse
 
--insert into t_lookup 
--select wh_id,'t_load_master',1,1033,'AF','AF HOT','TRSFWHID'
--	from t_whse 
--union 
--select wh_id,'t_load_master',1,1033,'IOR','IOR HOT','TRSFWHID'
--	from t_whse


select wh_id,'HotLoad_ATP_SKIP',1,1033,'AF','AF HOT','TRSFWHID'
from t_whse
union all 
select wh_id,'HotLoad_ATP_SKIP',1,1033,'IOR','IOR HOT','TRSFWHID'
from t_whse


select wh_id,'t_load_master',1,1033,'AF','AF HOT','TRSFWHID'
	from t_whse 
union 
select wh_id,'t_load_master',1,1033,'IOR','IOR HOT','TRSFWHID'
	from t_whse