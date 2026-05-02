select top 10 * from t_stored_item

select item_number, location_id, sum(actual_qty) as total_actual_qty
from t_stored_item
where wh_id = '335' and location_id like 'A3%' and actual_qty > 0
	AND item_number in ('2490438','9510439','B251-94','B984-94','B1199-82','B735-95','U2710515','B129-82','W781-68','9810366','M75X32','B944-58','D647-25','B192-53','B660-57','B777-57','B822-31','EW0200-127','9810317','M52531','100-54','M14231','A8000327','2810535','1440446','M72731','5020577','D634-01','M1X1272','M91X32','A2000663','A2000663','A8010291','A2000683','B267-92','A8010370','A8010370','A8000263','L204174','A2000753','M1B0131','A2000553','L734341','A2000487','M1X1102B','M1X3102B','A2000631','L000978','L734402','A2000587')
	group by item_number, location_id


select location_id, sum(actual_qty) as total_actual_qty
from t_stored_item
where wh_id = '335' and location_id like 'A3%' and actual_qty > 0
group by location_id