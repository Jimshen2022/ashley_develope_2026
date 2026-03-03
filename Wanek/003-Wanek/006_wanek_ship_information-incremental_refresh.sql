-- Power BI 参数
DECLARE @RangeStart DATETIME = '2024-12-01 00:00:00';
DECLARE @RangeEnd DATETIME = '2025-12-01 00:00:00';  -- 示例值，Power BI 会自动替换

WITH MaxEnteredYard AS (
    SELECT
        a.area_id AS wh_id,
        a.equipment_id,
        MAX(a.entered_yard) AS max_entered_yard
    FROM
        Distribution_Warehouse_Wholesale.Trailer AS a
    WHERE
        a.wh_id = '31' AND a.entered_yard >= @RangeStart
    GROUP BY
        a.area_id, a.equipment_id
),
CTN AS (
    SELECT
        a.area_id AS wh_id,
        a.equipment_id,
        a.trailer_type_id,
        a.entered_yard,
        CASE
            WHEN a.trailer_type_id IN ('86') THEN '20FT'
            WHEN a.trailer_type_id IN ('87') THEN '40FT'
            WHEN a.trailer_type_id IN ('88') THEN '45FT'
            WHEN a.trailer_type_id IN ('177') THEN '40H'
            WHEN a.trailer_type_id IN ('324') THEN '53FT'
            ELSE '40H'
        END AS ctn_size
    FROM
        (SELECT * FROM Distribution_Warehouse_Wholesale.Trailer AS a0 
         WHERE a0.wh_id = '31' AND a0.entered_yard >= @RangeStart) AS a
    INNER JOIN MaxEnteredYard AS mey 
        ON a.area_id = mey.wh_id AND a.equipment_id = mey.equipment_id AND a.entered_yard = mey.max_entered_yard
),
ItemInfo AS (
    SELECT
        COALESCE(T1.ITNBR, T2.ITNBR) AS ITNBR,
        CASE
            WHEN T1.CUBES > 0 THEN T1.ITMITCLS
            WHEN T1.CUBES = 0 AND T2.B2Z95S > 0 THEN T2.ITCLS
            ELSE NULL
        END AS ITCLS,
        CASE
            WHEN T1.CUBES > 0 THEN T1.ITMWEGHT
            WHEN T1.CUBES = 0 AND T2.B2Z95S > 0 THEN T2.WEGHT
            ELSE NULL
        END AS WEGHT,
        CASE
            WHEN T1.CUBES > 0 THEN T1.CUBES
            WHEN T1.CUBES = 0 AND T2.B2Z95S > 0 THEN T2.B2Z95S
            ELSE NULL
        END AS unit_cube
    FROM
        MasterData_ItemMaster_WNK.ITMEXT AS T1
    FULL OUTER JOIN (
        SELECT
            a.ITNBR, a.ITCLS, a.B2Z95S, a.WEGHT
        FROM
            MasterData_ItemMaster_WNK.ITMRVA AS a
        WHERE
            a.STID = '35'
    ) AS T2 ON T1.ITNBR = T2.ITNBR
),
tripDetail AS (
    SELECT * 
    FROM Distribution_Warehouse_Wholesale.TranLog AS t0
    WHERE 
        t0.wh_id IN ('35', '31', '33', '34')
        AND t0.tran_type IN ('361')
        AND t0.start_tran_date >= @RangeStart AND t0.start_tran_date < @RangeEnd
),
TripInfo AS (
    SELECT DISTINCT
        td.wh_id,
        td.control_number_2 AS trip_nbr,
        td.routing_code AS ctn_nbr,
        td.start_tran_date,
        ctn.ctn_size
    FROM
        tripDetail AS td
    LEFT JOIN CTN AS ctn 
        ON ctn.equipment_id = td.routing_code AND ctn.wh_id = td.wh_id
),
MixedContainer AS (
    SELECT
        b1.wh_id,
        b1.ctn_nbr,
        b1.trip_nbr,
        b1.employee_id,
        b1.supervisor,
        COUNT(DISTINCT b1.product) AS product_category_qty,
        COUNT(DISTINCT b1.item_number) AS skus,
        CASE WHEN COUNT(DISTINCT b1.product) = 1 THEN 'Non-Mixed' ELSE 'Mixed' END AS container_type
    FROM (
        SELECT
            td.wh_id,
            td.item_number,
            CASE
                WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTRING(td.item_number, 1, 1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
                ELSE 'UPH'
            END AS product,
            td.routing_code AS ctn_nbr,
            td.control_number_2 AS trip_nbr,
            td.employee_id,
            td.employee_id_2 AS supervisor
        FROM tripDetail AS td
        LEFT JOIN ItemInfo AS itm ON td.item_number = itm.ITNBR
    ) AS b1
    GROUP BY
        b1.wh_id, b1.ctn_nbr, b1.trip_nbr, b1.employee_id, b1.supervisor
),
EmployeeInfo AS (
    SELECT
        t1.wh_id,
        t1.id,
        t1.name,
        t1.work_shift,
        t1.supervisor,
        t1.dept,
        t2.description AS dept_name,
        t1.group_nbr,
        t3.Description AS group_name
    FROM
        (SELECT * FROM Distribution_Warehouse_Wholesale.t_employee AS t0
         WHERE t0.wh_id IN ('35', '31', '33', '34') AND t0.status <> 'T') AS t1
    LEFT JOIN PowerBI_Distribution.Department AS t2 ON t1.wh_id = t2.wh_id AND t1.dept = t2.department
    LEFT JOIN Distribution_Warehouse_Wholesale.[Group] AS t3 ON t1.wh_id = t3.wh_id AND t1.group_nbr = t3.GroupNbr
)
SELECT
    t1.tran_type,
    t1.wh_id,
    t1.item_number,
    CASE
        WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
        ELSE 'UPH'
    END AS product,
    t1.routing_code AS ctn_nbr,
    tp.ctn_size,
    t1.control_number_2 AS trip_nbr,
    m.container_type,
    m.skus,
    m.employee_id,
    e.name AS employee_name,
    e.supervisor,
    CASE
        WHEN m.container_type = 'Non-Mixed' THEN
            CASE
                WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
                ELSE 'UPH'
            END
        ELSE m.container_type
    END AS container_category,
    itm.unit_cube,
    MAX(t1.start_tran_date) AS start_tran_date,
    SUM(t1.tran_qty) AS tran_qty,
    itm.unit_cube * SUM(t1.tran_qty) AS cubes,
    CAST(
        itm.unit_cube * SUM(t1.tran_qty) /
        CASE
            WHEN TRIM(SUBSTRING(tp.ctn_size, 1, 3)) = '40H' THEN 2650.0
            WHEN TRIM(SUBSTRING(tp.ctn_size, 1, 3)) = '40' THEN 2383.0
            WHEN TRIM(SUBSTRING(tp.ctn_size, 1, 3)) = '45' THEN 3058.0
            WHEN SUBSTRING(tp.ctn_size, 1, 1) = '2' THEN 1191.0
            ELSE 2650.0
        END AS DECIMAL(10, 4)
    ) AS Utilization
FROM
    tripDetail AS t1
LEFT JOIN ItemInfo AS itm ON t1.item_number = itm.ITNBR
LEFT JOIN MixedContainer AS m ON t1.wh_id = m.wh_id AND t1.control_number_2 = m.trip_nbr AND t1.routing_code = m.ctn_nbr
LEFT JOIN TripInfo AS tp ON t1.wh_id = tp.wh_id AND t1.routing_code = tp.ctn_nbr AND t1.control_number_2 = tp.trip_nbr
LEFT JOIN EmployeeInfo AS e ON t1.wh_id = e.wh_id AND t1.employee_id = e.id
GROUP BY
    t1.tran_type,
    t1.wh_id,
    t1.item_number,
    CASE
        WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
        ELSE 'UPH'
    END,
    t1.routing_code,
    tp.ctn_size,
    t1.control_number_2,
    m.container_type,
    m.skus,
    m.employee_id,
    e.name,
    e.supervisor,
    CASE
        WHEN m.container_type = 'Non-Mixed' THEN
            CASE
                WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTRING(t1.item_number, 1, 1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
                ELSE 'UPH'
            END
        ELSE m.container_type
    END,
    itm.unit_cube
ORDER BY
    t1.control_number_2, t1.item_number;
