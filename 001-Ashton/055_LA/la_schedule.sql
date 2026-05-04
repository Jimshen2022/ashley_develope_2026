SELECT
    sch.schedule_id,
    CASE WHEN sch.schedule_end_time < sch.schedule_start_time
                AND CONVERT(VARCHAR(12), GETDATE(), 114) >= CONVERT(VARCHAR(12), sch.schedule_end_time, 114)
            THEN CONVERT(VARCHAR(10), GETDATE()+1, 101) + ' ' + CONVERT(VARCHAR(12), sch.schedule_end_time, 114)
        ELSE CONVERT(VARCHAR(10), GETDATE(), 101) + ' ' + CONVERT(VARCHAR(12), sch.schedule_end_time, 114)
    END AS schedule_end_time,
    cico.home_group_nbr
FROM t_la_employee_clock_in_out cico
    LEFT JOIN t_employee emp
        ON cico.employee_id = emp.employee_id
        AND cico.wh_id = emp.wh_id
    LEFT JOIN t_group grp
        ON cico.home_group_nbr = grp.group_nbr
        AND cico.wh_id = grp.wh_id
    LEFT JOIN t_la_schedule sch
        ON grp.schedule_id = sch.schedule_id
WHERE 1=1
    AND emp.id = 'emp_id'
    AND cico.wh_id = '335'
    AND cico.clock_out IS NULL