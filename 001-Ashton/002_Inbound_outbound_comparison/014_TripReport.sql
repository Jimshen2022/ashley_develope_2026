Select *
from Distribution_Warehouse_Wholesale.TripReport as t1
where t1.WhID in ('335') and t1.TripStatus not in ('S','X')
	and t1.LoadID in ('0032184-00','0040646-00')

Select top 10 *  from Distribution_Warehouse_Wholesale.OrderDetail_breakdown as t1 where t1.wh_id in ('335')

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
		and t1.order_number in ('0032184-00','0040646-00')
  );


Select top 10 * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown_CDC as t1 where t1.wh_id in ('335')
Select top 10 * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown_Snapshot as t1 where t1.wh_id in ('335')
Select top 10 * from Distribution_Warehouse_Wholesale.orderCNumber as t1 where t1.wh_id in ('335')


Select  count(*)  from Distribution_Warehouse_Wholesale.OrderDetail_breakdown_CDC as t1 where t1.wh_id in ('335')
Select  count(*)  from Distribution_Warehouse_Wholesale.OrderDetail_breakdown_Snapshot as t1 where t1.wh_id in ('335')
Select  count(*)  from Distribution_Warehouse_Wholesale.orderCNumber as t1 where t1.wh_id in ('335')

Select  top 10 * from Distribution_Warehouse_Wholesale.Order_Detail  as t1 where t1.wh_id in ('335')

Select   *
from Distribution_Warehouse_Wholesale.LoadDispatch as t1
WHERE t1.WhId in ('335')

Select  top 10 *
from Distribution_Warehouse_Wholesale.Order_Detail AS T1
where t1.wh_id = '335'


