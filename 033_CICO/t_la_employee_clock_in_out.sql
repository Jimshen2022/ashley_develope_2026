-- 查看打卡表中，实际未打卡的记录
SELECT  *  FROM t_la_employee_clock_in_out WHERE actual_clock_out is NULL and actual_clock_in < '2026-03-20'

-- 更新打卡表中，某个员工的打卡记录，补全缺失的打卡时间
update t_la_employee_clock_in_out 

set clock_out=dateadd(hh,10,clock_in),actual_clock_out=dateadd(hh,10,actual_clock_in) 
-- day shift
set actual_clock_out=DATEDIFF(d,0,clock_in)+19E0/24,clock_out=DATEDIFF(d,0,clock_in)+19E0/24
-- night shift
set actual_clock_out=DATEDIFF(d,0,clock_in)+31E0/24,clock_out=DATEDIFF(d,0,clock_in)+31E0/24
--set clock_out=DATEADD(HOUR,19,DATEDIFF(DAY,0,actual_clock_in)),actual_clock_out=DATEADD(HOUR,19,DATEDIFF(DAY,0,actual_clock_in))
--set clock_out=DATEADD(hh,19,DATEDIFF(d,0,actual_clock_in)),actual_clock_out=DATEADD(hh,19,DATEDIFF(d,0,actual_clock_in))
where  employee_id='1001997' and work_day= '2026-01-28 00:00:00.000' and clock_out is null


clock_out=CASE
WHEN CONVERT(TIME,actual_clock_in)<'19:00' THEN DATEADD(HOUR,19,DATEDIFF(DAY,0,actual_clock_in))
ELSE DATEADD(HOUR,31,DATEDIFF(DAY,0,actual_clock_in)) END,
actual_clock_out=CASE
WHEN CONVERT(TIME,actual_clock_in)<'19:00' THEN DATEADD(HOUR,19,DATEDIFF(DAY,0,actual_clock_in))
ELSE DATEADD(HOUR,31,DATEDIFF(DAY,0,actual_clock_in)) END




WHERE employee_id='1000979' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1001221' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1001634' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002106' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002506' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002572' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002574' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002575' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1001822' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1001948' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002555' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002539' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002307' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002492' AND work_day='2026-03-20' AND clock_out IS NULL
WHERE employee_id='1002170' AND work_day='2026-03-20' AND clock_out IS NULL


-- 更新打卡表中，某个员工的打卡记录，补全缺失的打卡时间
-- 规则：
--   actual_clock_in 在 07:00~19:00 → clock_out / actual_clock_out = 当天 19:00
--   actual_clock_in 在 20:00~次日 07:00 → clock_out / actual_clock_out = 次日 07:00

UPDATE t_la_employee_clock_in_out
SET
    clock_out = CASE
                    -- 日班：07:00 <= 打卡时间 < 19:00 → 当天 19:00
                    WHEN CAST(actual_clock_in AS TIME) >= '07:00:00'
                     AND CAST(actual_clock_in AS TIME) <  '19:00:00'
                    THEN DATEADD(DAY, 0, CAST(CAST(actual_clock_in AS DATE) AS DATETIME) + CAST('19:00:00' AS DATETIME))
                    
                    -- 夜班：19:00 <= 打卡时间 <= 23:59 → 次日 07:00
                    WHEN CAST(actual_clock_in AS TIME) >= '19:00:00'
                    THEN DATEADD(DAY, 1, CAST(CAST(actual_clock_in AS DATE) AS DATETIME) + CAST('07:00:00' AS DATETIME))
                    
                    -- 夜班：00:00 <= 打卡时间 < 07:00 → 当天 07:00（即次日相对前一天）
                    WHEN CAST(actual_clock_in AS TIME) < '07:00:00'
                    THEN CAST(CAST(actual_clock_in AS DATE) AS DATETIME) + CAST('07:00:00' AS DATETIME)
                    
                    ELSE clock_out
                END,

    actual_clock_out = CASE
                    WHEN CAST(actual_clock_in AS TIME) >= '07:00:00'
                     AND CAST(actual_clock_in AS TIME) <  '19:00:00'
                    THEN DATEADD(DAY, 0, CAST(CAST(actual_clock_in AS DATE) AS DATETIME) + CAST('19:00:00' AS DATETIME))
                    
                    WHEN CAST(actual_clock_in AS TIME) >= '19:00:00'
                    THEN DATEADD(DAY, 1, CAST(CAST(actual_clock_in AS DATE) AS DATETIME) + CAST('07:00:00' AS DATETIME))
                    
                    WHEN CAST(actual_clock_in AS TIME) < '07:00:00'
                    THEN CAST(CAST(actual_clock_in AS DATE) AS DATETIME) + CAST('07:00:00' AS DATETIME)
                    
                    ELSE actual_clock_out
                END

WHERE employee_id = '1001997'
  AND work_day = '2026-01-28 00:00:00.000'
  AND clock_out IS NULL;






select  top 100 * from t_employee WHERE status = 'A'
select  top 10 * from t_department
select  top 10 * from t_group
select  top 10 * from t_supervisor

select e.emp_number,t.*
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
where clock_out is null and work_day < CAST(GETDATE() AS DATE)


-- employee department supervisor
select  
    e.employee_id,
    e.emp_number,
     e.name as employee_name, 
     e.status,
     e.work_shift,
     e.audit_required,
     s.supervisor_nbr,
     e.supervisor as supervisor_name,
     g.group_nbr,
     g.description as group_name,
     t.department as department_nbr,
     t.description as department_name
from t_employee as e 
left join t_department as t on e.dept = t.department
left join t_group as g on e.group_nbr = g.group_nbr
left join t_supervisor as s on e.supervisor_nbr = s.supervisor_nbr
where e.supervisor_nbr = '00891' and e.status = 'A'


select * from t_employee where supervisor_nbr = '50279'
select top 10 * from t_group_master where supervisor_nbr = '50279'
select top 10 * from t_group where supervisor_nbr = '50279'
select top 10 * from t_supervisor where supervisor_nbr = '50279'
select top 10 * from t_tran_log where employee_id = '50945' order by start_tran_date desc
select * from t_employee where supervisor_nbr = '50279'

select  * from t_employee where supervisor like '%DIEP TUAN%'
select  * from t_employee where name like '%DIEP TUAN%'
select  * from t_employee where name like '%DIEP TUAN%' 
select  * from t_employee where emp_number in ('80054') 


-- 查看打卡表中，实际未打卡的记录
SELECT  *  FROM t_la_employee_clock_in_out WHERE actual_clock_in >= '2026-03-20' and employee_id = '1001787'
SELECT  *  FROM t_la_employee_clock_in_out WHERE actual_clock_out is NULL and actual_clock_in < '2026-03-20' and employee_id = '1002307'
SELECT  *  FROM t_la_employee_clock_in_out WHERE actual_clock_in < '2026-03-14' and employee_id = '50953'
SELECT  top 10 *  FROM t_employee WHERE emp_number = '50953'
SELECT top 10  *  FROM t_la_employee_clock_in_out


SELECT  *  FROM t_la_employee_clock_in_out_detail WHERE employee_id = '1002616'
SELECT  *  FROM t_la_employee_clock_in_out WHERE employee_id = '1002616' and actual_clock_in > '2026-01-15'


SELECT *  
FROM t_la_employee_clock_in_out 
where employee_id in ('1002540') and  actual_clock_in > '2026-01-28'


-- check employee shift in tran log
SELECT *
FROM t_tran_log
where employee_id in ('00891') and  start_tran_date >= '2026-03-20' 
order by start_tran_date desc, start_tran_time desc


-- 查看打卡表中，实际未打卡的记录，并统计每天每个员工的未打卡记录数
SELECT 
    employee_id, 
    CAST(actual_clock_in AS DATE) AS WorkDate, 
    COUNT(*) AS RecordCount
FROM t_la_employee_clock_in_out
WHERE actual_clock_out IS NULL 
  AND actual_clock_in < '2026-03-20'
GROUP BY 
    employee_id, 
    CAST(actual_clock_in AS DATE)
HAVING COUNT(*) > 1
ORDER BY WorkDate DESC, RecordCount DESC;

-- 查看打卡表中，实际未打卡的记录，并统计每天每个员工的未打卡记录数















































































