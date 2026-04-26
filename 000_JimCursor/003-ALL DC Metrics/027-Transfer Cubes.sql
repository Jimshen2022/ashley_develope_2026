Select
[from wh_id]
,sum([pastdue cubes]) as Past_Due_Cubes
,sum([mfg cross-dock cubes]) as Crossdock_Cubes
,sum([remaining to load cubes]) as Total_Cubes
,oldest_date
from PowerBI_Distribution.TransferManagementReport a
left join (Select 
     wh_id
	 ,min([oldest orderdate]) as Oldest_Date
   from PowerBI_Distribution.TransferManagementForTotal 
   group by wh_id) b
on a.[from wh_id]=b.wh_id
where [to wh_id] IN ('1','17','15','5','42','28','ECR')
and [from wh_id] IN ('1','17','15','5','42','28','ECR')
group by
[from wh_id]
,oldest_date