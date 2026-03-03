/****** Object:  View [PowerBI_Distribution].[loadpassdispatch]    Script Date: 8/23/2022 9:31:16 AM ******/
SELECT d.[wh_id]
     , d.[load_id]
     , d.[stage_loc]
     , d.[door_loc]
     , d.[carrier_id]
     , d.[carrier_name]
     , d.[trailer_type_id]
     , d.[status]
     , d.[trailer_number]
     , d.[shipment_status]
     , d.[actual_ship_date]
     , d.[actual_delivery_date]
     , d.[equipment_id]
     , d.[load_date]
     , d.dispatchdate
     , d.dispatchTime
     , d.DispatchDateTime
     , d.TimeDifference
     , d.Ontime_Count
     , COUNT(CONCAT(CAST(trip_create_date AS DATE), load_id)) AS Total_Trip_Count
     , d.[trip_type_id]
     , d.[load_type]
     , d.[trip_create_date]
     , d.[trip_create_time]
     , d.[transfer_wh_id]
     , d.[number_of_drops]
     , d.[destination_as400]
     , d.[hauling_carrier_id]
     , d.[hauling_carrier]
     , d.[ship_from_name]
     , d.[ship_from_addr1]
     , d.[ship_from_addr2]
     , d.[ship_from_addr3]
     , d.[ship_from_city]
     , d.[ship_from_state]
     , d.[ship_from_zip]
     , d.[ship_from_country_code]
     , d.[FiscalWeekLastDate]
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
         --,COUNT(CONCAT(CAST(trip_create_date AS DATE),load_id)) AS "Total Trip Count"
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
         , a.[FiscalWeekLastDate]
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
             , b.[FiscalWeekLastDate]
        FROM Distribution_Warehouse_Wholesale.[LoadMaster] A
            LEFT JOIN
            (
                SELECT DISTINCT
                       Fiscal_Date as [FiscalDate]
                     , Last_Date_Of_Fiscal_Week as [FiscalWeekLastDate]
                FROM [PowerBI_Enterprise].[DimDate]
            )                                                b
                ON CAST(A.[actual_ship_date] AS DATE) = CAST(b.[FiscalDate] AS DATE)
        WHERE CAST([actual_ship_date] AS DATE)
              BETWEEN DATEADD(YEAR, -2, GETDATE()) AND GETDATE()
              AND [shipment_status] = 'Shipped'
              AND RIGHT([load_id], 2) = '00'
    --AND [load_id]='0003542-00'
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
GROUP BY d.[wh_id]
       , d.[load_id]
       , d.[stage_loc]
       , d.[door_loc]
       , d.[carrier_id]
       , d.[carrier_name]
       , d.[trailer_type_id]
       , d.[status]
       , d.[trailer_number]
       , d.[shipment_status]
       , d.[actual_ship_date]
       , d.[actual_delivery_date]
       , d.[equipment_id]
       , d.[load_date]
       , d.dispatchdate
       , d.dispatchTime
       , d.DispatchDateTime
       , d.TimeDifference
       , d.Ontime_Count
       , d.[trip_type_id]
       , d.[load_type]
       , d.[trip_create_date]
       , d.[trip_create_time]
       , d.[transfer_wh_id]
       , d.[number_of_drops]
       , d.[destination_as400]
       , d.[hauling_carrier_id]
       , d.[hauling_carrier]
       , d.[ship_from_name]
       , d.[ship_from_addr1]
       , d.[ship_from_addr2]
       , d.[ship_from_addr3]
       , d.[ship_from_city]
       , d.[ship_from_state]
       , d.[ship_from_zip]
       , d.[ship_from_country_code]
       , d.[FiscalWeekLastDate];