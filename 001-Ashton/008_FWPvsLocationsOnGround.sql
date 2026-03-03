SELECT *
FROM Distribution_Warehouse_Wholesale.t_location as t1
WHERE t1.wh_id IN ('335') AND t1.location_id LIKE 'A3%1' AND t1.TypeDescription IN ('P','I','X','A') AND t1.pick_area NOT IN ('UPHOLSTERY')


SELECT  *
from Distribution_Warehouse_Wholesale.t_forward_pick as t1
Where t1.Wh_Id in ('335') and t1.LocationId not in ('A1001AA9','A1001AA9')