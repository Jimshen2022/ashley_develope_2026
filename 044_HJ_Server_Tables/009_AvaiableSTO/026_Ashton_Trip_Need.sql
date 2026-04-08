SELECT orb.item_number,
       SUM(orb.qty) AS trip_needed
FROM   Distribution_Warehouse_Wholesale.LoadMaster ldm
       JOIN Distribution_Warehouse_Wholesale.Orders orm  
         ON ldm.wh_id = orm.wh_id 
        AND ldm.load_id = orm.load_id 
       JOIN Distribution_Warehouse_Wholesale.OrderDetail_breakdown orb
         ON orb.wh_id = ldm.wh_id
        AND orb.order_number = orm.order_number
       LEFT JOIN Distribution_Warehouse_Wholesale.LoadDispatch ldd 
         ON ldd.LoadId = ldm.load_id
        AND ldd.WhId = ldm.wh_id
WHERE ldm.wh_id = '335'
  AND ldm.dispatch_date + ldm.dispatch_time BETWEEN CONVERT(datetime, DATEADD(WEEK, -1, DATEADD(HOUR, 7, GETUTCDATE())))
                                               AND CONVERT(datetime, DATEADD(MONTH, 1, DATEADD(HOUR, 7, GETUTCDATE())))
  AND ldm.status NOT IN ('S', 'X', 'C')
  AND ldm.load_type = 'B'
GROUP  BY orb.item_number
ORDER BY SUM(orb.qty) ASC;




