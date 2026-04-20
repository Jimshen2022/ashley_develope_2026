/********************************************************************************
 *    Company			: Ashley Furniture Industries								
 *    System   			: HighJump  		 
 *    Module			:  									
 *    Procedure			: usp_trip_available_sto			  
 *    Author			: Dolly Lv
 *    Date				: 10/24/2012 
 *	  Version			: 1.0							
 *    Description		: for Ron's request for check trip needlist item WA-page-1423/1424 (copy from Grace's SQL)
 *						   
 *    Modification Log  : Date 	        Modified By 	  Description
 *						  2012-11-30    Jeson Ye          optimize(Change variable table to temp table for temp_demand)
 *						  2012-12-19	Grace Liu		  add mfg schedule plan produce qty  
 *						  2013-01-22	Grace Liu		  fix billable trip doesn't include X, C     
 *						  2014-01-17    Grace Liu		  add another request only show negative item information from Ron                                   
 *              2014-06-11    Annie Liu         Add FP fillter to the report      
 *              2014/10/13    Sonia Xu            Multi - Warehouse ID  
 *						  2016/07/05    Grace Liu		  add summary page   on 7/15 still need to add more columns     
 *						  2016/08/26	Grace Liu		  add two more column and adjust affect trips count logical       
 *						  2018/11/21	Lily Wei		  DMND0134334 Trip available STO report add control if bounded warehouse is turn on
 *						  2019/01/18	Lily Wei		  remove bounded warehouse, create new input Param for Confirmed Dispatch
 *						  2019/07/03	Grace Liu		  for OMS load id change
 *						  2021/09/01	Sathya			  Included Location/Intransit/Product Quantity column for Trip Available STO
														  also corrected the spelling of deficiency	
 ********************************************************************************/


CREATE PROCEDURE [dbo].[usp_trip_available_sto] @in_vchWhID					NVARCHAR(10),
                                                @in_vchDispatchStartDate	DATETIME,
												@in_vchDispatchEndDate		DATETIME
											   ,@in_vchType					nvarchar(20)  
											   ,@in_vchFWP                  NVARCHAR(2)
											   ,@in_Report					varchar(1) 
											   ,@in_Confirmed				VARCHAR(1)	--2019/01/18
AS

DECLARE @v_vchItemNumber  VARCHAR(30),
        @v_vchTripNumber  VARCHAR(10),
        @v_nQty          INT,
        @v_nTripNeeded  INT,
        @v_nTripPicked  INT,
        @v_nNegativeQty INT,
        @v_nPreNegative INT
	  , @v_nRowCount	int   
	  , @v_vchBuilding  VARCHAR(10)
	  --, @v_vchBonded	NVARCHAR(1) --DMND0134334

	  
IF Object_id ('tempdb..#temp_demand') IS NOT NULL
  BEGIN
      DROP TABLE #temp_demand
  END

CREATE TABLE #temp_demand 
  (
     wh_id           VARCHAR(10) NOT NULL,
     dispatch_date   DATETIME NOT NULL,
     dispatch_time   DATETIME NOT NULL,
     item_number     VARCHAR(30) NOT NULL,
     trip_number     VARCHAR(10) NOT NULL,
     trip_needed     INT,
     trip_picked     INT,
     available_sto    INT,
     available_staged INT,
     yard_qty        INT,
     new_asn_qty     INT,
     po_number       VARCHAR(60),
     earliest_date   DATETIME,
     Stage_Qty         INT,
     NOMFG_qty       INT,
     negative_tot    INT
	,Mfg_schQty		 int 
	,ldm_status		 varchar(1)  
	,overflow_qty	int  
	,offsite_qty	int 
	,carrier		varchar(100)
	,In_transit		INT
	,prod_qty		INT
	,location_id	varchar(50)
  )

SELECT @v_vchItemNumber = '',
       @v_vchTripNumber = '',
       @v_nQty = 0,
       @v_nTripNeeded = 0,
       @v_nTripPicked = 0
	  ,@v_nRowCount =0

IF Object_id ('tempdb..#temp_asn') IS NOT NULL
  BEGIN
      DROP TABLE #temp_asn
  END

IF Object_id ('tempdb..#temp_sto') IS NOT NULL
  BEGIN
      DROP TABLE #temp_sto
  END

IF Object_id ('tempdb..#temp_total') IS NOT NULL
  BEGIN
      DROP TABLE #temp_total
  END

IF Object_id ('tempdb..#_overflow_building_location') IS NOT NULL
  BEGIN
      DROP TABLE #_overflow_building_location
  END

select @v_vchBuilding=c1 from t_control(nolock)where control_type='BLDG_FWD_PICK'

CREATE TABLE #_overflow_building_location (item_number NVARCHAR(30),
								location_id NVARCHAR(50),
								qty INT)	
	INSERT INTO #_overflow_building_location
	SELECT  sto.item_number, MIN(sto.location_id), sto.actual_qty
	FROM t_stored_item sto (NOLOCK)
	JOIN t_location loc (NOLOCK)
	ON loc.location_id = sto.location_id
	AND loc.type IN ('I', 'M', 'Y', 'X','P')  
	 AND loc.wh_id = sto.wh_id	
	JOIN t_control con (NOLOCK)
	ON con.c1 = loc.building
	AND con.control_type = 'BLDG_OVERFLOW'
	JOIN t_item_master itm (NOLOCK)
	ON sto.item_number = itm.item_number
	AND itm.pick_put_id LIKE '%'
	AND sto.wh_id = itm.wh_id
	INNER JOIN (SELECT item_number, MIN(actual_qty) AS actual_qty
				,s.wh_id 
				 FROM t_stored_item s (NOLOCK)
				JOIN t_location loc (NOLOCK)
				ON loc.location_id = s.location_id
				AND loc.type IN ('I', 'M', 'Y', 'X','P')
				 AND loc.wh_id = s.wh_id			
				JOIN t_control con (NOLOCK)
				ON con.c1 = loc.building
				AND con.control_type = 'BLDG_OVERFLOW' GROUP BY item_number
				,s.wh_id 
				) sto2
	ON sto.item_number = sto2.item_number
	AND sto.actual_qty = sto2.actual_qty
	AND sto.wh_id = sto2.wh_id
	GROUP BY sto.item_number, sto.actual_qty
	ORDER BY sto.item_number


if @in_vchType <> 'ALL'
begin
  IF Object_id ('tempdb..#item') IS NOT NULL
  BEGIN
      DROP TABLE #item
  END

SELECT a.item_number
INTO   #item
FROM   (SELECT orb.item_number,
               Sum(orb.qty) AS trip_needed
        FROM   t_load_master ldm (nolock)
			   join dbo.t_order orm (nolock) on ldm.wh_id=orm.wh_id and ldm.load_id=orm.load_id ---Grace add 
               JOIN t_order_detail_breakdown orb (nolock)
                 ON orb.wh_id = ldm.wh_id
                    AND orb.order_number = orm.order_number
				LEFT join t_load_dispatch ldd (nolock) on ldd.load_id =ldm.load_id and ldd.wh_id=ldm.wh_id ---Grace change
        WHERE  ldm.wh_id = @in_vchWhID
			   and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
               AND ldm.status NOT IN ( 'S', 'X', 'C' )
               AND ldm.load_type = 'B'
			   AND (case when @in_Confirmed='A' then @in_Confirmed else isnull(ldd.dispatch_confirmed,'N') end)= @in_Confirmed  --2019/01/18
        GROUP  BY orb.item_number) a
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
WHERE  a.trip_needed - Isnull(b.picked_qty, 0) - Isnull(c.avaiable_qty, 0) > 0 

-------------get trip demand
INSERT INTO #temp_demand
SELECT a.wh_id,
       a.dispatch_date,
       a.dispatch_time,
       a.item_number,
       a.trip_number,
       a.trip_needed,
       Sum(Isnull(pkd.picked_quantity, 0)) AS trip_picked,
       0,
       0,
       0,
       0,
       '',
       '',
       0,
       0,
       0
	  ,0 
	  ,a.status
	  ,c.overflow_qty
	  ,p.offsite_onhand_qty
	  ,a.carrier
	  ,(ISNULL(p.onhand_fwd_pick_bldg,0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl,0)) AS In_transit
	  ,0
	  ,ovr.location_id
FROM   (SELECT ldm.wh_id,
               ldm.dispatch_date,
               ldm.dispatch_time,
               orb.item_number,
			   ldm.status,		
			   isnull(orm.carrier,isnull(c.carrier_name,'')) as carrier,   
			   ldm.load_id			as trip_number , ----Grace change
               Sum(orb.qty)         AS trip_needed
        FROM   t_load_master ldm (nolock)
			   join t_order orm (nolock) on ldm.wh_id=orm.wh_id and ldm.load_id=orm.load_id
			   left join t_carrier c (nolock) on ldm.carrier_id=c.carrier_id       
               JOIN t_order_detail_breakdown orb (nolock)
                 ON orb.wh_id = ldm.wh_id
				 and orb.order_number=orm.order_number
			   join #item  (nolock) on orb.item_number = #item.item_number 
				LEFT join t_load_dispatch ldd (nolock) on ldd.load_id =ldm.load_id  AND ldd.wh_id = ldm.wh_id    ---Grace change
        WHERE  (ldm.wh_id = @in_vchWhID)
			   and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
			   AND ldm.status not in ('S','X','C')
               AND ldm.load_type = 'B'
			   AND (case when @in_Confirmed='A' then @in_Confirmed else isnull(ldd.dispatch_confirmed,'N') end)= @in_Confirmed  --2019/01/18
        GROUP  BY ldm.wh_id,
                  ldm.dispatch_date,
                  ldm.dispatch_time,
                  orb.item_number,
				  ldm.status,
				  isnull(orm.carrier,isnull(c.carrier_name,'')),
                  ldm.load_id) a
       LEFT JOIN t_pick_detail pkd (nolock)
			    on a.trip_number = pkd.load_id    ---Grace change
                 AND a.item_number = pkd.item_number
                 AND Isnull(pkd.picked_quantity, 0) > 0
				 AND a.wh_id = pkd.wh_id
	  left join (select sto.wh_id,sto.item_number,sum(sto.actual_qty) as overflow_qty
	             from t_stored_item (nolock) sto
				 join t_location (nolock) loc on sto.wh_id=loc.wh_id and sto.location_id=loc.location_id 
				 join t_control con (NOLOCK) ON con.c1 = loc.building AND con.control_type = 'BLDG_OVERFLOW'
				 join #item  (nolock) on sto.item_number=#item.item_number
				 where loc.type in ('I','M','Y','X')
				 AND sto.status='A'
				 and sto.actual_qty > 0
				 group by sto.wh_id,sto.item_number
				 ) c on a.wh_id=c.wh_id and a.item_number=c.item_number
	  left join t_inventory_position (nolock) p on p.wh_id=a.wh_id and p.item_number=a.item_number
	  left join #_overflow_building_location (nolock) ovr on ovr.item_number = c.item_number
GROUP  BY a.wh_id,
          a.dispatch_date,
          a.dispatch_time,
          a.item_number,
          a.trip_number,
          a.trip_needed,
		  a.status,
		  c.overflow_qty
		  ,p.offsite_onhand_qty
		  ,a.carrier
		  ,(ISNULL(p.onhand_fwd_pick_bldg,0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl,0))
		  ,ovr.location_id
	 
end
else
begin
	INSERT INTO #temp_demand
SELECT a.wh_id,
       a.dispatch_date,
       a.dispatch_time,
       a.item_number,
       a.trip_number,
       a.trip_needed,
       Sum(Isnull(pkd.picked_quantity, 0)) AS trip_picked,
       0,
       0,
       0,
       0,
       '',
     '',
       0,
       0,
       0
	  ,0 
	  ,a.status
	  ,c.overflow_qty
	  ,p.offsite_onhand_qty
	  ,a.carrier
	  ,(ISNULL(p.onhand_fwd_pick_bldg,0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl,0)) AS In_transit
	  ,0
	  ,ovr.location_id
FROM   (SELECT ldm.wh_id,
               ldm.dispatch_date,
               ldm.dispatch_time,
               orb.item_number,
			   ldm.status,		
			   isnull(orm.carrier,isnull(c.carrier_name,'')) as carrier, 
			   ldm.load_id		as trip_number, ---Grace change
               Sum(orb.qty)         AS trip_needed
        FROM   t_load_master ldm (nolock)
			   join t_order orm (nolock) on ldm.wh_id=orm.wh_id and ldm.load_id=orm.load_id
			   left join t_carrier c (nolock) on ldm.carrier_id=c.carrier_id       
               JOIN t_order_detail_breakdown orb (nolock) ON orb.wh_id = ldm.wh_id
			   and orb.order_number=orm.order_number
			   LEFT join t_load_dispatch ldd (nolock) on ldd.load_id =ldm.load_id AND ldd.wh_id = ldm.wh_id 
        WHERE  ldm.wh_id = @in_vchWhID
			   and ldm.dispatch_date + ldm.dispatch_time between convert(datetime,@in_vchDispatchStartDate) and convert(datetime,@in_vchDispatchEndDate)
			   AND ldm.status not in ('S','X','C')
               AND ldm.load_type = 'B'
			   AND (case when @in_Confirmed='A' then @in_Confirmed else isnull(ldd.dispatch_confirmed,'N') end)= @in_Confirmed  --2019/01/18
        GROUP  BY ldm.wh_id,
                  ldm.dispatch_date,
                  ldm.dispatch_time,
                  orb.item_number,
				  ldm.status,
				  isnull(orm.carrier,isnull(c.carrier_name,'')),
                  ldm.load_id) a
       LEFT JOIN t_pick_detail pkd (nolock)
              ON a.trip_number = pkd.load_id  ---Grace change
                 AND a.item_number = pkd.item_number
                 AND Isnull(pkd.picked_quantity, 0) > 0
				 AND a.wh_id = pkd.wh_id
	  left join (select sto.wh_id,sto.item_number,sum(sto.actual_qty) as overflow_qty
	             from t_stored_item (nolock) sto
				 join t_location (nolock) loc on sto.wh_id=loc.wh_id and sto.location_id=loc.location_id 
				 join t_control con (NOLOCK) ON con.c1 = loc.building AND con.control_type = 'BLDG_OVERFLOW'
				 where loc.type in ('I','M','Y','X')
				 AND sto.status='A'
				 and sto.actual_qty > 0
				 group by sto.wh_id,sto.item_number
				 ) c on a.wh_id=c.wh_id and a.item_number=c.item_number
	  left join t_inventory_position (nolock) p on p.wh_id=a.wh_id and p.item_number=a.item_number
	  left join #_overflow_building_location (nolock) ovr on ovr.item_number = c.item_number
GROUP  BY a.wh_id,
          a.dispatch_date,
          a.dispatch_time,
          a.item_number,
          a.trip_number,
          a.trip_needed,
		  a.status,
		  c.overflow_qty
		  ,p.offsite_onhand_qty
		  ,a.carrier
		  ,(ISNULL(p.onhand_fwd_pick_bldg,0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl,0))
		  ,ovr.location_id
end

select @v_nRowCount =count(1) from #temp_demand (nolock)
if @v_nRowCount > 0
begin
SELECT wh_id,
       item_number,
       Sum(trip_needed) AS trip_needed,
       Sum(trip_picked) AS trip_picked,
       0                AS available_sto,
       0                AS available_staged,
       0                AS Stage_Qty,
       0                AS yard_qty,
       0                AS new_asn_qty,
       0                AS negative_qty
INTO   #temp_total
FROM   #temp_demand
GROUP  BY wh_id,
          item_number

-----------get avaiable staged qty for work type 06  and FL001AA1
UPDATE #temp_demand
SET    available_staged = avaiable_stage.qty
FROM   (SELECT sto.item_number,
               Sum(sto.actual_qty) AS qty
        FROM   t_stored_item sto (nolock)
        WHERE  sto.type = 'STORAGE'
			   AND sto.wh_id = @in_vchWhID
               AND sto.actual_qty > 0
               AND ( sto.location_id LIKE 'RS%'
                      OR sto.location_id LIKE 'DZ%'
                      OR sto.location_id IN (SELECT Isnull(c1, 'FL001AA1')
                                             FROM   t_control (nolock)
                                             WHERE  control_type = 'DEFUPHDROP_LOC') )
        GROUP  BY sto.item_number) avaiable_stage
       JOIN #temp_demand demand
         ON demand.item_number = avaiable_stage.item_number

  update #temp_demand 
     set Mfg_schQty = s.qty
	from (select sch.item_number,
				 sum(sch.qty_produced) as qty
			from t_mfg_schedule_stage (nolock) sch
			where sch.wh_id=@in_vchWhID
			 group by sch.item_number) s
	join #temp_demand demand
	 on demand.item_number=s.item_number

-----------get MFG made but without receipt qty
UPDATE #temp_demand
SET    NOMFG_qty = mfg.qty
FROM   (SELECT pru.item_number,
               Count(1) AS qty
        FROM   t_prod_receipt_upholstery pru (nolock)       	   
		WHERE  pru.wh_id = @in_vchWhID
			   AND eol_scanned = 'Y'
               AND received = 'N'
        GROUP  BY pru.item_number) mfg
       JOIN #temp_demand demand
         ON demand.item_number = mfg.item_number

-----------get avaiable staged qty for Q type location
UPDATE #temp_demand
SET    Stage_Qty = q_stage.qty
FROM   (SELECT sto.item_number,
               Sum(sto.actual_qty) AS qty
        FROM   t_stored_item sto (nolock)
               JOIN t_location loc (nolock)
                 ON sto.location_id = loc.location_id
				 AND sto.wh_id = loc.wh_id
        WHERE  sto.type = 'STORAGE'
               AND sto.actual_qty > 0
               AND loc.type = 'Q'
			   AND sto.wh_id = @in_vchWhID
        GROUP  BY sto.item_number) q_stage
       JOIN #temp_demand demand
         ON demand.item_number = q_stage.item_number

------------get avaiable check in ASN qty
UPDATE #temp_demand
SET    yard_qty = yard_asn.qty
FROM   (SELECT asd.item_number,
               Sum(asd.quantity_shipped - asd.quantity_received) AS qty
        FROM   t_asn asn (nolock)
               JOIN t_asn_detail asd (nolock)
                 ON asn.asn_id = asd.asn_id
        WHERE  asn.status = 'CHECKED IN'
        GROUP  BY asd.item_number
		having sum(asd.quantity_shipped) > sum(asd.quantity_received) ) yard_asn
       JOIN #temp_demand demand
         ON demand.item_number = yard_asn.item_number

-------------------------get product quantity
UPDATE #temp_demand set prod_qty=prod.qty
	FROM (SELECT mfg.item_number,
                        Sum(mfg.qty_expected - mfg.qty_received) AS qty
                 FROM   t_mfg_receipt (nolock) mfg
                        JOIN t_work_q(nolock) wkq
                          ON mfg.license_number = wkq.pick_ref_number
						  AND mfg.wh_id = wkq.wh_id
                        JOIN t_hu_master (nolock) hud
                          ON mfg.license_number = hud.hu_id
						  AND mfg.wh_id = hud.wh_id
                 WHERE  mfg.status = 'U'
                        AND received = 'N'
                        AND wkq.work_type = '55'
                        AND wkq.work_status <> 'C'
                        AND mfg.qty_expected - mfg.qty_received > 0
                 GROUP  BY mfg.item_number                  
				union
				SELECT pru.item_number, ISNULL(Count(1),0) AS qty 
									FROM t_prod_receipt_upholstery pru (nolock) 
								WHERE eol_scanned = 'Y' AND received = 'N' 
								GROUP BY pru.item_number )prod 
	JOIN #temp_demand demand
	ON prod.item_number = demand.item_number

-----------get need check in ASN qty
SELECT asd.asn_id,
       asd.item_number,
       asn.expected_arrival,
       Sum(asd.quantity_shipped - asd.quantity_received) AS qty,
       Cast('0' AS VARCHAR(60))                          AS po_number
INTO   #temp_asn
FROM   t_asn asn (nolock)
       JOIN t_asn_detail asd (nolock)
         ON asn.asn_id = asd.asn_id
WHERE  asn.status = 'NEW'
       AND asd.quantity_shipped > asd.quantity_received
       AND asd.item_number IN (SELECT item_number
     FROM   #temp_demand)
GROUP  BY asd.asn_id,
          asd.item_number,
          asn.expected_arrival

UPDATE #temp_asn
SET    po_number = y.customer_po_number
FROM   (SELECT TOP 1 asd.asn_id,
                     asd.customer_po_number
        FROM   t_asn_detail asd(nolock)
               JOIN #temp_asn x (nolock)
                 ON x.asn_id = asd.asn_id) y

UPDATE #temp_demand
SET    new_asn_qty = new_asn.qty,
       po_number = new_asn.po_number,
       earliest_date = new_asn.expected_arrival
FROM   #temp_asn new_asn (nolock)
       JOIN #temp_demand demand
         ON demand.item_number = new_asn.item_number

DROP TABLE #temp_asn

-----------get avaiable STO need to order by dispatch date & dispatch time
SELECT sto.item_number,
       Sum(sto.actual_qty) AS qty,
       'N'                 AS flag
INTO   #temp_sto
FROM   t_stored_item sto (nolock)
       JOIN t_location loc (nolock)
         ON sto.location_id = loc.location_id
		 AND sto.wh_id = loc.wh_id
WHERE  sto.type = 'STORAGE'
	   AND sto.wh_id = @in_vchWhID
       AND sto.actual_qty > 0
       AND loc.type IN ( 'I', 'M', 'P','X' )
	    AND loc.building =case when @in_vchFWP='Y' then @v_vchBuilding else loc.building end
	   and sto.status='A'
       AND sto.item_number IN (SELECT item_number
                               FROM   #temp_demand)
GROUP  BY sto.item_number

CREATE CLUSTERED INDEX IDX_TEMP_DISPATCH
  ON #temp_demand (dispatch_date, dispatch_time, trip_number);

CREATE INDEX IDX_ITEM
  ON #temp_demand (item_number); 

LOOPITEM:

SELECT TOP 1 @v_vchItemNumber = item_number,
             @v_nQty = qty
FROM   #temp_sto (nolock)
WHERE  flag = 'N'

IF @@ROWCOUNT > 0
  BEGIN
      LOOPITEMQTY:

      SELECT TOP 1 @v_vchTripNumber = trip_number,
                   @v_nTripNeeded = trip_needed,
                   @v_nTripPicked = trip_picked
      FROM   #temp_demand
      WHERE  item_number = @v_vchItemNumber
             AND available_sto = 0

      IF @@ROWCOUNT > 0
        BEGIN
            UPDATE #temp_demand
            SET    available_sto = @v_nQty
            WHERE  item_number = @v_vchItemNumber
                   AND trip_number = @v_vchTripNumber

            IF @v_nQty - ( @v_nTripNeeded - @v_nTripPicked ) > 0
              BEGIN
                  SELECT @v_nQty = @v_nQty - ( @v_nTripNeeded - @v_nTripPicked )

                  GOTO LOOPITEMQTY
              END
            ELSE
              BEGIN
                  UPDATE #temp_sto
                  SET    flag = 'Y'
                  WHERE  item_number = @v_vchItemNumber

                  GOTO LOOPITEM
              END
        END

      UPDATE #temp_sto
      SET    flag = 'Y'
      WHERE  item_number = @v_vchItemNumber

      GOTO LOOPITEM
  END

DROP TABLE #temp_sto

-----------get total negative_qty
SELECT DISTINCT item_number,
                'N' AS flag
INTO   #temp_item
FROM   #temp_demand
WHERE  available_sto - ( trip_needed - trip_picked ) < 0

LOOPITEMAGAIN:

SELECT TOP 1 @v_vchItemNumber = item_number
FROM   #temp_item (nolock)
WHERE  flag = 'N'

IF @@ROWCOUNT > 0
  BEGIN
      SELECT @v_nNegativeQty = 0,
             @v_nPreNegative = 0

      SELECT item_number,
             trip_number,
             CASE
               WHEN available_sto - ( trip_needed - trip_picked ) < 0 THEN available_sto - ( trip_needed - trip_picked )
               ELSE 0
             END AS negative_qty,
             'N' AS flag,
             negative_tot
      INTO   #temp_negative
      FROM   #temp_demand
      WHERE  item_number = @v_vchItemNumber
             AND available_sto - ( trip_needed - trip_picked ) < 0


      LOOPQTY:

      SELECT TOP 1 @v_vchTripNumber = trip_number,
                   @v_nNegativeQty = negative_qty
      FROM   #temp_negative (nolock)
      WHERE  flag = 'N'

      IF @@ROWCOUNT > 0
        BEGIN
            UPDATE #temp_demand
         SET    negative_tot = @v_nNegativeQty + @v_nPreNegative
            WHERE  item_number = @v_vchItemNumber
                   AND trip_number = @v_vchTripNumber

            UPDATE #temp_negative
            SET    flag = 'Y'
            WHERE  item_number = @v_vchItemNumber
                   AND trip_number = @v_vchTripNumber

            SELECT @v_nPreNegative = @v_nPreNegative + @v_nNegativeQty

            GOTO LOOPQTY
        END

      DROP TABLE #temp_negative

      UPDATE #temp_item
      SET    flag = 'Y'
      WHERE  item_number = @v_vchItemNumber

      GOTO LOOPITEMAGAIN
  END

DROP TABLE #temp_item


if @in_Report <> 'S' ---DETAIL information
begin

SELECT wh_id,
       CONVERT(CHAR(10), dispatch_date, 111) + ' '
       + CONVERT(CHAR(8), dispatch_time, 108) AS dispatch_date,
       item_number,
       trip_number,
	   ldm_status, 
       trip_needed,
       trip_picked,
       available_sto,
       available_staged,
       Stage_Qty,
       NOMFG_qty                              AS No_Received_Qty,
       yard_qty,
       new_asn_qty,
       --po_number,
       CASE
         WHEN CONVERT(CHAR(10), earliest_date, 111) = '1900/01/01' THEN ''
         ELSE CONVERT(CHAR(10), earliest_date, 111)
       END                                    AS earliest_date,
       CASE
         WHEN available_sto - ( trip_needed - trip_picked ) < 0 THEN available_sto - ( trip_needed - trip_picked )
         ELSE 0
       END                                    AS negative_qty,
       negative_tot
	  ,Mfg_schQty							  as MFG_Schedule_Qty
	  ,overflow_qty							  as Overflow_Qty  
	  ,offsite_qty			
	  ,carrier
	  ,In_transit
	  ,prod_qty
	  ,location_id
FROM   #temp_demand

end 
else   ---summary report
begin	
	IF Object_id ('tempdb..#temp_summary') IS NOT NULL
	BEGIN
      DROP TABLE #temp_summary
	END

	IF Object_id ('tempdb..#temp_trailer') IS NOT NULL
	BEGIN
      DROP TABLE #temp_trailer
	END

	IF Object_id ('tempdb..#update_trl') IS NOT NULL
	BEGIN
      DROP TABLE #update_trl
	END

	create table #temp_summary(
		wh_id			varchar(10),
		item_number		varchar(30),
		trip_count		int,
		deficiency		int,
		min_disp_date	varchar(30),
		max_disp_date	varchar(30),
		equipment		varchar(200),
		door			varchar(100),
		door_qty		varchar(100),
		available_staged	int,
		yard_qty		int,
		overflow_qty	int,
		offsite_qty		int,
		In_transit		int,
		prod_qty		int,
		location_id		varchar(50)    
	)
	insert into #temp_summary (wh_id,item_number,trip_count,deficiency,min_disp_date,max_disp_date,available_staged,yard_qty,overflow_qty,offsite_qty,In_transit,prod_qty,location_id)
	select m.wh_id ,m.item_number,
			(select count(distinct trip_number) from #temp_demand d where d.negative_tot <0 and d.item_number=m.item_number)
			,min(m.negative_tot) ,
			min(CONVERT(CHAR(10), m.dispatch_date, 111) + ' '+ CONVERT(CHAR(8), m.dispatch_time, 108)) ,
			max(CONVERT(CHAR(10), m.dispatch_date, 111) + ' '+ CONVERT(CHAR(8), m.dispatch_time, 108)) ,
			m.available_staged,
			m.yard_qty,
			m.overflow_qty,
			m.offsite_qty,
			m.In_transit,
			m.prod_qty,
			m.location_id
	from #temp_demand m
	group by m.wh_id,m.item_number,m.available_staged,m.yard_qty,m.overflow_qty,m.offsite_qty,m.In_transit,m.prod_qty,m.location_id

	select asn.equipment_id,yoc.location_name,asd.item_number,sum(asd.quantity_shipped - asd.quantity_received) as open_qty
	into #temp_trailer
	from t_asn (nolock) asn
	join t_asn_detail (nolock) asd on asn.asn_id=asd.asn_id
	join t_trailer_asn (nolock) tra on asn.asn_id=tra.asn_id
	join t_trailer (nolock) trl on tra.trailer_id=trl.trailer_id
	join t_ya_location (nolock) yoc on yoc.location_id=trl.location_id
	join (select distinct item_number from #temp_demand) d on asd.item_number=d.item_number
    where asn.status='CHECKED IN' 
	  and trl.status='IN DOOR'
	group by asn.equipment_id,yoc.location_name,asd.item_number
	having sum(asd.quantity_shipped - asd.quantity_received)>0

	if (select count(1) from #temp_trailer)>0 
	  begin 
		select m.item_number, 
			(select equipment_id+';' from #temp_trailer d where d.item_number=m.item_number for xml path('')) as equipment,
			(select location_name+';' from #temp_trailer d where d.item_number=m.item_number for xml path('')) as location,
			(select cast(open_qty as varchar(4))+';' from #temp_trailer d where d.item_number=m.item_number for xml path('')) as qty
		into #update_trl
		from #temp_summary m

		update #temp_summary
		  set equipment= left(d.equipment,len(d.equipment)-1),
			  door=left(d.location,len(d.location)-1),
			  door_qty=left(d.qty,len(d.qty)-1)
		 from #update_trl d
		 join #temp_summary m on d.item_number=m.item_number

		 drop table #update_trl
	  end
	  	
    select * from  #temp_summary order by  trip_count desc

	drop table #temp_trailer
	drop table #temp_summary

end


DROP TABLE #temp_total 
DROP TABLE #temp_demand

end 

