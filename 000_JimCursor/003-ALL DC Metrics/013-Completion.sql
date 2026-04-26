SELECT DISTINCT
       load_dispatch.wh_id
     , load_dispatch.load_id
     , load_dispatch.trip_num
     , load_dispatch.trip_type_id
     , load_dispatch.shipment_status
     , load_dispatch.trip_create_date
     , load_dispatch.load_date
     , load_dispatch.dispatchdate
     , load_dispatch.DispatchDateTime
     , load_dispatch.actual_ship_date
	 , load_dispatch.door_loc
	 ,load_dispatch.[type of load]
     , truck_loading.PiecesRouted
     , truck_loading.PiecesLoaded
     , truck_loading.PiecesRemaining
     , truck_loading.[% pieces complete]                                                  AS pieces_complete_percentage
     , truck_loading.Cubes
     , truck_loading.[Cubes Loaded]
     , truck_loading.[% cube Complete]                                                    AS cube_complete_percentage
	 ,case when truck_loading.[Cubes Loaded]>='1700' then 'Yes' else 'No' end as [1700 plus cube flag]
	 ,case when truck_loading.[% pieces complete] = '100.00' then 'Yes' else 'No' end as [Shipped 100% flag]
	 ,case when truck_loading.[Cubes Loaded]>='2500' then 'Yes' else 'No' end as [2500 plus cube flag]
	 ,case when load_dispatch.trip_type_id='T' or load_dispatch.trip_type_id='F' then 'Yes' else 'No' end as [Billable cubes shipped flag]
FROM
(
    SELECT wh_id
         , load_id
         , CAST(SUBSTRING(load_id, 1, PATINDEX('%-%', load_id + '-') - 1) AS INTEGER) trip_num
         , carrier_id
         , carrier_name
		 ,door_loc
		 ,case when wh_id = '15' and door_loc like 'D%A' or door_loc like 'D%B' then 'Straights' else 'Non-Straights' end as [type of load]
         , equipment_id
         , trailer_type_id
         , trailer_number
         , shipment_status
         , actual_ship_date
         , actual_delivery_date
         , load_date
         , dispatchdate
         , dispatchTime
         , DispatchDateTime
         , TimeDifference                                                             TimeDifferenceInMins
         , Ontime_Count
         , Total_Trip_Count
         , trip_type_id
         , load_type
         , trip_create_date
         , trip_create_time
         , transfer_wh_id
         , number_of_drops
         , hauling_carrier
         , ship_from_name
         , ship_from_addr1
         , ship_from_city
         , ship_from_state
         , ship_from_zip
         , ship_from_country_code
         , FiscalWeekLastDate
    FROM PowerBI_Distribution.loadpassdispatch
    WHERE dispatchdate > DATEADD(DAY, -45, GETDATE())
          AND ship_from_country_code = 'USA'
          and hauling_carrier <> 'null'
)     load_dispatch

    -------------------------------------------------------------------
    --bringing the truck loading details
    INNER JOIN
    (
        SELECT Warehouse
             , Region
             , Trip#
             , TripCreateDate
             , DispatchDate
             , LatestDeliverDate
             , TripStatus
             , Carrier
             , PiecesRouted
             , PiecesLoaded
             , PiecesRemaining
             , ISNULL(try_cast(REPLACE([% Complete], '%', '') AS numeric(5, 2)), 0) [% pieces complete]
             , Cubes
             , ISNULL([Cubes Loaded], 0)                                            [Cubes Loaded]
             , CONVERT(NUMERIC(15, 2), (ISNULL([Cubes Loaded] / Cubes, 0) * 100))   [% cube Complete]
			
        FROM PowerBI_Distribution.Transportation_TruckLoads
        WHERE 
            CAST(dispatchdate AS DATE) > DATEADD(DAY, -45, GETDATE())
    ) truck_loading
        ON (
               try_CAST(truck_loading.DispatchDate AS DATE) = try_CAST(load_dispatch.dispatchdate AS DATE)
               OR try_CAST(truck_loading.TripCreateDate AS DATE) = try_CAST(load_dispatch.trip_create_date AS DATE) -- couple of trip num 26166, 27585 seems to have different dispatch date so trip create date used
           )
           AND truck_loading.Trip# = load_dispatch.trip_num
           AND truck_loading.Warehouse = load_dispatch.wh_id