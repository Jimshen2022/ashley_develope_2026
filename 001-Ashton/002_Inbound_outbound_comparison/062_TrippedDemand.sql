DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list AS VARCHAR(500);
DECLARE @StartDate DATETIME;
DECLARE @EndDate DATETIME;
DECLARE @in_vchDispatchStartDate DATETIME;
DECLARE @in_vchDispatchEndDate DATETIME;
SET @wh_id_list = '335,335';
SET @tran_list = '151,183,951,321,363,372,347,252,254,262,202';
-- Set @StartDate to the previous day at 7:00:00 AM
SET @StartDate = DATEADD(DAY, -3, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
-- Set @EndDate to today's date at 06:59:59 AM
SET @EndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';
-- SET @EndDate = DATEADD(DAY, -1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '06:59:59.997';

SET @in_vchDispatchStartDate = CAST(DATEADD(DAY, -3, GETDATE()) AS DATE); -- 仅包含前3天的日期部分
SET @in_vchDispatchEndDate = CAST(DATEADD(DAY, +21, GETDATE()) AS DATE);  -- 当前日期，仅日期部分
With ldm as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.LoadMaster a3 where a3.wh_id in ('335') and a3.dispatch_date + a3.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)),
orm as
	(SELECT distinct * FROM Distribution_Warehouse_Wholesale.Orders a4 where a4.wh_id in ('335')),
orb as
(SELECT  * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown a5 where a5.wh_id in ('335')),
ldd as
	(SELECT  * from Distribution_Warehouse_Wholesale.LoadDispatch AS a6 where a6.WhId in ('335')),
pkd as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.PickDetail as a7 where a7.wh_id in ('335')),
sto as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.t_stored_item as a8  WHERE a8.wh_id in ('335')),
loc as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.t_location as a9 where a9.wh_id in ('335'))

-- trip demand
SELECT orb.item_number,  ldm.dispatch_date + ldm.dispatch_time as dispatch, ldm.load_id, ldm.[status] as loadmaster_status, ldm.trip_type_id, ldm.load_type, orm.order_number,  orb.order_number,
	ldd.DispatchConfirmed, orm.[status] as order_status,
				   Sum(orb.qty) AS trip_needed, sum(orb.qty_shipped) as trip_shipped_qty
			FROM   ldm  -- load master
				   JOIN orm   -- t_order
						on ldm.wh_id=orm.wh_id and ldm.load_id=orm.load_id
				   JOIN  orb   -- OrderDetail_breakdown
						ON orb.wh_id = ldm.wh_id AND orb.order_number = orm.order_number
					LEFT JOIN  ldd   -- LoadDispatch
						on ldd.LoadId =ldm.load_id and ldd.WhId = ldm.wh_id
			WHERE
			  ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
			   AND ldm.status not in ('S','X','C')
               AND ldm.load_type = 'B'
			-- 				   AND  orm.[status] IN ( 'N', 'R' )
				 --  AND ldd.DispatchConfirmed IN ('Y')
			GROUP  BY orb.item_number,  ldm.dispatch_date + ldm.dispatch_time, ldm.load_id, ldm.[status], ldm.trip_type_id, ldm.load_type, orm.order_number,  orb.order_number, ldd.DispatchConfirmed,orm.[status]
			HAVING  Sum(orb.qty) - sum(orb.qty_shipped) > 0
