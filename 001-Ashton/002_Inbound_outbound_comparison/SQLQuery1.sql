DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list AS VARCHAR(500);
DECLARE @StartDate DATETIME;
DECLARE @EndDate DATETIME;
SET @wh_id_list = '335,335';
SET @tran_list = '151,183,951,321,363,372,347,252,254,262,202';
-- Set @StartDate to the previous day at 7:00:00 AM
SET @StartDate = DATEADD(DAY, -3, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
-- Set @EndDate to today's date at 06:59:59 AM
SET @EndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';
-- SET @EndDate = DATEADD(DAY, -1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '06:59:59.997';


-- STO
SELECT  sto.item_number, MIN(sto.location_id), sto.actual_qty
FROM (SELECT * FROM Distribution_Warehouse_Wholesale.t_stored_item as a0  WHERE a0.wh_id IN (SELECT trim(value) FROM string_split(@wh_id_list, ','))) AS sto
JOIN  (SELECT * FROM Distribution_Warehouse_Wholesale.t_location as a1 where a1.wh_id in (SELECT trim(value) FROM string_split(@wh_id_list, ','))) AS loc
 	ON loc.location_id = sto.location_id AND loc.TypeDescription IN ('I', 'M', 'Y', 'X','P') AND loc.wh_id = sto.wh_id	
JOIN  (SELECT * FROM Distribution_Warehouse_Wholesale.t_item_master AS a2 where a2.wh_id in (SELECT trim(value) FROM string_split(@wh_id_list, ','))) AS itm 
	ON sto.item_number = itm.item_number AND itm.pick_put_id LIKE '%' AND sto.wh_id = itm.wh_id
GROUP BY sto.item_number, sto.actual_qty
ORDER BY sto.item_number

-- trip needed
SELECT orb.item_number,
               Sum(orb.qty) AS trip_needed
        FROM   (SELECT * FROM Distribution_Warehouse_Wholesale.LoadMaster a3 where a3.wh_id in (SELECT trim(value) FROM string_split(@wh_id_list, ','))) AS ldm 
			   join (SELECT * FROM Distribution_Warehouse_Wholesale.t_order a4 where a4.wh_id in (SELECT trim(value) FROM string_split(@wh_id_list, ','))) AS  orm  
					on ldm.wh_id=orm.wh_id and ldm.load_id=orm.load_id 
               JOIN (SELECT * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown a5 where a5.wh_id in (SELECT trim(value) FROM string_split(@wh_id_list, ','))) as orb
                 ON orb.wh_id = ldm.wh_id
                    AND orb.order_number = orm.order_number
				LEFT join t_load_dispatch ldd (nolock) on ldd.load_id =ldm.load_id and ldd.wh_id=ldm.wh_id ---Grace change
        WHERE  ldm.wh_id = @in_vchWhID
			   and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
               AND ldm.status NOT IN ( 'S', 'X', 'C' )
               AND ldm.load_type = 'B'
			   AND (case when @in_Confirmed='A' then @in_Confirmed else isnull(ldd.dispatch_confirmed,'N') end)= @in_Confirmed  --2019/01/18
        GROUP  BY orb.item_number) as a 
       LEFT JOIN (SELECT pkd.item_number,
                         Sum(pkd.picked_quantity) AS picked_qty
                  FROM   t_load_master (nolock) ldm
                         JOIN t_pick_detail (nolock) pkd
                           ON ldm.load_id = pkd.load_id
							AND ldm.wh_id = pkd.wh_id
				LEFT join t_load_dispatch ldd (nolock) on ldd.load_id =ldm.load_id and ldd.wh_id=ldm.wh_id ---Grace change
                  WHERE  ldm.wh_id = @in_vchWhID
						 and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
                         AND ldm.status NOT IN ( 'S', 'X', 'C' ) 
                         AND ldm.load_type = 'B'
						  AND (case when @in_Confirmed='A' then @in_Confirmed else isnull(ldd.dispatch_confirmed,'N') end)= @in_Confirmed  --2019/01/18
                  GROUP  BY pkd.item_number) b
              ON a.item_number = b.item_number
       LEFT JOIN (SELECT sto.item_number,
                         Sum(sto.actual_qty) AS avaiable_qty
                  FROM   t_stored_item (nolock) sto
                         JOIN t_location (nolock) loc
                           ON sto.location_id = loc.location_id
							AND sto.wh_id = loc.wh_id
                  WHERE  sto.wh_id =@in_vchWhID
                         AND sto.type = 'STORAGE'
                         AND sto.actual_qty > 0
                         AND loc.type IN ( 'I', 'M', 'P','X' )
	                     AND loc.building =case when @in_vchFWP='Y' then @v_vchBuilding else loc.building end
						 AND sto.status='A'
                  GROUP  BY sto.item_number) c
              ON a.item_number = c.item_number


--SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.t_control
--SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.t_location
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.LoadMaster where wh_id in ('335')
SELECT TOP 10  wh_id FROM  Distribution_Warehouse_Wholesale.t_order where wh_id in ('335')
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown  where wh_id in ('335')

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 't_order';
