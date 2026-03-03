
select  * 
from  Manufacturing_Maximo.WorkOrder as t 
where t.siteid = 'VNM.ASPM' 
	and t.woclass = 'WORKORDER'  
order by t.reportdate desc


WITH base_data AS (
	SELECT DISTINCT
		t.status,
		YEAR(t.reportdate) AS report_year,
		MONTH(t.reportdate) AS report_month,
		t.wonum
	FROM Manufacturing_Maximo.WorkOrder t
	WHERE 
		t.siteid = 'VNM.ASPM'
		AND t.woclass = 'WORKORDER'
),
pivot_data AS (
	SELECT 
		status,
		report_year,
		ISNULL([1], 0) AS Jan,
		ISNULL([2], 0) AS Feb,
		ISNULL([3], 0) AS Mar,
		ISNULL([4], 0) AS Apr,
		ISNULL([5], 0) AS May,
		ISNULL([6], 0) AS Jun,
		ISNULL([7], 0) AS Jul,
		ISNULL([8], 0) AS Aug,
		ISNULL([9], 0) AS Sep,
		ISNULL([10], 0) AS Oct,
		ISNULL([11], 0) AS Nov,
		ISNULL([12], 0) AS Dec
	FROM base_data
	PIVOT (
		COUNT(wonum)
		FOR report_month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
	) AS p
)
SELECT 
	*, 
	-- 年度合计
	Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec AS Total,
	
	-- 每月占比（保留一位小数）
	CAST(100.0 * Jan / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Jan_pct,
	CAST(100.0 * Feb / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Feb_pct,
	CAST(100.0 * Mar / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Mar_pct,
	CAST(100.0 * Apr / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Apr_pct,
	CAST(100.0 * May / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS May_pct,
	CAST(100.0 * Jun / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Jun_pct,
	CAST(100.0 * Jul / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Jul_pct,
	CAST(100.0 * Aug / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Aug_pct,
	CAST(100.0 * Sep / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Sep_pct,
	CAST(100.0 * Oct / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Oct_pct,
	CAST(100.0 * Nov / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Nov_pct,
	CAST(100.0 * Dec / NULLIF(Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, 0) AS DECIMAL(5,1)) AS Dec_pct
FROM pivot_data
ORDER BY status, report_year;
