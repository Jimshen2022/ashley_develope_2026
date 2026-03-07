
SELECT
	a.ExceptionCode
	,a.[Exception]
	,a.[Exception W/E]
	,a.[Count of Exceptions]
	,a.[Qty]
	,a.[wh_id]
	,a.Market
	,a.WhseEmpNumber
	,a.EmployeeName
	,a.CurrentlyAssignedSupervisorName
	,a.EmployeeNumber
	,DENSE_RANK() OVER(PARTITION BY  a.ExceptionCode,a.[Exception W/E], a.wh_id ORDER BY [Count of Exceptions] DESC) AS Rank
FROM
(
	SELECT  [tran_type]
		  ,[description]
		  ,CONCAT(tran_type, '-',description) AS [Exception]
		  ,DATEADD(dd, 7-(DATEPART(dw, exception_date)), exception_date) AS [Exception W/E]
		  ,COUNT([exception_time]) AS [Count of Exceptions]
		  --,[employee_id]
		  ,[wh_id]
		  ,CONCAT(wh_id, '-', employee_id) AS [Custom]
		  ,SUM([quantity]) AS [Qty]
		  --,[hu_id]
		  --,[load_id]
		  --,[control_number]
		  --,[line_number]
		  ,CASE 
				WHEN CONCAT(tran_type, '-',description) LIKE '%-F2%' THEN 'F2' 
				WHEN CONCAT(tran_type, '-',description) LIKE '101-Putaway Location Override%' THEN 'Putaway Overrides' 
				ELSE 'F7' END AS ExceptionCode
		  ,case when wh_id = '42' then '42 - Spanaway'
			   when wh_id = '28' then '28 - Mesquite'
			   when wh_id = '5' then '5 - Redlands'
			   when wh_id = '17' then '17 - Advance'
			   when wh_id = '15' then '15 - Leesport'
			   when wh_id = 'ECR' then 'ECR - Ecru'
			   when wh_id = '1' then '1 - Arcadia'
			   when wh_id = '335' then '335 - Ashton'
			   else 'Other WHSE' end as [Market]
		   ,WhseEmpNumber
		   ,EmployeeName
		   ,CurrentlyAssignedSupervisorName
		   ,EmployeeNumber
		  -- ,RANK() OVER (ORDER BY wh_id ORDER BY COUNT([exception_time]) DESC) Rank
	  FROM [PowerBI_Distribution].[ExceptionLog]
		LEFT JOIN PowerBI_Distribution.DimEmployee
			ON CONCAT(wh_id, '-', employee_id) = WhseEmpNumber
	  where tran_type IN ('112F2','115f2','152f2','202f2','252f2','254f2','262f2','303f7', '301f7', '305f7','101') -- ,'311a','313a', '315a', 'dcf1','dcf6','dcf8','SLRP','254f9','202f9', 'dcf3')
	  and [wh_id] in ('335')
	  and cast([exception_date] as date) BETWEEN DATEADD(day,-60,GETDATE()) AND GETDATE()
	  AND WhseEmpNumber IS NOT NULL
	  GROUP BY
	  [tran_type]
		  ,[description]
		  ,CONCAT(tran_type, '-',description) 
  
		  ,DATEADD(dd, 7-(DATEPART(dw, exception_date)), exception_date)
		  ,[wh_id]
		  ,CONCAT(wh_id, '-', employee_id) 
  
		  ,CASE WHEN CONCAT(tran_type, '-',DESCRIPTION)LIKE '%-F2%' THEN 'F2' ELSE 'F7' END 
		  ,CASE WHEN wh_id = '42' THEN '42 - Spanaway'
		   WHEN wh_id = '28' THEN '28 - Mesquite'
		   WHEN wh_id = '5' THEN '5 - Redlands'
		   WHEN wh_id = '17' THEN '17 - Advance'
		   WHEN wh_id = '15' THEN '15 - Leesport'
		   WHEN wh_id = 'ECR' THEN 'ECR - Ecru'
		   WHEN wh_id = '1' THEN '1 - Arcadia'
		   when wh_id = '335' then '335 - Ashton'
		   else 'Other WHSE' end 
		   ,WhseEmpNumber
		   ,EmployeeName
		   ,CurrentlyAssignedSupervisorName
		   ,EmployeeNumber
) A
--WHERE A.wh_id = '15' AND A.exceptioncode = 'F2'
ORDER BY
	Rank, a.exceptionCode, a.[Exception W/E], a.wh_id, 
	a.EmployeeName



