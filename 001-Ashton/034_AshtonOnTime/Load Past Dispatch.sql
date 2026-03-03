/****** ?????loadpassdispatch ******/
SELECT 
    -- ????
    A.[wh_id]
  , A.[load_id]
  , A.[equipment_id]
  , CONCAT(A.[load_id], '-', A.[equipment_id]) AS trip_nbr
  
  -- ???????
  , A.[stage_loc]
  , A.[door_loc]
  , A.[trailer_number]
  
  -- ?????
  , A.[carrier_id]
  , A.[hauling_carrier_id]
  , A.[hauling_carrier]
  
  -- ?????
  , A.[status]
  , A.[shipment_status]
  , A.[trailer_type_id]
  , A.[trip_type_id]
  , A.[load_type]
  
  -- ??????
  , A.[actual_ship_date]
  , A.[actual_delivery_date]
  , A.[load_date]
  , CAST(A.[dispatch_date] AS DATE) AS dispatchdate
  , CAST(A.[dispatch_time] AS TIME) AS dispatchTime
  , CAST(CAST(A.[dispatch_date] AS DATE) AS VARCHAR) + ' ' + 
    CAST(CAST(A.[dispatch_time] AS TIME) AS VARCHAR(8)) AS DispatchDateTime
  
  -- ????
  , DATEDIFF(MINUTE, A.[actual_ship_date], 
             CAST(CAST(A.[dispatch_date] AS DATE) AS VARCHAR) + ' ' + 
             CAST(CAST(A.[dispatch_time] AS TIME) AS VARCHAR(8))) AS TimeDifference
  , CASE 
      WHEN DATEDIFF(MINUTE, A.[actual_ship_date], 
                    CAST(CAST(A.[dispatch_date] AS DATE) AS VARCHAR) + ' ' + 
                    CAST(CAST(A.[dispatch_time] AS TIME) AS VARCHAR(8))) >= 0 
      THEN 1 
      ELSE 0 
    END AS Ontime_Count
  , COUNT(DISTINCT CONCAT(CAST(A.trip_create_date AS DATE), A.load_id)) AS Total_Trip_Count
  
  -- ????
  , A.[trip_create_date]
  , A.[trip_create_time]
  , A.[transfer_wh_id]
  , A.[number_of_drops]
  , A.[destination_as400]
  
  -- ??????
  , A.[ship_from_name]
  , A.[ship_from_addr1]
  , A.[ship_from_addr2]
  , A.[ship_from_addr3]
  , A.[ship_from_city]
  , A.[ship_from_state]
  , A.[ship_from_zip]
  , A.[ship_from_country_code]
  
  -- ???
  , D.[FiscalWeekLastDate]

FROM Distribution_Warehouse_Wholesale.[LoadMaster] A
LEFT JOIN (
    SELECT DISTINCT
        Fiscal_Date
      , Last_Date_Of_Fiscal_Week AS FiscalWeekLastDate
    FROM [PowerBI_Enterprise].[DimDate]
) D ON CAST(A.[actual_ship_date] AS DATE) = D.Fiscal_Date

WHERE A.[wh_id] = '335'
  AND A.[shipment_status] = 'Shipped'
  AND A.[load_id] LIKE '%00'
  AND A.[actual_ship_date] >= '2024-01-01'  -- ??2024-01-01??????

GROUP BY 
    A.[wh_id], A.[load_id], A.[equipment_id]
  , A.[stage_loc], A.[door_loc], A.[trailer_number]
  , A.[carrier_id], A.[hauling_carrier_id], A.[hauling_carrier]
  , A.[status], A.[shipment_status], A.[trailer_type_id]
  , A.[trip_type_id], A.[load_type]
  , A.[actual_ship_date], A.[actual_delivery_date], A.[load_date]
  , A.[dispatch_date], A.[dispatch_time]
  , A.[trip_create_date], A.[trip_create_time]
  , A.[transfer_wh_id], A.[number_of_drops], A.[destination_as400]
  , A.[ship_from_name], A.[ship_from_addr1], A.[ship_from_addr2], A.[ship_from_addr3]
  , A.[ship_from_city], A.[ship_from_state], A.[ship_from_zip], A.[ship_from_country_code]
  , D.[FiscalWeekLastDate];


SELECT TOP 1000 * 
FROM Distribution_Warehouse_Wholesale.[LoadMaster] A 
WHERE A.[wh_id] = '335'
  AND A.[shipment_status] = 'Shipped'
  AND A.[load_id] LIKE '%00'
  AND A.[actual_ship_date] >= '2025-10-11'           -- ??00:00:00
  AND A.[actual_ship_date] < '2025-10-12'            -- ??00:00:00