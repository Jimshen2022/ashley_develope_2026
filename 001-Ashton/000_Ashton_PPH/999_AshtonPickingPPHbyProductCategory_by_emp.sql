WITH itm AS (
    SELECT DISTINCT
        t3.ITNBR AS item_number,
        t1.wh_id,
        t1.description,
        t1.commodity_code,
        t4.PICKPUT AS pick_put_id,
        t3.ITCLS,
        t3.B2Z95S,
        t3.B2Z95S * 0.028317 AS Unit_CBM,
        CASE
            WHEN LEFT(t3.ITNBR, 4) = '100-'
              OR LEFT(t3.ITNBR, 1) IN ('A','B','D','H','L','Q','R','T','W','M','E')
              OR t3.ITNBR IN ('7340321','9910160','4400021','4400022','7390160',
                              '5920230','1300021','1660021','6280260')
            THEN 'CG'
            ELSE 'UPH'
        END AS product,
        t4.TIHIUNLD,
        t4.ITMCLSID,
        t4.UNITSWIDE,
        t4.UNITLAYERS,
        t4.UNITSDEEP,
        t4.SCOOPQTY,
        t4.SKIDSIZE
    FROM (SELECT a1.ITNBR, a1.ITCLS, a1.B2Z95S
          FROM MasterData_ItemMaster_AFI.ITMRVA AS a1
          WHERE a1.STID IN ('335')) AS t3
    LEFT JOIN (
        SELECT a1.item_number, a1.wh_id, a1.description, a1.commodity_code
        FROM Distribution_Warehouse_Wholesale.t_item_master AS a1
        WHERE a1.wh_id = '335'
    ) AS t1
        ON t1.item_number = t3.ITNBR
    LEFT JOIN (
        SELECT a2.ITNBR, a2.PICKPUT, a2.TIHIUNLD, a2.ITMCLSID,
               a2.UNITSWIDE, a2.UNITLAYERS, a2.UNITSDEEP, a2.SCOOPQTY, a2.SKIDSIZE
        FROM MasterData_ItemMaster_AFI.ITBEXT AS a2
        WHERE a2.HOUSE IN ('335')
    ) AS t4
        ON t3.ITNBR = t4.ITNBR
),
CategoryBase AS (
    SELECT
        t1.*,
        CASE
            WHEN i.product IS NOT NULL THEN i.product
            WHEN LEFT(t1.item_number, 4) = '100-'
              OR LEFT(t1.item_number, 1) IN ('A','B','D','H','L','Q','R','T','W','M','E')
              OR t1.item_number IN ('7340321','9910160','4400021','4400022','7390160',
                                    '5920230','1300021','1660021','6280260')
            THEN 'CG'
            ELSE 'UPH'
        END AS product_category,
        -- 合并开始/结束日期时间
        DATEADD(SECOND,
                DATEDIFF(SECOND, '00:00:00', CAST(t1.start_tran_time AS TIME)),
                CAST(t1.start_tran_date AS DATETIME2)) AS actual_start_time,
        DATEADD(SECOND,
                DATEDIFF(SECOND, '00:00:00', CAST(t1.end_tran_time AS TIME)),
                CAST(t1.end_tran_date AS DATETIME2)) AS actual_end_time
    FROM Distribution_Warehouse_Wholesale.[TranLog] AS t1
    LEFT JOIN itm AS i
        ON t1.item_number = i.item_number
       AND t1.wh_id = i.wh_id
    WHERE
        t1.start_tran_date >= '2025-01-01 07:00:00'
        AND t1.start_tran_date < DATEADD(HOUR, 7, DATEADD(DAY, -1, GETDATE()))
        AND t1.tran_type = '363'
        AND t1.wh_id = '335'
),
TimeWindows AS (
    SELECT
        *,
        LAG(actual_end_time) OVER (
            PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
            ORDER BY actual_start_time
        ) AS prev_end_time,
        CASE
            WHEN DATEDIFF(
                     SECOND,
                     LAG(actual_end_time) OVER (
                         PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                         ORDER BY actual_start_time
                     ),
                     actual_start_time
                 ) > 1800
            THEN DATEDIFF(
                     SECOND,
                     LAG(actual_end_time) OVER (
                         PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                         ORDER BY actual_start_time
                     ),
                     actual_start_time
                 )
            ELSE 0
        END AS indirect_time_seconds
    FROM CategoryBase
),
TimeWindowsWithGroup AS (
    SELECT
        *,
        CASE
            WHEN prev_end_time IS NULL
              OR DATEDIFF(SECOND, prev_end_time, actual_start_time) > 1800
            THEN 1 ELSE 0
        END AS new_window_flag,
        SUM(
            CASE
                WHEN prev_end_time IS NULL
                  OR DATEDIFF(SECOND, prev_end_time, actual_start_time) > 1800
                THEN 1 ELSE 0
            END
        ) OVER (
            PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
            ORDER BY actual_start_time
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS time_window_group
    FROM TimeWindows
),
FinalAggregation AS (
    -- 以时间窗口为单位聚合
    SELECT
        product_category,
        employee_id,
        CAST(start_tran_date AS DATE) AS work_date,
        time_window_group,
        SUM(tran_qty) AS total_qty,
        DATEDIFF(SECOND, MIN(actual_start_time), MAX(actual_end_time)) AS total_work_seconds,
        DATEDIFF(SECOND, MIN(actual_start_time), MAX(actual_end_time)) / 3600.0 AS total_work_hours
    FROM TimeWindowsWithGroup
    GROUP BY
        product_category,
        employee_id,
        CAST(start_tran_date AS DATE),
        time_window_group
)
-- 最终：按 product_category + work_date + employee_id 汇总
SELECT
    fa.product_category,
    fa.employee_id,                                         -- 已加入
    CONVERT(VARCHAR(10), fa.work_date, 120) AS work_date,   -- YYYY-MM-DD
    SUM(fa.total_qty) AS total_qty,
    SUM(fa.total_work_seconds) AS total_work_seconds,
    ROUND(SUM(fa.total_work_hours), 2) AS total_work_hours,
    -- 该员工当日该品类的 PPH
    ROUND(
        CASE WHEN SUM(fa.total_work_hours) = 0
             THEN NULL
             ELSE SUM(fa.total_qty) / SUM(fa.total_work_hours)
        END, 2
    ) AS pph_employee_day
FROM FinalAggregation AS fa
GROUP BY
    fa.product_category,
    fa.employee_id,
    fa.work_date
ORDER BY
    fa.product_category,
    fa.work_date,
    fa.employee_id;
