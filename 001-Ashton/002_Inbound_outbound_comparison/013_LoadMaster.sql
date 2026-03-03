/*-- ldm
status
M
W
S
H
N
I
R
X
*/

-- SELECT count(*) as rows
-- FROM Distribution_Warehouse_Wholesale.LoadMaster t1
-- where t1.wh_id in ('335') and t1.dispatch_date >'2024-11-01' AND t1.load_type = 'B' and t1.status not in ('S','X','C')
--
-- SELECT count(*) as rows_2
-- FROM Distribution_Warehouse_Wholesale.LoadMaster t1
-- where t1.wh_id in ('335') and t1.dispatch_date >'2024-11-01'
--   AND t1.load_type = 'B' and t1.status not in ('S','X','C')

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

SELECT ldm.wh_id,
               ldm.dispatch_date,
               ldm.dispatch_time,
               orb.item_number,
			   ldm.status,
			   isnull(orm.carrier,isnull(c.carrier_name,'')) as carrier,
			   ldm.load_id			as trip_number , ----Grace change
               Sum(orb.qty)         AS trip_needed
        FROM   Distribution_Warehouse_Wholesale.LoadMaster ldm
			   join Distribution_Warehouse_Wholesale.Orders orm on ldm.wh_id=orm.wh_id and ldm.load_id=orm.load_id
			   left join Distribution_Warehouse_Wholesale.Carrier c  on ldm.carrier_id=c.carrier_id
               JOIN Distribution_Warehouse_Wholesale.OrderDetail_breakdown orb (nolock)
                 ON orb.wh_id = ldm.wh_id
				 and orb.order_number=orm.order_number
			  -- join #item  (nolock) on orb.item_number = #item.item_number
				LEFT join Distribution_Warehouse_Wholesale.LoadDispatch ldd  on ldd.load_id =ldm.load_id  AND ldd.wh_id = ldm.wh_id    ---Grace change
        WHERE  (ldm.wh_id = '335')
			   and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
			   AND ldm.status not in ('S','X','C')
               AND ldm.load_type = 'B'
			  -- AND (case when @in_Confirmed='A' then @in_Confirmed else isnull(ldd.dispatch_confirmed,'N') end)= @in_Confirmed  --2019/01/18
        GROUP  BY ldm.wh_id,
                  ldm.dispatch_date,
                  ldm.dispatch_time,
                  orb.item_number,
				  ldm.status,
				  isnull(orm.carrier,isnull(c.carrier_name,'')),
                  ldm.load_id

