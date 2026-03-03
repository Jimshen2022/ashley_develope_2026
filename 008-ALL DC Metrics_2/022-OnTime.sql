SELECT d.[wh_id]
     , cast(d.[actual_ship_date] as date) AS [Date]
     , Sum(d.Ontime_Count) AS [On Time Trips]
     , COUNT(CONCAT(CAST(trip_create_date AS DATE), load_id)) AS Total_Trip_Count
     , d.[Last_Date_Of_Fiscal_Week]
FROM
(
    SELECT a.[wh_id]
         , a.[load_id]
         , a.[stage_loc]
         , a.[door_loc]
         , a.[carrier_id]
         , c.[carrier_name]
         , a.[trailer_type_id]
         , a.[status]
         , a.[trailer_number]
         , a.[shipment_status]
         , a.[actual_ship_date]
         , a.[actual_delivery_date]
         , a.[equipment_id]
         , a.[load_date]
         , a.dispatchdate
         , a.dispatchTime
         , CAST(CONCAT(dispatchdate, ' ', SUBSTRING(CAST(dispatchTime AS VARCHAR), 1, 8)) AS DATETIME) AS DispatchDateTime
         , DATEDIFF(
                       minute, [actual_ship_date]
                     , CAST(CONCAT(dispatchdate, ' ', SUBSTRING(CAST(dispatchTime AS VARCHAR), 1, 8)) AS DATETIME)
                   )                                                                                   AS TimeDifference
         , CASE
               WHEN DATEDIFF(
                                MINUTE, [actual_ship_date]
                              , CAST(CONCAT(dispatchdate, ' ', SUBSTRING(CAST(dispatchTime AS VARCHAR), 1, 8)) AS DATETIME)
                            ) >= 0 THEN
                   1
               ELSE
                   0
           END                                                                                         AS Ontime_Count
         , a.[trip_type_id]
         , a.[load_type]
         , a.[trip_create_date]
         , a.[trip_create_time]
         , a.[transfer_wh_id]
         , a.[number_of_drops]
         , a.[destination_as400]
         , a.[hauling_carrier_id]
         , a.[hauling_carrier]
         , a.[ship_from_name]
         , a.[ship_from_addr1]
         , a.[ship_from_addr2]
         , a.[ship_from_addr3]
         , a.[ship_from_city]
         , a.[ship_from_state]
         , a.[ship_from_zip]
         , a.[ship_from_country_code]
         , a.[Last_Date_Of_Fiscal_Week]
    FROM
    (
        SELECT DISTINCT
               [wh_id]
             , [load_id]
             , [stage_loc]
             , [door_loc]
             , [carrier_id]
             , [trailer_type_id]
             , [status]
             , [trailer_number]
             , [shipment_status]
             , [actual_ship_date]
             , [actual_delivery_date]
             , [equipment_id]
             , [load_date]
             , CAST([dispatch_date] AS DATE) AS dispatchdate
             , CAST([dispatch_time] AS TIME) AS dispatchTime
             , [trip_type_id]
             , [load_type]
             , [trip_create_date]
             , [trip_create_time]
             , [transfer_wh_id]
             , [number_of_drops]
             , [destination_as400]
             , [hauling_carrier_id]
             , [hauling_carrier]
             , [ship_from_name]
             , [ship_from_addr1]
             , [ship_from_addr2]
             , [ship_from_addr3]
             , [ship_from_city]
             , [ship_from_state]
             , [ship_from_zip]
             , [ship_from_country_code]
             , b.[Last_Date_Of_Fiscal_Week]
        FROM [PowerBI_ADS].[LoadMaster] A
            LEFT JOIN
            (
                SELECT DISTINCT
                       [Fiscal_Date]
                     , [Last_Date_Of_Fiscal_Week]
                FROM [PowerBI_Enterprise].[DimDate]
            )                                                b
                ON CAST(A.[actual_ship_date] AS DATE) = CAST(b.[Fiscal_Date] AS DATE)
        WHERE CAST([actual_ship_date] AS DATE)
              BETWEEN DATEADD(day, -200, GETDATE()) AND GETDATE()
              AND [shipment_status] = 'Shipped'
              AND RIGHT([load_id], 2) = '00'
              AND [trip_type_id] IN ('T','F','R')
    )     A
        LEFT JOIN
        (
            SELECT DISTINCT
                   [wh_id]
                 , [carrier_id]
                 , [carrier_name]
            FROM [PowerBI_ADS].[Carrier]
        ) C
            ON A.[carrier_id] = C.[carrier_id]
               AND A.[wh_id] = C.[wh_id]
) d
WHERE NOT (
            door_loc LIKE '%a' OR door_loc LIKE '%b'
          )
GROUP BY 
      d.[wh_id]
     , cast(d.[actual_ship_date] as date)
     , d.[Last_Date_Of_Fiscal_Week]