SELECT       
 a.wh_id   
,a.employee_id
,a.EmployeeNumber   
,a.process_id  
, labor_type  -- 2011-04-07 Erik Easton - Added
, process_name
--, additional_description  
, work_day  
, process_transaction  
, MIN(process_start) AS first_process_start  
, MAX(process_end) AS last_process_end  
, SUM([actual_elapsed_time]) AS actual_time   
, SUM([total_sam]) AS sam   

FROM(
SELECT [process_report_id]
      ,a.[process_id]
	  ,b.process_name
      ,[equipment_type_id]
      ,[equipment_id]
      ,a.[wh_id]
      ,[employee_id]
	  ,c.EmployeeNumber
      ,[work_shift_id]
      ,[work_day]
      ,[process_start]
      ,[process_end]
      ,[start_location]
      ,[previous_location]
      ,[actual_elapsed_time]
      ,[process_transaction]
      ,[goal_time_transaction]
      ,a.[type]
      ,[total_sam]
      ,a.[labor_type]
      ,[status]
      ,[cico_key]
      ,[home_wh_id]
      ,[supervisor_nbr]
      ,[home_supervisor_nbr]
      ,[group_nbr]
      ,[home_group_nbr]
      ,[department]
      ,[home_department]
      ,[company_nbr]
      ,[facility_nbr]
      ,[date_created]
      ,[date_modified]
      ,[modified_by]
      ,[source]
      ,[la_unit]
      ,[superintendent_nbr]
      ,[total_grabs]
      ,[total_cubes]
      ,[total_travel]
  FROM [Distribution_Warehouse_Wholesale].[ProcessReport] a
  INNER JOIN  [Distribution_Warehouse_Wholesale].[t_la_process] b ON a.process_id=b.process_id AND a.wh_id=b.wh_id
  INNER JOIN [PowerBI_Distribution].[DimEmployee] c ON a.wh_id=c.WarehouseID AND a.employee_id=c.EmployeeID
  WHERE a.wh_id IN ('335','35')
  AND a.[work_day] >DATEADD(DAY,-15,GETDATE())
  AND a.[type] IN ('I','TM')
  and a.[process_id] in ('28','19','44','46')
  --and c.employeenumber='119974'

  ) a

 GROUP BY
 a.wh_id   
,a.employee_id
,a.EmployeeNumber      
,a.process_id  
, labor_type  -- 2011-04-07 Erik Easton - Added
, process_name 
--, additional_description  
, work_day  
, process_transaction