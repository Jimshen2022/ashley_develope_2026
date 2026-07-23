-- 声明一个变量 @wh_id_list，用于存储仓库 ID 列表
DECLARE @wh_id_list AS VARCHAR(500);

-- 设置仓库 ID 列表，两个仓库 ID 分别为 335 和 35
SET @wh_id_list = '335, 35'; -- 两个仓库均在越南，当地时间比 UTC 快 12 小时

-- 从以下子查询中选择所需的字段
SELECT 
    t3.wh_id                             -- 仓库 ID
    , t3.employee_id                     -- 员工 ID
    , t3.work_day                       -- 工作日
    , t3.clock_in                       -- 上班时间
    , t3.clock_out                      -- 下班时间
    , t3.first_tran_date_time           -- 第一个交易的日期和时间
    , t3.last_tran_date_time            -- 最后一个交易的日期和时间
    , t3.first_tran_type                -- 第一个交易的类型
    , t3.first_tran_description         -- 第一个交易的描述
    , t3.last_tran_type                 -- 最后一个交易的类型
    , t3.last_tran_description          -- 最后一个交易的描述
    , t3.time_before_first_tran_minutes -- 第一个交易前的时间（分钟）
    , t3.time_after_last_tran_minutes   -- 最后一个交易后的时间（分钟）

FROM
(
    -- 子查询 t2 计算了每个员工在特定工作日的交易记录
    SELECT 
        t2.*,
        tranlog_start.tran_type AS first_tran_type,          -- 第一个交易的类型
        tranlog_start.description AS first_tran_description, -- 第一个交易的描述
        tranlog_end.tran_type AS last_tran_type,            -- 最后一个交易的类型
        tranlog_end.description AS last_tran_description,   -- 最后一个交易的描述
        DATEDIFF(MINUTE, clock_in, first_tran_date_time) AS time_before_first_tran_minutes, -- 第一个交易前的时间（分钟）
        DATEDIFF(MINUTE, last_tran_date_time, clock_out) AS time_after_last_tran_minutes,   -- 最后一个交易后的时间（分钟）
        ROW_NUMBER() OVER (PARTITION BY t2.employee_id, t2.wh_id, t2.work_day ORDER BY t2.employee_id) AS row_number_rank -- 分组排序的行号
    FROM
    (
        -- 子查询 T1 计算每个员工在每个工作日的最早和最晚交易时间
        SELECT 
            T1.wh_id
            , employee_id
            , l.[work_day]
            , l.clock_in
            , l.clock_out
            , MIN(start_tran_date_time) AS first_tran_date_time -- 最早交易的日期和时间
            , MAX(end_tran_date_time) AS last_tran_date_time    -- 最晚交易的日期和时间
        FROM
        (
            -- 选择交易记录及其开始和结束时间
            SELECT 
                wh_id
                , employee_id
                , item_number
                , start_tran_date
                , start_tran_time
                , end_tran_date
                , end_tran_time
                , hu_id
                , tran_qty
                , tran_type
                , description
                , CONCAT(CAST([start_tran_date] AS DATE), ' ', CAST([start_tran_time] AS TIME)) AS start_tran_date_time -- 交易开始的日期和时间
                , CONCAT(CAST([end_tran_date] AS DATE), ' ', CAST([end_tran_time] AS TIME)) AS end_tran_date_time -- 交易结束的日期和时间
            FROM [PowerBI_Distribution].[TranLog]
            WHERE CAST([start_tran_date] AS DATE) BETWEEN DATEADD(DAY, -15, CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)) -- 过去 15 天的日期范围
                AND DATEADD(DAY, 1, CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)) -- 到今天的日期范围
                AND [wh_id] IN (SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ',')) -- 过滤特定仓库 ID 列表
                AND [tran_type] <> '100' -- 排除交易类型为 '100' 的记录
        ) T1
        -- 联接员工考勤记录表以获取考勤信息
        LEFT JOIN
        (
            SELECT DISTINCT
                t.[work_day]
                , t.WhseEmpNumber
                , t.EmployeeNumber
                , t.EmployeeName
                , t.[home_department]
                , t.home_wh_id
                , MIN(t.clock_in) AS clock_in -- 最早的上班时间
                , MAX(t.clock_out) AS clock_out -- 最晚的下班时间
                , MAX(t.[End Time]) AS [End Time] -- 结束时间（考虑到实际下班时间可能为空）
            FROM
            (
                SELECT 
                    [cico_key]
                    , [wh_id]
                    , b.WarehouseID
                    , a.home_wh_id
                    , [work_day]
                    , [work_shift_id]
                    , [employee_id]
                    , b.WhseEmpNumber
                    , b.EmployeeNumber
                    , b.EmployeeName
                    , [clock_in]
                    , [actual_clock_out] AS [clock_out]
                    , CASE
                          WHEN a.clock_out <> '' THEN a.actual_clock_out
                          ELSE DATEADD(HOUR, 7, GETUTCDATE()) -- 如果实际下班时间为空，使用当前时间作为结束时间
                      END AS [End Time]
                    , [supervisor_nbr]
                    , [home_supervisor_nbr]
                    , [group_nbr]
                    , [home_group_nbr]
                    , [department]
                    , [home_department]
                FROM [PowerBI_Distribution].[EmployeeClockInOut] a
                LEFT JOIN [PowerBI_Distribution].[DimEmployee] b
                    ON a.employee_id = b.EmployeeID
                    AND a.home_wh_id = b.WarehouseID
                WHERE CAST([work_day] AS DATE) BETWEEN DATEADD(DAY, -15, CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)) -- 过去 15 天的日期范围
                    AND CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE) -- 到今天的日期范围
                    AND [home_wh_id] IN (SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ',')) -- 过滤特定仓库 ID 列表
            ) t
            GROUP BY 
                t.work_day
                , t.WhseEmpNumber
                , t.EmployeeNumber
                , t.EmployeeName
                , t.home_department
                , t.home_wh_id
        ) l
        ON T1.[employee_id] = l.EmployeeNumber
            AND T1.[wh_id] = l.home_wh_id
    WHERE
        T1.end_tran_date_time >= l.clock_in -- 交易结束时间在上班时间之后
        AND T1.end_tran_date_time <= CASE WHEN l.clock_out <> '' THEN l.clock_out ELSE [End Time] END -- 交易结束时间在下班时间之前（如果下班时间为空，则使用结束时间）
        AND T1.start_tran_date_time >= l.clock_in -- 交易开始时间在上班时间之后
        AND T1.start_tran_date_time <= CASE WHEN l.clock_out <> '' THEN l.clock_out ELSE [End Time] END -- 交易开始时间在下班时间之前（如果下班时间为空，则使用结束时间）
        AND l.clock_in IS NOT NULL -- 确保上班时间不为空
        AND l.clock_out IS NOT NULL -- 确保下班时间不为空
        AND DATEDIFF(HOUR, l.clock_in, l.clock_out) < 24 -- 确保工作时间小于 24 小时
    GROUP BY
        t1.wh_id
        , t1.employee_id
        , l.work_day
        , l.clock_in
        , l.clock_out
    ) t2
    -- 联接第一个交易的详细信息
    LEFT JOIN [PowerBI_Distribution].[TranLog] tranlog_start
    ON t2.first_tran_date_time = CONCAT(CAST(tranlog_start.[start_tran_date] AS DATE), ' ', CAST(tranlog_start.[start_tran_time] AS TIME))
    AND t2.employee_id = tranlog_start.employee_id
    AND t2.wh_id = tranlog_start.wh_id
    -- 联接最后一个交易的详细信息
    LEFT JOIN [PowerBI_Distribution].[TranLog] tranlog_end
    ON t2.last_tran_date_time = CONCAT(CAST(tranlog_end.[end_tran_date] AS DATE), ' ', CAST(tranlog_end.[end_tran_time] AS TIME))
    AND t2.employee_id = tranlog_end.employee_id
    AND t2.wh_id = tranlog_end.wh_id
) t3

-- 选择排名为 1 的记录
WHERE row_number_rank = 1
