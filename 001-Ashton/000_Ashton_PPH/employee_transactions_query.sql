DECLARE @cols      NVARCHAR(MAX);
DECLARE @total_col NVARCHAR(MAX);
DECLARE @sql       NVARCHAR(MAX);

-- 步骤 1：按日期升序生成列名列表
SELECT
    @cols      = STRING_AGG(QUOTENAME(d_str), ', ') WITHIN GROUP (ORDER BY d ASC),
    @total_col = STRING_AGG('ISNULL(' + QUOTENAME(d_str) + ', 0)', ' + ') WITHIN GROUP (ORDER BY d ASC)
FROM (
    SELECT DISTINCT
        CAST(start_tran_date AS DATE)                    AS d,
        CONVERT(VARCHAR(10), start_tran_date, 120)         AS d_str
    FROM t_tran_log
    WHERE employee_id   = '50425'
      AND start_tran_date >= '2026-06-01'
) t;

-- 步骤 2：拼接 SQL（ORDER BY tran_type + 日期升序列 + total）
SET @sql = N'
SELECT
    tran_type,
    description,
    employee_id,
    ' + @cols + N',
    (' + @total_col + N') AS total
FROM (
    SELECT
        tran_type,
        description,
        employee_id,
        CONVERT(VARCHAR(10), start_tran_date, 120) AS tran_date,
        tran_qty
    FROM t_tran_log
    WHERE employee_id      = ''50425''
      AND start_tran_date >= ''2026-06-01''
) src
PIVOT (
    SUM(tran_qty) FOR tran_date IN (' + @cols + N') 
) pvt
ORDER BY tran_type ASC;';   -- ① tran_type 升序
                              -- ② 日期列已在 @cols 中按升序排好
                              -- ③ total 列在最右

EXEC sp_executesql @sql;