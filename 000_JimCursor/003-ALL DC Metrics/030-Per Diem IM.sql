Select
a.wh_id
,sum(Per_diem_Expense) AS Per_Diem_$
,count(per_diem_expense) AS Per_Diem_Trailers
FROM
(

SELECT 
  [trailer_id],
  [status],
  [state],
  [carrier_trailer_number],
  [location_id],
  [entered_yard],
  CAST([entered_yard] AS DATE) AS Date_Entered_Yard,
  DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) AS DAYS_IN_YARD,
  --'30' AS Dwell_dollars_per_day,
  --'3' AS Free_days,
  CASE 
    WHEN DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) <= 5 THEN null
    WHEN DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) > 5 
      AND DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) <= 11 THEN (DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) - 5) * 75
    when DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) > 11 THEN ((DATEDIFF(DAY, CAST([entered_yard] AS DATE), GETDATE()) - 11)*100)+(6*75)
    -- Add additional conditions here if necessary
  END AS Per_Diem_Expense,
  [exited_yard],
  [equipment_id],
  [area_id],
  [asn_id],
  [wh_id],
  [LoadDate]
FROM 
  [PowerBI_Distribution].[WRKTrailer]
WHERE 
  entered_yard > '2020-01-01'
  AND exited_yard IS NULL
  AND NOT (status = 'HISTORY' OR status = 'LOST')
  AND ([state] LIKE 'IN FULL%' OR [state] LIKE 'IN PARTIAL%')
  AND (equipment_id LIKE 'HGIU%' OR equipment_id LIKE 'HGWU%')
--ORDER BY 
--  [entered_yard],
--  [exited_yard],
--  [equipment_id];
)a
group by a.WH_ID