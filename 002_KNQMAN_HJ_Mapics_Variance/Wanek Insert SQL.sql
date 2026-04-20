
select *
from t_lookup 

select *
from t_whse 

--AF and IOR

insert into t_lookup 
select wh_id,'HotLoad_ATP_SKIP',1,1033,'AF','AF HOT','TRSFWHID'
from t_whse 
union 
select wh_id,'HotLoad_ATP_SKIP',1,1033,'IOR','IOR HOT','TRSFWHID'
from t_whse
 
insert into t_lookup 
select wh_id,'t_load_master',1,1033,'AF','AF HOT','TRSFWHID'
from t_whse 
union 
select wh_id,'t_load_master',1,1033,'IOR','IOR HOT','TRSFWHID'
from t_whse



--select wh_id,'HotLoad_ATP_SKIP',1,1033,'AF','AF HOT','TRSFWHID'
--from t_whse 
--union 
--select wh_id,'HotLoad_ATP_SKIP',1,1033,'IOR','IOR HOT','TRSFWHID'
--from t_whse

--10921	31	HotLoad_ATP_SKIP	1	1033	AF	AF HOT	TRSFWHID
--10922	33	HotLoad_ATP_SKIP	1	1033	AF	AF HOT	TRSFWHID
--10923	34	HotLoad_ATP_SKIP	1	1033	AF	AF HOT	TRSFWHID
--10924	35	HotLoad_ATP_SKIP	1	1033	AF	AF HOT	TRSFWHID
--10925	31	HotLoad_ATP_SKIP	1	1033	IOR	IOR HOT	TRSFWHID
--10926	33	HotLoad_ATP_SKIP	1	1033	IOR	IOR HOT	TRSFWHID
--10927	34	HotLoad_ATP_SKIP	1	1033	IOR	IOR HOT	TRSFWHID
--10928	35	HotLoad_ATP_SKIP	1	1033	IOR	IOR HOT	TRSFWHID



--select wh_id,'t_load_master',1,1033,'AF','AF HOT','TRSFWHID'
--from t_whse 
--union 
--select wh_id,'t_load_master',1,1033,'IOR','IOR HOT','TRSFWHID'
--from t_whse
--31	t_load_master	1	1033	AF	AF HOT	TRSFWHID
--33	t_load_master	1	1033	AF	AF HOT	TRSFWHID
--34	t_load_master	1	1033	AF	AF HOT	TRSFWHID
--35	t_load_master	1	1033	AF	AF HOT	TRSFWHID
--31	t_load_master	1	1033	IOR	IOR HOT	TRSFWHID
--33	t_load_master	1	1033	IOR	IOR HOT	TRSFWHID
--34	t_load_master	1	1033	IOR	IOR HOT	TRSFWHID
--35	t_load_master	1	1033	IOR	IOR HOT	TRSFWHID