WITH pick AS (
    SELECT
        [tran_type]
        ,[start_tran_date]
        ,[start_tran_time]
        ,[employee_id]
        ,[wh_id]
        ,[item_number]
        ,[lot_number]
        ,[tran_qty]
        ,[location_id]
        ,[control_number_2]
        ,DENSE_RANK() OVER (
            PARTITION BY [lot_number]
            ORDER BY CONCAT(CAST([end_tran_date] AS NVARCHAR), CAST([end_tran_time] AS NVARCHAR)) DESC
        ) AS rank_info
    FROM [PowerBI_Distribution].[TranLog]
    WHERE [tran_type] = '231'
      --AND [wh_id] = '1'
    GROUP BY
        [tran_type]
        ,[start_tran_date]
        ,[start_tran_time]
        ,[employee_id]
        ,[wh_id]
        ,[item_number] 
        ,[lot_number]
        ,[tran_qty]
        ,[location_id]
        ,[control_number_2]
	    ,[end_tran_date]
		,[end_tran_time]
),
put AS (
    SELECT
        [tran_type]
        ,[start_tran_date]
        ,[start_tran_time]
        ,[employee_id]
        ,[wh_id]
        ,[item_number]
        ,[lot_number]
        ,[tran_qty]
        ,[location_id_2]
        ,[control_number_2]
        ,[end_tran_date]
        ,[end_tran_time]
        ,DENSE_RANK() OVER (
            PARTITION BY [lot_number]
            ORDER BY CONCAT(CAST([end_tran_date] AS NVARCHAR), CAST([end_tran_time] AS NVARCHAR)) DESC
        ) AS rank_info
    FROM [PowerBI_Distribution].[TranLog]
    WHERE [tran_type] = '232'
      --AND [wh_id] = '1'
    GROUP BY
        [tran_type]
        ,[start_tran_date]
        ,[start_tran_time]
        ,[employee_id]
        ,[wh_id]
        ,[item_number]
        ,[lot_number]
        ,[tran_qty] 
        ,[location_id_2]
        ,[control_number_2]
		,[end_tran_date]
		,[end_tran_time]
)
,
closed AS (   SELECT
        [tran_type]
        ,[start_tran_date]
        ,[start_tran_time]
        ,[employee_id]
        ,[wh_id]
        ,[item_number]
        ,[lot_number]
        ,[tran_qty]
        ,[location_id_2]
        ,[control_number_2]
        ,[end_tran_date]
        ,[end_tran_time]
        ,DENSE_RANK() OVER (
            PARTITION BY [lot_number]
            ORDER BY CONCAT(CAST([end_tran_date] AS NVARCHAR), CAST([end_tran_time] AS NVARCHAR)) DESC
        ) AS rank_info
    FROM [PowerBI_Distribution].[TranLog]
    WHERE [tran_type] = '230'
      --AND [wh_id] = '1'
    GROUP BY
        [tran_type]
        ,[start_tran_date]
        ,[start_tran_time]
        ,[employee_id]
        ,[wh_id]
        ,[item_number]
        ,[lot_number]
        ,[tran_qty] 
        ,[location_id_2]
        ,[control_number_2]
		,[end_tran_date]
		,[end_tran_time]
)
,
details as (SELECT
    pick.[tran_type]
    ,cast(pick.[start_tran_date] AS date) AS [Start Tran Date]
    ,cast(pick.[start_tran_time] AS time) AS [Start Tran Time]
    ,cast(put.[end_tran_date] AS date) AS [End Tran Date]
    ,cast(put.[end_tran_time] AS time) AS [End Tran Time]
    ,pick.[employee_id]
    ,pick.[wh_id]
    ,pick.[item_number]
    ,pick.[lot_number]
    ,pick.[tran_qty]
    ,pick.[location_id] as [From Location]
    ,put.[location_id_2] as [To Location]
    ,put.[control_number_2] as [Control Number]
	,closed.end_tran_date as [trip closed date]
		  ,c.AFIFinanceDivision
      ,c.AFISalesDivision
      ,c.ItemClassCode
      ,c.SellableItemFlag
	  ,c.itemgrouping
	  ,c.associationcode
	  ,d.UUCCIM
	  ,b.[UCDEF]
FROM pick
INNER JOIN put
    ON pick.rank_info = put.rank_info
    AND pick.employee_id = put.employee_id
    AND pick.lot_number = put.lot_number
    AND pick.wh_id = put.wh_id
INNER JOIN closed
    ON pick.rank_info = put.rank_info
    AND pick.lot_number = closed.lot_number
    AND pick.wh_id = closed.wh_id
	AND put.control_number_2 = closed.control_number_2
      left join [PowerBI_Distribution].[ITEMASA] b
    on pick.[item_number]=b.itnbr
	LEFT JOIN [PowerBI_Distribution].[Dimitemmaster] c
	on pick.[item_number] = c.ItemSKU
	LEFT Join [PowerBI_Wholesale].[ITMEXT]d
	on pick.[item_number] = d.itnbr
WHERE pick.rank_info = '1'
and cast(pick.[start_tran_date] AS date)>'2024-04-18'
)
Select
details.[trip closed date]
,details.[wh_id]
,sum(details.[tran_qty]) AS [Total Pcs]
,sum(details.[UCDEF]) AS [Total $]
from details
group by
details.[trip closed date]
,details.[wh_id]