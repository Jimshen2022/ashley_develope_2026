SELECT 
[wh_id]
,count(distinct[equipment_id]) AS [Empty Trailers on Yard]
FROM [PowerBI_Distribution].[WRKTrailer]
WHERE entered_yard > '2020-1-01'
and exited_yard is null
and NOT (status = 'HISTORY' or status = 'LOST') -- or status = 'IB SHUTTLE')
and ([state] like 'EMPTY%')
and (equipment_id like'HGIU%' or equipment_id like'HGWU%')
and equipment_id not like '%HGIU504274%'
and equipment_id not like '%HGIU503806%'
group BY
[wh_id]