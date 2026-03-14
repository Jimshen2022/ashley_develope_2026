
-- 查看打卡表中，实际未打卡的记录
SELECT  *  FROM t_la_employee_clock_in_out WHERE actual_clock_out is NULL and actual_clock_in < '2026-03-14' and employee_id = '50953'
SELECT  *  FROM t_la_employee_clock_in_out WHERE actual_clock_in < '2026-03-14' and employee_id = '50953'
SELECT  top 10 *  FROM t_employee WHERE emp_number = '50953'
SELECT top 10  *  FROM t_la_employee_clock_in_out
-- 更新打卡表中，某个员工的打卡记录，补全缺失的打卡时间
update t_la_employee_clock_in_out set clock_out=dateadd(hh,10,clock_in),actual_clock_out=dateadd(hh,10,actual_clock_in) 
where  employee_id='1002492' and work_day= '2025-11-01 00:00:00.000' and clock_out is null




