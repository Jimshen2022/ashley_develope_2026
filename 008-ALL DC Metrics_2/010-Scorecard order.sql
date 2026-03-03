SELECT  [wh_id] AS [DC #]
,case when [wh_id]='1' then 'Arcadia'
      when [wh_id]='17' then 'Advance'
	  when [wh_id]='15' then 'Leesport'
	  when [wh_id]='5' then 'Redlands'
      when [wh_id]='ECR' then 'Ecru'
	  when [wh_id]='28' then 'Mesquite'
	  when [wh_id]='335' then 'Ashton'
	  when [wh_id]='42' then 'Spanaway'
	  else 'Other' End AS [DC]
,case when [wh_id]='1' then '2'
      when [wh_id]='17' then '1'
	  when [wh_id]='15' then '5'
	  when [wh_id]='5' then '7'
      when [wh_id]='ECR' then '4'
	  when [wh_id]='28' then '6'
	  when [wh_id]='335' then '3'
	  when [wh_id]='42' then '8'
	  else 'Other' End AS [Order]
  FROM [PowerBI_Distribution].[WhsNames]
  where [wh_id] IN ('1','17','15','28','5','42','335','ECR')