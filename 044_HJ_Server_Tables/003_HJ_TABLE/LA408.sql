
DECLARE @WW_USERNAME NVARCHAR(255) = REPLACE(UPPER('~WW_USERNAME~'), 'ASHLEYFURNITURE_','')
SELECT
    cico.work_day,
    ev.id,
    ev.name,
    cico.actual_clock_in,
    cico.clock_in,
    cico.actual_clock_out,
    cico.clock_out,
    grp.description + ' [' + CONVERT(VARCHAR,cico.group_nbr) + ']' AS group_name,
    CASE
        WHEN clock_out IS NULL THEN 'Switch Group'
        ELSE NULL
    END AS action_group_switch,
    grp.schedule_id
FROM t_la_employee_clock_in_out cico (NOLOCK)
     INNER JOIN dbo.usf_employee_visibility (@WW_USERNAME) ev
            ON ev.employee_id = cico.employee_id
    INNER JOIN t_group grp (NOLOCK)
        ON cico.group_nbr = grp.group_nbr
-- 11/08/2013 Erik Easton: Removed last 24 hours per Nate
--WHERE (cico.clock_in > GETDATE() - 1 OR
WHERE cico.clock_out IS NULL
ORDER BY
    cico.work_day