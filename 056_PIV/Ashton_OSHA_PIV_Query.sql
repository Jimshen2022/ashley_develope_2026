-- ============================
-- 查询条件参数（修改这里）
-- ============================
DECLARE @equipment_id          VARCHAR(50)  = 'VJ1324'          -- 设备编号，支持通配符 %
DECLARE @employee_id           VARCHAR(50)  = '%'           -- 员工编号，支持通配符 %
DECLARE @pass_fail_code        VARCHAR(10)  = '%'        -- 通过/失败代码，支持通配符 %

SELECT
    CONVERT(VARCHAR(26), l.check_group, 121)                AS check_group
   ,l.equipment_id
   ,l.employee_id
   ,l.employee_id + ' - ' + e.name                         AS employee_display
   ,CASE WHEN l.equipment_id LIKE 'FOOT%'
         THEN ''
         ELSE CAST(l.check_meter AS NVARCHAR(10))
    END                                                     AS check_meter
   ,l.check_performed
   ,l.checklist_attribute_id
   ,Oa.attribute_name                                       AS checklist_attribute_display
   ,l.pass_fail_code
   ,l.equipment_check_log_id
   ,e.supervisor

FROM       t_equipment_check_log        l  (NOLOCK)
JOIN       t_employee                   e  (NOLOCK) ON l.employee_id          = e.id
JOIN       t_OSHA_checklist_attributes  Oc (NOLOCK) ON l.checklist_attribute_id = Oc.checklist_attribute_id
JOIN       t_OSHA_attributes            Oa (NOLOCK) ON Oc.attribute_id          = Oa.attribute_id

WHERE
        l.equipment_id    LIKE  @equipment_id
    AND l.employee_id     LIKE  @employee_id
    AND l.pass_fail_code  LIKE  @pass_fail_code

ORDER BY
    l.check_group         DESC
   ,l.checklist_attribute_id