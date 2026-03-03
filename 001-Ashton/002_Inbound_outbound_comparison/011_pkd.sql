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
	(SELECT  * FROM Distribution_Warehouse_Wholesale.Orders a4 where a4.wh_id in ('335')),
orb as
(SELECT  * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown a5 where a5.wh_id in ('335')),
ldd as
	(SELECT  * from Distribution_Warehouse_Wholesale.LoadDispatch AS a6 where a6.WhId in ('335')),
pkd as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.PickDetail as a7 where a7.wh_id in ('335'))

SELECT pkd.item_number,
    Sum(pkd.picked_quantity) AS picked_qty
FROM   ldm
     JOIN pkd
       ON ldm.load_id = pkd.load_id
        AND ldm.wh_id = pkd.wh_id
LEFT join ldd on ldd.LoadId =ldm.load_id and ldd.WhId=ldm.wh_id
WHERE  ldm.wh_id = '335'
     and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
     AND ldm.status NOT IN ( 'S', 'X', 'C' )
     AND ldm.load_type = 'B'
GROUP  BY pkd.item_number