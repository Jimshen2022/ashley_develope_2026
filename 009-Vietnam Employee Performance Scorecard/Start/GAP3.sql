  SELECT [Tran Type]
      ,[Tran Descript]
      ,[EE Name]
      ,[EE Number]
      ,[Start Trans Datetime]
      ,[End Trans Datetime]
      ,[Supervisor Name]
      ,[Department]
      ,[Warehouse #]
      ,[Date]
      ,[Transaction Qty]
      ,[WorkDay] AS [work_day]
      ,[Start Tran Date] AS [start_tran_date] 
      ,[Start Tran Time] AS [start_tran_time]
      ,[End Tran Date] AS [end_tran_date]
      ,[End Tran Time] AS [_end_tran_time]  -- by Crystal
      , DATEADD(MINUTE, 
                -(DATEPART(MINUTE, [End Tran Time]) % 15), 
                DATEADD(SECOND, 
                        -DATEPART(SECOND, [End Tran Time]), 
                        [End Tran Time])
        ) AS [end_tran_time]  -- Aug.24.2024 - to round the clock out time to the nearest 15 minutes by Jim,Shen 
      ,[COUNT]
      ,[GapTime] AS [Gap_Time]
      ,[ElapsedTime] AS [Elapsed_Time]
      ,[WorkTypeKey]
  FROM [PowerBI_Distribution].[GapTimeReport_EmployeeDetail]
  where [Warehouse #] IN ('335','35')


/*
 DATEADD(MINUTE, 
                -(DATEPART(MINUTE, [End Tran Time]) % 15), 
                DATEADD(SECOND, 
                        -DATEPART(SECOND, [End Tran Time]), 
                        [End Tran Time])
        ) AS rounded_clock_out_time

当然，我很乐意为您详细解释这段 SQL 代码。让我们逐步分析它：

1. 最内层的 `DATEADD` 函数：
   ```sql
   DATEADD(SECOND, -DATEPART(SECOND, [End Tran Time]), [End Tran Time])
   ```
   - 这一步是为了去除秒数。
   - `DATEPART(SECOND, [End Tran Time])` 获取 [End Tran Time] 的秒数。
   - 然后用负号将其变为负值，并通过 `DATEADD` 函数从原时间中减去这些秒。
   - 结果是将时间调整到该分钟的整点，例如 14:23:45 会变成 14:23:00。

2. 中间层的计算：
   ```sql
   DATEPART(MINUTE, [End Tran Time]) % 15
   ```
   - 这一步计算分钟数除以 15 的余数。
   - 例如，如果分钟是 23，那么 23 % 15 = 8。
   - 这个余数告诉我们距离上一个 15 分钟间隔有多远。

3. 外层的 `DATEADD` 函数：
   ```sql
   DATEADD(MINUTE, -(DATEPART(MINUTE, [End Tran Time]) % 15), ...)
   ```
   - 这一步将时间向下调整到最近的 15 分钟间隔。
   - 我们用负号将第 2 步计算的余数变为负值。
   - 然后通过 `DATEADD` 函数将这个负值添加到时间上，实际上是在减去这些分钟。

4. 整体效果：
   - 首先去除秒数，将时间调整到分钟。
   - 然后计算需要减去多少分钟才能达到最近的 15 分钟间隔。
   - 最后执行这个减法操作。

举例说明：
- 如果 [End Tran Time] 是 14:23:45
- 首先变成 14:23:00（去除秒）
- 然后计算 23 % 15 = 8，表示需要向下调整 8 分钟
- 最后得到 14:15:00

这个方法确保了时间总是被舍入到最近的较早的 15 分钟间隔，完全符合您之前描述的需求。

*/