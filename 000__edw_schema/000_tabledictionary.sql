/*
ashley-edw.database.windows.net
ASHLEY_EDW
SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT top 10 * FROM INFORMATION_SCHEMA.TABLES as t 
WHERE t.table_schema ='Distribution_Warehouse_Wholesale' 
	and t.TABLE_NAME LIKE '%tran%'


select top 10 * from dw_developer.tabledictionary
where tpktablename like '%TripAvailableSTO%'

select top 10 * from dw_developer.tabledictionary
where tpktablename like '%ShippedHistoryCubeData%'

SELECT TOP 100 *
FROM ASHLEY_EDW.INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%RefreshRate%'


-- 临时刷新频率映射表（建议你先用 # 临时表测试）
WITH RefreshRateMapping AS (
    SELECT 1 AS tpkRefreshRate, '每 8 小时' AS FrequencyDescription UNION ALL
    SELECT 2, '每 4 小时' UNION ALL
    SELECT 3, '每 3 小时' UNION ALL
    SELECT 4, '每 2 小时' UNION ALL
    SELECT 6, '每小时' UNION ALL
    SELECT 8, '每 30 分钟' UNION ALL
    SELECT 12, '每 20 分钟' UNION ALL
    SELECT 24, '每 15 分钟' UNION ALL
    SELECT 26, '每天 1 次（成本核算）' UNION ALL
    SELECT 48, '每天 2 次（早晚）' UNION ALL
    SELECT 72, '每 20 分钟 (特殊调度)' UNION ALL
    SELECT 96, '每 15 分钟 (快速刷新)' UNION ALL
    SELECT 9999, '未知 / 手动触发'
)

-- 你可以根据实际值调整上面内容
-- 然后我们和 TableDictionary 做 JOIN 分析
SELECT
    td.tpkDatabaseName,
    td.tpkSchemaName,
    td.tpkTableName,
    td.tpkJobName,
    td.tpkRefreshRate,
    rrm.FrequencyDescription AS RefreshFrequency,
    td.tpkRowCount,
    td.tpkUpdateMethod,
    td.tpkCreateDate,
    td.tpkModified
FROM
    DW_Developer.TableDictionary td
LEFT JOIN
    RefreshRateMapping rrm ON td.tpkRefreshRate = rrm.tpkRefreshRate
ORDER BY
    td.tpkRefreshRate, td.tpkTableName;

*/


-- Step 1: Define a common refresh rate mapping table
-- You can turn this into a permanent table if needed
WITH RefreshRateMapping AS (
    SELECT 1 AS tpkRefreshRate, 'Every 8 hours' AS FrequencyDescription UNION ALL
    SELECT 2, 'Every 4 hours' UNION ALL
    SELECT 3, 'Every 3 hours' UNION ALL
    SELECT 4, 'Every 2 hours' UNION ALL
    SELECT 6, 'Every 1 hour' UNION ALL
    SELECT 8, 'Every 30 minutes' UNION ALL
    SELECT 12, 'Every 20 minutes' UNION ALL
    SELECT 24, 'Every 15 minutes' UNION ALL
    SELECT 26, 'Once per day (e.g. CostAccounting)' UNION ALL
    SELECT 48, 'Twice per day (morning/evening)' UNION ALL
    SELECT 72, 'Every 20 minutes (special jobs)' UNION ALL
    SELECT 96, 'Every 15 minutes (fast refresh)' UNION ALL
    SELECT 9999, 'Unknown / Manual Trigger'
)

-- Step 2: Join the mapping to the main TableDictionary to analyze each table's refresh frequency
SELECT
    td.tpkDatabaseName,
    td.tpkSchemaName,
    td.tpkTableName,
    td.tpkJobName,
    td.tpkRefreshRate,
    rrm.FrequencyDescription AS RefreshFrequency,
    td.tpkRowCount,
    td.tpkUpdateMethod,
    td.tpkCreateDate,
    td.tpkModified
FROM
    DW_Developer.TableDictionary td
LEFT JOIN
    RefreshRateMapping rrm ON td.tpkRefreshRate = rrm.tpkRefreshRate
where td.tpkSchemaName = 'Distribution_Warehouse_Wholesale'
ORDER BY
    td.tpkRefreshRate, td.tpkTableName;



