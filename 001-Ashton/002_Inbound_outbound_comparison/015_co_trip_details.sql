SELECT  *
FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown AS t1
WHERE t1.wh_id IN ('335') 
  AND EXISTS (
      SELECT 1
      FROM (
          SELECT CAST(SUBSTRING(a1.LoadID, 1, 7) AS VARCHAR(50)) AS LoadID
          FROM Distribution_Warehouse_Wholesale.TripReport AS a1
          WHERE a1.WhID IN ('335') AND a1.TripStatus NOT IN ('S', 'X')
      ) AS a2
      WHERE a2.LoadID = CAST(SUBSTRING(t1.order_number, 1, 7) AS VARCHAR(50))
  );