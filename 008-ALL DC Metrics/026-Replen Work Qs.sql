SELECT  
	     [wh_id]
        --,[description]
        ,[priority]
		,case when [description]='IB Replenishment' then 'IB Replens' else 'All Other Replens' end as [Replen Type]
	    ,count([work_q_id]) as Count
  FROM [PowerBI_Distribution].[WorkQue]
  where [wh_id] in ('1','15','17','5','28','42','ECR','335') 
  and [work_status] = 'U' 
  and [Priority] >= '90' 
  and [work_type] = '07'
  group by 
   [wh_id]
  --,[description]
  ,[priority]
  ,[description]
  order by priority desc