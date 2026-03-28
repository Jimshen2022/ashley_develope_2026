~~SQLServer~~


DECLARE @WW_USERNAME NVARCHAR(255) = REPLACE(UPPER('~WW_USERNAME~'), 'ASHLEYFURNITURE_','')

SET NOCOUNT ON
EXECUTE usp_la_srch_cico_group_action
    N'~Srch_Employee_ID~',
    N'~Srch_Department~',
    N'~Srch_Wh_ID~',
    N'~Srch_Work_Shift_Name~',
    N'~Group_Action_Type~',
    @WW_USERNAME
SET NOCOUNT OFF

SELECT 
    CASE WHEN ega.change_action = 'Y' THEN 'YES'
        ELSE 'NO' 
    END AS clock_in_value,
    dbo.usf_la_get_locale_text (ISNULL(ega.change_action, 'N'), 'YN', '~WW_USERLCID~', 'CONSTANT') AS clock_in,
    emp.employee_id,
    emp.name,
    emp.wh_id,
    emp.dept AS department,
    CASE WHEN '~srch_work_shift_name~' = '%' THEN 'ANY'
         ELSE '~srch_work_shift_name~'
         END AS selected_work_shift,
    emp.work_shift AS default_work_shift,
    '~Actual_Start_Date~' AS actual_start_date,
    '~Actual_Start_Time~' AS actual_start_time,
    'CLOCKIN' AS group_action_type,
    RIGHT(emp.work_shift, 1) AS work_shift_id,
    N'~Srch_Work_Shift_Name~' AS srch_work_shift_name,
    N'~Srch_Employee_ID~' AS srch_employee_id,
    N'~Srch_Wh_ID~' AS srch_wh_id,
    N'~Srch_Department~' AS srch_department,
   @WW_USERNAME AS NEW_WW_USERNAME
FROM
    t_employee emp (NOLOCK)
    
    INNER JOIN
        t_la_employee_group_action ega (NOLOCK)
        ON
            emp.employee_id = ega.employee_id
            AND ega.group_action_type = 'CLOCKIN'
            AND ega.username = @WW_USERNAME
WHERE
    emp.employee_id LIKE N'~Srch_Employee_ID~'
    AND ISNULL(emp.dept, '%') LIKE N'~Srch_Department~'
    AND emp.wh_id = N'~Srch_Wh_ID~'
    AND emp.work_shift LIKE N'~Srch_Work_Shift_Name~'
    AND ISNULL(emp.team_flag, 'N') <> 'Y'
    AND NOT EXISTS(SELECT employee_id FROM t_la_employee_clock_in_out (NOLOCK) WHERE employee_id = emp.employee_id AND clock_out IS NULL)
ORDER BY
    emp.name

