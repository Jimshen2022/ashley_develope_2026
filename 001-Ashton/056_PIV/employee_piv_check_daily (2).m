Vietnam Employee Performance Scorecard-Actual Clock Out

let
    Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [Query="    
WITH base AS (
    SELECT
        wh_id,
        employee_id,
        equipment_id,
        CAST(check_performed AS date)              AS check_date,
        CONVERT(varchar(19), check_performed, 120) AS check_datetime,

        CAST(
            DATEADD(hour, -7, check_performed)
        AS date)                                   AS shift_date,

        CASE
            WHEN DATEPART(hour, check_performed) BETWEEN 7 AND 18
                THEN 'D'
            ELSE 'N'
        END                                        AS shift

    FROM  Distribution_Warehouse_Wholesale.EquipmentCheckLog
    WHERE check_performed >= '2024-01-01'
      AND wh_id = '335'
),
deduped_equip AS (
    SELECT DISTINCT
        wh_id,
        check_date,
        shift_date,
        shift,
        employee_id,
        CAST(equipment_id AS varchar(50))          AS equipment_id
    FROM  base
),
max_time_per_equip AS (
    SELECT
        wh_id,
        check_date,
        shift_date,
        shift,
        employee_id,
        CAST(equipment_id AS varchar(50))          AS equipment_id,
        MAX(check_datetime)                        AS last_check_datetime
    FROM  base
    GROUP BY wh_id, check_date, shift_date, shift, employee_id, equipment_id
),
agg_equip AS (
    SELECT
        wh_id, check_date, shift_date, shift, employee_id,
        COUNT(equipment_id)                        AS equipment_count,
        STRING_AGG(equipment_id, ', ')
            WITHIN GROUP (ORDER BY equipment_id)   AS equipment_list
    FROM  deduped_equip
    GROUP BY wh_id, check_date, shift_date, shift, employee_id
),
agg_time AS (
    SELECT
        wh_id, check_date, shift_date, shift, employee_id,
        STRING_AGG(last_check_datetime, ', ')
            WITHIN GROUP (ORDER BY equipment_id)   AS check_time_list
    FROM  max_time_per_equip
    GROUP BY wh_id, check_date, shift_date, shift, employee_id
)
SELECT
    e.wh_id,
    e.check_date,
    e.shift_date,
    e.shift,
    e.employee_id,
    e.equipment_count,
    e.equipment_list,
    t.check_time_list,
    CONCAT(
        e.wh_id,       '-',
        e.employee_id, '-',
        CAST(MONTH(e.shift_date) AS varchar(2)), '/',
        CAST(DAY(e.shift_date)   AS varchar(2)), '/',
        CAST(YEAR(e.shift_date)  AS varchar(4))
    )                                              AS master_key
FROM       agg_equip e
INNER JOIN agg_time  t
    ON  t.wh_id       = e.wh_id
    AND t.check_date  = e.check_date
    AND t.shift_date  = e.shift_date
    AND t.shift       = e.shift
    AND t.employee_id = e.employee_id
ORDER BY
    e.shift_date,
    e.shift,
    e.employee_id;    
    ", CreateNavigationProperties=false, CommandTimeout=#duration(0, 2, 40, 0)]),
    #"Added Custom" = Table.AddColumn(Source, "WhseEmployee#", each [wh_id]&"-"&[employee_id]),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"shift_date", type date}})
in
    #"Changed Type"