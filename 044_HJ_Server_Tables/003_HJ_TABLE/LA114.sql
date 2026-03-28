~~SQLServer~~
DECLARE @WW_USERNAME NVARCHAR(255) = REPLACE(UPPER('~WW_USERNAME~'), 'ASHLEYFURNITURE_','')

SET NOCOUNT ON
EXECUTE usp_la_srch_co_group_action
    N'~Srch_Employee_ID~',
    N'~Srch_Department~',
    N'~Srch_Wh_ID~',
    N'~Srch_Work_Shift_ID~',
    N'~Group_Action_Type~',
    @WW_USERNAME
SET NOCOUNT OFF

SELECT  
   CASE WHEN ega.change_action = 'Y' THEN 'YES'
        ELSE 'NO' 
    END AS clock_out_value,
    dbo.usf_la_get_locale_text (ISNULL(ega.change_action, 'N'), 'YN', '~WW_USERLCID~', 'CONSTANT') AS clock_out,
    eci.cico_key, 
    eci.employee_id,
    emp.name,
    emp.wh_id,
    emp.dept AS department,
    wsf.work_shift_name,
    'CLOCKOUT' AS group_action_type,
    '~Actual_End_Date~' AS actual_end_date,
    '~Actual_End_Time~' AS actual_end_time,
    N'~Srch_Wh_ID~' AS srch_wh_id,
    N'~Srch_Department~' AS srch_department,
    N'~Srch_Work_Shift_ID~' AS srch_work_shift_id,
    N'~Srch_Employee_ID~' AS srch_employee_id,
   @WW_USERNAME AS NEW_WW_USERNAME
FROM t_la_employee_clock_in_out eci WITH(NOLOCK)
    LEFT OUTER JOIN
        t_la_employee_group_action ega
        ON
            eci.employee_id = ega.employee_id
            AND ega.group_action_type = 'CLOCKOUT'
            AND ega.username = @WW_USERNAME
    INNER JOIN 
        t_employee emp
        ON
            emp.employee_id = eci.employee_id
    INNER JOIN
        t_la_work_shift wsf
        ON
            wsf.work_shift_id = eci.work_shift_id
OUTER APPLY(SELECT TOP 1 department dpt
	             FROM t_la_employee_clock_in_out_detail ecid WITH (NOLOCK)
                          WHERE eci.cico_key = ecid.cico_key
                                AND department LIKE '~Srch_Department~') dpt
WHERE
eci.employee_id <> 0
AND ISNULL(eci.employee_id,'%') LIKE '~Srch_Employee_ID~'
     AND ISNULL(eci.wh_id,'%') LIKE N'~Srch_Wh_ID~'
   AND ISNULL(eci.work_shift_id, '%') LIKE '~Srch_Work_Shift_ID~'
    AND eci.clock_out IS NULL
    AND eci.clock_in IS NOT NULL
ORDER BY
    emp.name
