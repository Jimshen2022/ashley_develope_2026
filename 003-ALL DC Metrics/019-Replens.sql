SELECT
 [wh_id]
,cast([start_tran_date] as date) [start_tran_date]
,count(distinct [routing_code]) as [LPN]
,count(distinct [employee_id]) as [# EE]

FROM [PowerBI_Distribution].[TranLog]
where tran_type in ('251' )
and CAST(start_tran_date AS DATE) BETWEEN DATEADD(day,-200,GETDATE()) AND GETDATE()
and wh_id in ( '1', '15', '17', '5', '28', '42', 'ECR', '335','35')       
and control_number ='REPLENISH'
group by
 [wh_id]
,[start_tran_date]
order by
[start_tran_date]
,[wh_id]