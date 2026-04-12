
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--      E:\Harini\Releases\20230731-01-CHG44684-DfctPbstry-Wholesale-Alpha-Advance\Rollout\Dbscripts\977772-GL-SEFU exclude ecoms show duplicated\rollout\usp_Get_Asn_Equipment_Unload.sql
----------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
EXEC [dbo].[usp_Get_Asn_Equipment_Unload] @in_vch_select='ALL', @in_vch_area='5', @in_vch_flag='ALL'
*/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Procedure: usp_Get_Asn_Equipment_Unload
-- Version: 4.8
---------------------------------------------------------------------
-- 11/19/07  v2.0  Pat Horne	   Task 615 - Corrected Join to 
--                                 t_trailer to use asn_id instead of
--				   equipment_id
---------------------------------------------------------------------
-- 02/27/08  V3.0  Lyn Henderson   Task 736 - Corrected error where
--                                 equipment appeared on SEFU page
--                                 that did not contain the item
--                                 listed
---------------------------------------------------------------------
-- 02/28/2008 Andy Davis Task 20 - Allow Multiple ASN's per Container
---------------------------------------------------------------------
--06/23/2008 V.3.1 Bubacarr Ceesay	Replace B2 & B4 hardcoding which updates to
--                      		t_demand_disposition	    
---------------------------------------------------------------------
--07/16/2008 V4.0  Bubacarr Ceesay	Include trip number and dispatch date & time 
--									to report	    
---------------------------------------------------------------------
--08/15/2008 V4.1  Lyn Henderson	Only show trip / dispatch date for those trips 
--									that need product.  Include 'A', 'H', 'C', 'W', 'M' trips.	    
---------------------------------------------------------------------
--08/21/2008 V4.2  Lyn Henderson	When dispositioning ASN to bldg, select the bldg with the 
--									largest number of cubes destined to it's forward pick.	    
---------------------------------------------------------------------
--09/02/2008 V4.3  Lyn Henderson	Performance tuned the stored procedure. 
---------------------------------------------------------------------
--10/30/2008 V4.4  Lyn Henderson    Changed @TotalCount variable to be equal to the count of 
--                                  distinct items in the #Demand table instead of a set value
---------------------------------------------------------------------
--10/31/2008 V4.5  Lyn Henderson    Fixed ASN calculation to aggregate shipped and received  
--                                  quantities when doing the comparison for what is unreceived.
---------------------------------------------------------------------
--12/11/2011 V4.6  Kevin Conan	    Set the #Demand.Disposition variable to varchar(30) and set nocount on 
---------------------------------------------------------------------
--2011/3/16 Grace Liu				change t_trailer. status not include 'LOST'
---------------------------------------------------------------------
--02/01/2013 V4.8  Leo Schmidt		PV4952 - Whitehall Split from Arcadia - Remove the link to 
--									Schedule Equipment to Door when the trailer is in a DRAYAGE location.
---------------------------------------------------------------------
---2014/06/10  GRACE LIU		backorder item remove from A demand per Ron's request  
---2014/07/24  Annie Liu        Transfer pick pieces remove form demand for Ron's request
---2014/08/04  Annie Liu        Added on column for User's request
---2014/08/08  Annie Liu        add column from  asn.expected_arrival
/*=============================================================================
--2015/01/14    Stephen Chen     task add muti wh_id for wanek 
---------------------------------------------------------------------
--2015/11/06    Lily Wei		 Fix Schedule Equipment for Unload-Mesquite does not return any results in HJ 
--2016/01/11   Sonia Xu          report show double trailer(move t_trailer.status to where conditon).
--2016/09/14   Bharathi B        Point the first cursor to run on a temp table instead of on the base tables to imporove the performance
                                 Removed the While loop to select trips at the end of the proc and placed a windowing function
--2017/01/24   Amrut M(STRY0066379)Added Highlight column in Temp table to figure out the Express trip by this supervisor will prioritize the receiving process.
--2018/01/11   Grace Liu	STRY0141233 - Add New Column (call usf_get_ASN_cube to get backorder cube) to YA Page1456	
--3019/06/20   Chris/Adaik	Tripless - Added Ecom tripless as well.  All Express will be RED regardless of priority per Dan W and Maurice.	
--10/18/2019	LWei			314807 WMS-03 Load ID Change(combine Grace OMS version with laterest PROD version)
--18/07/2020	Lakshmi		Tripless Billable Crossdock to include X type Trips																										
--10/05/2021    SateeshP   PBI619246-Transfer Crossdock Opportunity WW - Columns wanted for Lynwood																										
-- Zaheer  Optimized code changes for RR % fixes
--03/07/2022    PVenkatesh   OBb3 fix of  Status filter, and Excluding Transfers.
--04/07/2022	John X		 PRB827165 - Performance Tuning for SEFU - usp_Get_Asn_Equipment_Unload
--04/13/2022   Gowtham A     PRB770902 - Create RR item Exclusion list - Exclude from Compliance % calculation
--06/02/2022   Sai Krishna K Highlight MDC RDC loads in Yellow by considering Trip Type ID as 'M'
--06/16/2022   Sai Krishna K Identifying MDC RDC Item and setting the ASN
--03/02/2023   Grace Liu		977357 SEFU page filter change to pick_put_id
--04/10/2023   Grace Liu		977772 SEFU page correct ecoms orders show duplicated and correct percentage 
--06/19/2023   Grace Liu		include for ecoms order always show top 
--08/31/2023   Grace Liu		fix for ecoms order only include released
--08/30/2023   Grace Liu		for task 1050861  add new input parameters let it return others table
-- 11/28/2023  Mohd Kabir Ansari  Added nolock in usp_Get_Asn_Equipment_Unload PRB1072922
-- 12/08/2023   Pallav			1075119 - SEFU Consolidation
-- 03/13/2024   PVenkat		   1135903 SEFU page in Redlands is timing out without returning data
--03/13/2024     PVenkat	   1140418 - Core V Fringe calculation for Sefu
--11/01/2024     PVenkat	   1242809 - SEFU  Fix to correct priority of isEcom, isMDC being above items with Net Demand on other trips
--12/26/2024     PVENKAT   PRB1268567 - Sefu should Only ConsIder MDC-ECOM with A OR B Priority and NetDemand as  high Priority
-- 23/01/2025    Pallav			1075119 - SEFU Consolidation
--09/16/2025     Vasanth      V6 - 1375917 - Improve the performance for usp_dch_yard_volume_sefu used in DC Health Report   
--09/18/2025     Sonia Xu     V6.1 - 1375923 - Improve the performance of usp_dch_count_rr_containers SP used in DC Health Report
--11/11/2025	Lily		V7.0 WW-465 MVP for Automation candidates logic
--11/21/2025	Lily		V7.1 WW-465 any line with X on auto detail page exculde from item count(new column on Sefu will be impacted with the y or n but otherwise no impact)
---------------------------------------------------------------------
====                        Developer's Note!                              ====
====-----------------------------------------------------------------------====
====  If you must make a change to this stored procedure, please make      ====
====  the same changes to the following stored procedures as the logic     ====
==== is identical:                                                        ====
====                                                                       ====
====  usp_Asn_Equipment_Unload                                             ====
====  usp_Get_Item_Priority_Demand                                         ====
====  usp_Asn_Disposition                                                  ====
====  Web Wise Page 1455                                                   ====
====                                                                       ====

SAMPLE
SELECT GETDATE()

DECLARE
@in_select      VARCHAR(10),
      @in_area        VARCHAR(10)
	 , @in_flag        VARCHAR(10) 
SET @in_select = 'ALL'
SET	 @in_area  ='%'
SET @in_flag = 'ALL'
EXECUTE [usp_Get_Asn_Equipment_Unload_vp] @in_select,@in_area,@in_flag
SELECT GETDATE()

DECLARE
@in_vch_select      VARCHAR(10),
      @in_vch_area        VARCHAR(10)
	 , @in_vch_flag        VARCHAR(10) 
	 ,@in_sefu_version VARCHAR(10)
SET @in_vch_select = 'ALL'
SET	 @in_vch_area  ='%'
SET @in_vch_flag = 'ALL'
SET @in_sefu_version ='DEFAULT'
EXECUTE [usp_Get_Asn_Equipment_Unload] @in_vch_select,@in_vch_area,@in_vch_flag,'0',@in_sefu_version
SELECT GETDATE()
=============================================================================*/
CREATE     PROCEDURE [dbo].[usp_Get_Asn_Equipment_Unload]  
	  @in_vch_select		VARCHAR (10) 
     ,@in_vch_area		    VARCHAR (10) 		     
	 ,@in_vch_flag		    VARCHAR (10) 
	 ,@in_vch_seltable		VARCHAR (1)='0'
	 ,@in_vch_sefu_version  VARCHAR (10)='DEFAULT'
AS

BEGIN
SET NOCOUNT ON
DECLARE
  	 @in_select      VARCHAR(10),
	 @in_area        VARCHAR(10),
     @in_flag        VARCHAR(10),
     @wh_id			 VARCHAR(10)  

SET @in_select = @in_vch_select
SET	 @in_area  = @in_vch_area
SET @in_flag = @in_vch_flag

IF @in_area='%'
  SELECT TOP 1 @wh_id =wh_id FROM dbo.t_area_wh_id (NOLOCK) ORDER BY wh_id
ELSE 
  SELECT @wh_id =wh_id FROM dbo.t_area_wh_id (NOLOCK) WHERE area_id=@in_area

DECLARE 
  	  @Count			INT
	, @TotalCount		INT
	, @asn				INT
	, @Sample_asn		INT
	, @itnbr			VARCHAR(15) 
	, @Demand			FLOAT 
	, @Arrival			DATETIME 
	, @Expected_Arrival DATETIME  
	, @Priority			VARCHAR(1) 
	, @Disposition		VARCHAR(20) 
	, @Offsetdays		INT 
	, @BldgOvrflw		VARCHAR(10)
	, @BldgPick			VARCHAR(10)

DECLARE @n_po_type INT
SELECT @n_po_type = lookup_id FROM dbo.t_lookup WITH(NOLOCK) WHERE source = 't_po_master' AND text = 'Shuttle Orders'

SET @Offsetdays = 5 
SET @TotalCount = 100
SET @Count = 0

SET @BldgOvrflw = (SELECT c1 FROM dbo.t_control WITH(NOLOCK) WHERE control_type = 'BLDG_OVERFLOW')
SET @BldgPick = (SELECT c1 FROM dbo.t_control WITH(NOLOCK) WHERE control_type = 'BLDG_PICK')

IF OBJECT_ID('tempdb..#t_load_master') IS NOT NULL
    DROP TABLE #t_load_master

IF OBJECT_ID('tempdb..#t_trailer') IS NOT NULL
    DROP TABLE #t_trailer

IF OBJECT_ID('tempdb..#t_carrier') IS NOT NULL
    DROP TABLE #t_carrier

IF OBJECT_ID('tempdb..#t_ya_location') IS NOT NULL
	DROP TABLE #t_ya_location

IF OBJECT_ID('tempdb..#t_ya_work_q') IS NOT NULL
	DROP TABLE #t_ya_work_q

IF OBJECT_ID('tempdb..#t_load_master_with_exclusion') IS NOT NULL
	DROP TABLE #t_load_master_with_exclusion 

SELECT DISTINCT  * INTO #t_load_master  
FROM 
(SELECT * FROM dbo.t_load_master (NOLOCK)  WHERE status IN ('N','M')
UNION ALL
SELECT * FROM dbo.t_load_master (NOLOCK) WHERE load_type = 'X') A

SELECT DISTINCT * INTO #t_load_master_with_exclusion FROM dbo.t_load_master WITH(NOLOCK)


CREATE NONCLUSTERED INDEX #t_load_master1 ON #t_load_master (wh_id,load_id,status,trip_type_id,load_type)
CREATE NONCLUSTERED INDEX #t_load_master_with_exclusion1 ON #t_load_master_with_exclusion (wh_id,load_id,status,trip_type_id,load_type)

SELECT  
	trailer_id,status,state,location_id,carrier_id,entered_yard,area_id,exited_yard INTO #t_trailer 
FROM dbo.t_trailer (NOLOCK) WHERE  status NOT IN ('HISTORY') AND  state NOT IN ('EMPTY')

CREATE NONCLUSTERED INDEX #t_trailer1 ON #t_trailer (trailer_id,status,state,location_id,carrier_id)

SELECT  carrier_id,carrier_name INTO  #t_carrier FROM dbo.t_carrier(NOLOCK)

CREATE NONCLUSTERED INDEX #t_carrier1 ON #t_carrier (carrier_id,carrier_name)

SELECT location_id,location_name,type INTO #t_ya_location FROM  dbo.t_ya_location (NOLOCK)

CREATE NONCLUSTERED INDEX #t_ya_location1 ON #t_ya_location (location_id,location_name,type)

SELECT * INTO #t_ya_work_q FROM dbo.t_ya_work_q (NOLOCK) WHERE type  = '52' AND status = 'UNASSIGNED' 

SELECT t_asn_detail.asn_id, item_number, t_asn.status, 
        SUM(quantity_shipped) AS quantity_shipped,
        SUM(quantity_received) AS quantity_received,
        t_asn.equipment_id, c.carrier_name, entered_yard 
        ,expected_arrival
		, CAST(0 AS INT) AS backorder_cube
		, asn_number
 INTO #_asn_detail
 FROM dbo.t_asn_detail WITH(NOLOCK)
 JOIN dbo.t_asn WITH(NOLOCK) ON t_asn.asn_id = t_asn_detail.asn_id 
 JOIN dbo.t_trailer_asn WITH(NOLOCK) ON t_asn_detail.asn_id = t_trailer_asn.asn_id
 JOIN #t_trailer ON t_trailer_asn.trailer_id = #t_trailer.trailer_id
 LEFT JOIN #t_carrier c ON #t_trailer.carrier_id = c.carrier_id  
 LEFT JOIN dbo.t_po_master pom WITH(NOLOCK) ON t_asn_detail.customer_po_number=pom.po_number
WHERE t_asn.trailer_type_name <> 'AIR FREIGHT' 
  AND t_asn.equipment_id IS NOT NULL AND t_asn.status IN ('CHECKED IN')
  AND entered_yard <= GETDATE() + @Offsetdays 
  AND #t_trailer.status NOT IN ('HISTORY')
  AND #t_trailer.state NOT IN ('EMPTY')
  and (@in_vch_seltable = 0 or ( @in_vch_seltable='1' and isnull(pom.type_id,@n_po_type) <> @n_po_type)) 
GROUP BY t_asn_detail.asn_id, item_number, t_asn.status, entered_yard, t_asn.equipment_id, c.carrier_name,expected_arrival,asn_number
HAVING SUM(quantity_shipped) > SUM(quantity_received)

CREATE INDEX Temp1 ON #_asn_detail (asn_id, item_number, quantity_shipped)
CREATE INDEX Temp2 ON #_asn_detail (item_number, asn_id, quantity_shipped, entered_yard)

 SELECT 
 wh_id,
 item_number,
 SUM(back_qty) AS back_qty
 INTO #temp_backorder
 FROM (
 SELECT orb.wh_id,
       orb.item_number,
	   SUM(orb.qty) AS back_qty
 FROM dbo.t_order_detail_breakdown (NOLOCK) orb 
 --Load ID change
 JOIN dbo.t_order orm (NOLOCK) ON orb.wh_id = orm.wh_id AND orb.order_number = orm.order_number
 JOIN dbo.t_load_master(NOLOCK) ldm ON orm.load_id = ldm.load_id AND ldm.wh_id = orb.wh_id 
 WHERE ldm.status IN ('R','A','H','C','W')
 AND orb.ship_status IN ('BACKORDER','B')
GROUP BY orb.wh_id,orb.item_number

UNION ALL

 SELECT orm.wh_id,
       ord.item_number,
	   SUM(ord.bo_qty) AS back_qty
  FROM dbo.t_order (NOLOCK) orm 
 JOIN dbo.t_order_detail (NOLOCK) ord ON orm.order_number = ord.order_number
 WHERE bo_qty > 0
 AND orm.order_type_2 = 'U'
GROUP BY orm.wh_id,ord.item_number
) my_TABLE
GROUP BY wh_id,item_number

SELECT pkd.wh_id,pkd.item_number,SUM(pkd.planned_quantity - pkd.picked_quantity) AS transfer_qty
INTO #temp_transfer 
FROM dbo.t_pick_detail(NOLOCK) pkd
JOIN dbo.t_load_master(NOLOCK) ldm ON  ldm.load_id = pkd.load_id
AND pkd.wh_id = ldm.wh_id 
WHERE ldm.status IN ('R','A','H','C','W')
AND   pkd.work_type = '35'
GROUP BY pkd.wh_id,pkd.item_number

CREATE TABLE #Demand 
(Priority VARCHAR(1),Itnbr VARCHAR(15), Demand DECIMAL(12,0), Sort DECIMAL(12,4), Asn INT, isMDCRDC_with_net_demand BIT DEFAULT 0, isECOMS_with_net_demandS BIT DEFAULT 0,
  Net_demand DECIMAL (12,0), Sample_asn INT, Arrival DATETIME, 
  Expected_Arrival DATETIME,
  Disposition VARCHAR(30), 
  Suggested_Disposition VARCHAR(20), Status VARCHAR(1), Current_location VARCHAR(2), Scheduled_To VARCHAR(50),
  Percent_complete DECIMAL (7,0), Cubes DECIMAL (12,2), Disposition_Unit VARCHAR(5) DEFAULT 'Go To', Review_Inventory VARCHAR(5) DEFAULT 'Go To') 

CREATE TABLE #_inventory_position
(item_number VARCHAR(15),ABCE_supply DECIMAL(12,0),A_demand DECIMAL(12,0),B_demand DECIMAL(12,0),
C_demand DECIMAL(12,0),D_supply DECIMAL(12,0),D_demand DECIMAL(12,0),E_demand DECIMAL(12,0))


IF @in_flag = 'T'
BEGIN 

DELETE FROM #t_load_master_with_exclusion WHERE trip_type_id='W' 
INSERT INTO #_inventory_position
SELECT t1.item_number, 
	   CASE WHEN @in_vch_sefu_version IN ('DEFAULT','RM') THEN ISNULL(t3.onhand_whse,0)  -- for non shuttle version of sefu
			WHEN @in_vch_sefu_version IN ('SHUTTLE') THEN ISNULL(t3.onhand_fwd_pick_bldg_less_shtl,0) -- shuttle version of sefu
			END AS ABCE_supply,
	   ISNULL(t3.planned_picks,0) - ISNULL(t4.transfer_qty,0) AS A_demand,	   
       ISNULL(t3.planned_picks,0) - ISNULL(t4.transfer_qty,0) + ISNULL(t3.unreleased_orders,0) AS B_demand,
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) - ISNULL(t4.transfer_qty,0) + ISNULL(t3.unreleased_orders,0) AS C_demand,
       ISNULL(t3.onhand_fwd_pick_bldg,0) AS D_supply,
       ISNULL(t2.fwd_pick_bldg_thresh,0) AS D_demand, 
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) - ISNULL(t4.transfer_qty,0) + ISNULL(t3.unreleased_orders,0) AS E_demand
FROM dbo.t_item_master t1 WITH(NOLOCK)
        LEFT OUTER JOIN dbo.t_item_planning t2 WITH(NOLOCK)
             ON t1.item_number = t2.item_number 
			 	 AND t1.wh_id = t2.wh_id  
        LEFT OUTER JOIN dbo.t_inventory_position t3 WITH(NOLOCK)
             ON t1.item_number = t3.item_number 
			 AND t1.wh_id = t3.wh_id  
		LEFT OUTER JOIN #temp_transfer t4  
		     ON t1.item_number = t4.item_number
			 AND t1.wh_id = t4.wh_id  
        WHERE  commodity_code LIKE 'Z%'
		   AND ((@in_vch_sefu_version IN ('DEFAULT','SHUTTLE') AND commodity_code NOT LIKE 'Z__K') -- Finished Goods ( Used in Default Sefu version or Shuttle version)
					OR (@in_vch_sefu_version='RM' AND commodity_code LIKE 'Z__K' )) -- For Raw material version
END
ELSE IF @in_flag = 'B'
BEGIN 
INSERT INTO #_inventory_position
SELECT t1.item_number,
	   CASE WHEN @in_vch_sefu_version IN ('DEFAULT','RM') THEN ISNULL(t3.onhand_whse,0)  -- for non shuttle version of sefu
			WHEN @in_vch_sefu_version IN ('SHUTTLE') THEN ISNULL(t3.onhand_fwd_pick_bldg_less_shtl,0) -- shuttle version of sefu
			END AS ABCE_supply,
	   ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) AS A_demand,	   
       ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) + ISNULL(t3.unreleased_orders,0) AS B_demand,
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) + ISNULL(t3.unreleased_orders,0) AS C_demand,
       ISNULL(t3.onhand_fwd_pick_bldg,0) AS D_supply,
       ISNULL(t2.fwd_pick_bldg_thresh,0) AS D_demand, 
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) + ISNULL(t3.unreleased_orders,0) AS E_demand
FROM dbo.t_item_master t1 WITH(NOLOCK)
        LEFT OUTER JOIN dbo.t_item_planning t2 WITH(NOLOCK)
             ON t1.item_number = t2.item_number 
			 AND t1.wh_id=t2.wh_id  
        LEFT OUTER JOIN dbo.t_inventory_position t3 WITH(NOLOCK)
             ON t1.item_number = t3.item_number 
			 AND t1.wh_id = t3.wh_id 
		LEFT OUTER JOIN #temp_backorder t4 
		     ON t1.item_number = t4.item_number
			 AND t1.wh_id = t4.wh_id 
        WHERE  commodity_code LIKE 'Z%'
		   AND ((@in_vch_sefu_version IN ('DEFAULT','SHUTTLE') AND commodity_code NOT LIKE 'Z__K') -- Finished Goods ( Used in Default Sefu version or Shuttle version)
					OR (@in_vch_sefu_version='RM' AND commodity_code LIKE 'Z__K' )) -- For Raw material version
END
ELSE IF @in_flag = 'BT'
BEGIN 
DELETE FROM #t_load_master_with_exclusion WHERE trip_type_id='W'
INSERT INTO #_inventory_position
SELECT t1.item_number,
	   CASE WHEN @in_vch_sefu_version IN ('DEFAULT','RM') THEN ISNULL(t3.onhand_whse,0)  -- for non shuttle version of sefu
			WHEN @in_vch_sefu_version IN ('SHUTTLE') THEN ISNULL(t3.onhand_fwd_pick_bldg_less_shtl,0) -- shuttle version of sefu
			END AS ABCE_supply,
	   ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) - ISNULL(t5.transfer_qty,0) AS A_demand,	   
       ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) + ISNULL(t3.unreleased_orders,0) - ISNULL(t5.transfer_qty,0) AS B_demand,
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) + ISNULL(t3.unreleased_orders,0) - ISNULL(t5.transfer_qty,0) AS C_demand,
       ISNULL(t3.onhand_fwd_pick_bldg,0) AS D_supply,
       ISNULL(t2.fwd_pick_bldg_thresh,0) AS D_demand, 
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) - ISNULL(t4.back_qty,0) + ISNULL(t3.unreleased_orders,0) - ISNULL(t5.transfer_qty,0) AS E_demand
FROM dbo.t_item_master t1 WITH(NOLOCK)
        LEFT OUTER JOIN dbo.t_item_planning t2 WITH(NOLOCK)
             ON t1.item_number = t2.item_number 
			 AND t1.wh_id = t2.wh_id  
        LEFT OUTER JOIN dbo.t_inventory_position t3 WITH(NOLOCK)
             ON t1.item_number = t3.item_number 
			 AND t1.wh_id = t3.wh_id  
		LEFT OUTER JOIN #temp_backorder t4 
		     ON t1.item_number = t4.item_number
			 AND t1.wh_id=t4.wh_id  
	    LEFT OUTER JOIN #temp_transfer t5 
		     ON t1.item_number = t5.item_number
			  AND t1.wh_id = t5.wh_id  
        WHERE  commodity_code LIKE 'Z%'
		   AND ((@in_vch_sefu_version IN ('DEFAULT','SHUTTLE') AND commodity_code NOT LIKE 'Z__K') -- Finished Goods ( Used in Default Sefu version or Shuttle version)
					OR (@in_vch_sefu_version='RM' AND commodity_code LIKE 'Z__K' )) -- For Raw material version
END
ELSE IF @in_flag = 'ALL'
BEGIN 
INSERT INTO #_inventory_position
SELECT t1.item_number,
	   CASE WHEN @in_vch_sefu_version IN ('DEFAULT','RM') THEN ISNULL(t3.onhand_whse,0)  -- for non shuttle version of sefu
			WHEN @in_vch_sefu_version IN ('SHUTTLE') THEN ISNULL(t3.onhand_fwd_pick_bldg_less_shtl,0) -- shuttle version of sefu
			END AS ABCE_supply,
	   ISNULL(t3.planned_picks,0) AS A_demand,	   
       ISNULL(t3.planned_picks,0) + ISNULL(t3.unreleased_orders,0) AS B_demand,
       ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) + ISNULL(t3.unreleased_orders,0) AS C_demand,
       ISNULL(t3.onhand_fwd_pick_bldg,0) AS D_supply,
       ISNULL(t2.fwd_pick_bldg_thresh,0) AS D_demand, 
	   ISNULL(t2.forecast_demand,0) + ISNULL(t3.planned_picks,0) + ISNULL(t3.unreleased_orders,0) AS E_demand  
FROM dbo.t_item_master t1 WITH(NOLOCK)
        LEFT OUTER JOIN dbo.t_item_planning t2 WITH(NOLOCK)
             ON t1.item_number = t2.item_number 
			 AND t1.wh_id=t2.wh_id  
        LEFT OUTER JOIN dbo.t_inventory_position t3 WITH(NOLOCK)
             ON t1.item_number = t3.item_number 
			 AND t1.wh_id = t3.wh_id  
        WHERE  commodity_code LIKE 'Z%'
		   AND ((@in_vch_sefu_version IN ('DEFAULT','SHUTTLE') AND commodity_code NOT LIKE 'Z__K') -- Finished Goods ( Used in Default Sefu version or Shuttle version)
					OR (@in_vch_sefu_version='RM' AND commodity_code LIKE 'Z__K' )) -- For Raw material version
END


-- Step 1, Build Demand list 
INSERT INTO #Demand 
(Priority, Itnbr, Demand, Sort, Asn, Net_demand, Sample_asn) 
--- Demand A =  Released Picks vs Whse Onhand 
SELECT 'A' AS priority, item_number, (A_demand - ABCE_supply), (A_demand - ABCE_supply)/(A_demand * 1.000) AS sort, 
       '' AS asn, A_demand-ABCE_supply AS Net_demand, '' AS sample_asn 
 FROM #_inventory_position
 WHERE A_demand > ABCE_supply AND A_demand > 0 

UNION ALL 
--- Demand B = Released Picks + Unplanned Picks vs Whse Onhand 
SELECT 'B' as priority, item_number, (B_demand-ABCE_supply), (B_demand-ABCE_supply)/(B_demand*1.000) AS sort, 
  '' AS asn, B_demand-ABCE_supply AS Net_demand, '' AS sample_asn 
 FROM #_inventory_position
 WHERE B_demand > ABCE_supply AND B_demand > 0 

UNION ALL 

SELECT 'B' AS priority, 'SAMPLE' AS item_number, SUM(quantity_shipped) AS Demand, 
    .75 as sort, '' AS asn, SUM(quantity_shipped) AS net_demand, AD.asn_id AS sample_asn 
 FROM #_asn_detail AD 
 WHERE item_number = 'SAMPLE' 
 GROUP BY item_number, AD.asn_id 

UNION ALL 

SELECT 'C' AS priority, item_number, (C_demand-ABCE_supply), (C_demand-ABCE_supply)/(C_demand*1.000) AS sort, 
       '' AS asn, C_demand-ABCE_supply AS Net_demand, '' AS sample_asn 
 FROM #_inventory_position 
 WHERE C_demand > ABCE_supply AND C_demand > 0  

UNION ALL 

--- Demand D = Forward Pick threshhold vs Forward Pick Onhand 
SELECT 'D' AS priority, item_number, (D_demand - D_supply), 
       (D_demand - D_supply)/D_demand * 1.000 AS sort, 
        '' AS asn, D_demand - D_supply AS Net_demand, '' AS sample_asn 
 FROM #_inventory_position
 WHERE D_demand > D_supply AND D_demand > 0  

UNION ALL 

--- Demand E = Items whose Demand has been covered 
SELECT 'E' as priority, item_number, E_demand, (E_demand-ABCE_supply)/(E_demand*1.000) AS sort, 
       '' as asn, E_demand-ABCE_supply as Net_demand, '' AS sample_asn 
 FROM #_inventory_position
 WHERE E_demand <= ABCE_supply AND E_demand > 0  
 
CREATE NONCLUSTERED INDEX itnbr ON #Demand (Itnbr)
CREATE NONCLUSTERED INDEX Demand ON #Demand (Asn, Itnbr)

---2023/06/16 Grace Liu comment out check in door trailer cover demand 
--IF OBJECT_ID('tempdb..#pre_items') IS NOT NULL DROP TABLE #pre_items

--SELECT AH.asn_id, location_name, entered_yard as Arrival 
-- ,AH.expected_arrival
-- INTO #pre_items
--     FROM dbo.t_asn AH (NOLOCK) 
--       JOIN dbo.t_trailer_asn WITH(NOLOCK) ON AH.asn_id = t_trailer_asn.asn_id
--       JOIN #t_trailer WITH(NOLOCK) ON t_trailer_asn.trailer_id = #t_trailer.trailer_id 
--                             AND #t_trailer.state <> 'EMPTY'
--                             AND #t_trailer.status = 'IN DOOR' 
--                             AND exited_yard IS NULL
--       JOIN #t_ya_location WITH(NOLOCK) ON #t_ya_location.location_id = #t_trailer.location_id 
--                             AND #t_ya_location.type = 'DOOR'
--                             AND location_name NOT LIKE  'DROP%'
--     WHERE AH.status IN ('CHECKED IN') 

--DECLARE pre_items CURSOR 
--FOR 
-- SELECT asn_id, location_name, Arrival ,expected_arrival
--     FROM #pre_items 
--     ORDER BY Arrival

--OPEN pre_items 
--FETCH NEXT FROM pre_items INTO @asn, @Disposition, @Arrival, @Expected_Arrival
--WHILE (@@FETCH_STATUS <> -1) 
--BEGIN 
--   IF (@@FETCH_STATUS <> -2) 
--   BEGIN 
--      IF LEN(@asn) > 0 
--      BEGIN 
--            SELECT TOP 1 @itnbr = #Demand.Itnbr, @Priority = #Demand.Priority 
--              FROM #Demand WITH(NOLOCK)
--              JOIN #_asn_detail WITH(NOLOCK) 
--                ON asn_id = @asn AND #Demand.Itnbr = item_number 
--              WHERE #Demand.Asn = '' 
--              ORDER BY Priority, Net_demand DESC, Sort DESC 

--            IF @itnbr IS NOT NULL
--            BEGIN
--				UPDATE #Demand 
--				   SET Net_demand = Net_demand - quantity_shipped,

--                  Sort = CASE WHEN item_number <> @itnbr 
--                  Then CASE WHEN Demand = 0 THEN 0
--                                     ELSE(Net_demand)/(Demand * 1.000)
--                                END 
--                           ELSE Sort 
--                         End
--				   FROM (SELECT item_number, SUM(quantity_shipped) AS quantity_shipped
--               			 FROM #_asn_detail WITH(NOLOCK)
--              			 WHERE item_number <> 'SAMPLE'  AND asn_id = @asn
--                         GROUP BY item_number) t1
--				 WHERE #Demand.Itnbr = item_number 
--                   AND #Demand.Asn = ''

--				UPDATE #Demand 
--				SET Asn = @asn, Arrival = @Arrival, Disposition = @Disposition, Expected_Arrival = @Expected_Arrival
--				  WHERE #Demand.Itnbr = @itnbr AND #Demand.Priority = @Priority 
--				  AND Asn = '' AND @itnbr <> 'SAMPLE' 
	             
--				UPDATE #Demand 
--				SET Asn = @asn, Arrival = @Arrival, Disposition= @Disposition, Expected_Arrival = @Expected_Arrival
--				  WHERE #Demand.Itnbr = 'SAMPLE' AND @itnbr = 'SAMPLE' AND Sample_asn = @asn 

--				IF @itnbr <> 'SAMPLE'
--				  BEGIN

--					DELETE FROM #Demand WHERE #Demand.Sample_asn = @asn AND #Demand.Itnbr = 'SAMPLE' 
--				  END

--				INSERT INTO #Demand 
--				  (Priority, Itnbr, Demand, Sort, Asn, Net_demand) 
--                SELECT Priority, Itnbr, Net_demand, CASE WHEN Demand = 0 THEN 0
--                           ELSE(Net_demand)/(Demand * 1.000)
--                                                    END as Sort,
--                       '' AS asn, Net_demand 
--				  FROM #Demand WITH(NOLOCK)
--				 WHERE Asn = @asn AND Net_demand > 0  AND Itnbr <> 'SAMPLE' AND Priority = @Priority 	
--				DELETE FROM #Demand WHERE Net_demand <= 0 AND Asn = '' AND Priority <> 'E' 
--            END
--      END 
--   END 
--   FETCH NEXT FROM pre_items INTO @asn, @Disposition, @Arrival 
--		,@Expected_Arrival
--   SET @itnbr = NULL
--END 
--CLOSE pre_items 
--DEALLOCATE pre_items 

CREATE NONCLUSTERED INDEX temp1 ON #Demand( Priority, Sort DESC, Net_demand, Asn)

DELETE FROM #Demand WHERE Itnbr <> 'SAMPLE' AND Itnbr NOT IN (SELECT item_number FROM  #_asn_detail)

SELECT @TotalCount = COUNT(DISTINCT Itnbr) FROM #Demand WHERE Asn = 0

--- Step 3, locate containers for remaining Demand items 

UPDATE d1 SET isMDCRDC_with_net_demand = 1						
FROM  #Demand d1
JOIN dbo.t_mdcrdc_wave_order_detail wod (NOLOCK) ON wod.item_number = d1.Itnbr
WHERE (wod.released_quantity - wod.staged_quantity > 0) AND (wod.staged_quantity - wod.shipped_quantity >= 0 )
		AND   wod.codis_order_number IS NOT NULL
		AND   d1.Itnbr <> 'SAMPLE'
		AND   d1.Net_demand>0 AND d1.Priority IN('A','B')
---2023/06/16  Grace liu add make sure Ecoms need always top 
UPDATE d1
  set isECOMS_with_net_demandS=1
FROM #Demand d1
JOIN dbo.t_pick_detail pkd WITH(NOLOCK) ON pkd.item_number=d1.Itnbr
WHERE pkd.work_type IN ('72','73')
AND pkd.planned_quantity > pkd.picked_quantity
AND pkd.status NOT IN ('BACKORDER','CANCELED')
AND   d1.Net_demand>0 AND d1.Priority IN ('A','B')
--END

WHILE @Count <= @TotalCount AND EXISTS(SELECT TOP 1 Itnbr FROM #Demand WHERE Asn = '') 
BEGIN 
   SET @asn = NULL 
   SET @Sample_asn  = NULL 
   SET @itnbr = NULL 
   SET @Demand = NULL 
   SET @Arrival = NULL 
   SET @Expected_Arrival=Null	
   SET @Priority = NULL 
   SET @Disposition = NULL 

   -- Get the next highest needed item 
   SELECT @itnbr = Itnbr, @Priority = Priority, @Demand = Net_demand, @Sample_asn = Sample_asn 
    FROM (SELECT TOP 1 d1.Itnbr, d1.Priority, d1.Sample_asn, d2.Net_demand 
            FROM #Demand d1 
             LEFT JOIN #Demand d2 
               ON d1.Itnbr = d2.Itnbr 
               AND d2.Priority = CASE WHEN d1.Priority IN ('A','B') Then 'C' 
                                      ELSE d1.Priority 
                                 END
			WHERE d1.Asn = '' 
    ORDER BY d1.isECOMS_with_net_demandS desc,d1.isMDCRDC_with_net_demand DESC, d1.Priority, d1.Net_demand DESC, d1.Sort DESC) TopNeededItem

   IF @itnbr = 'SAMPLE' 
     BEGIN 
       SELECT @asn = asn_id, @Arrival = GETDATE()
	    ,@Expected_Arrival=expected_arrival
	     FROM dbo.t_asn WITH(NOLOCK) 
        WHERE asn_id = @Sample_asn 
     END 
   ELSE 
     BEGIN 
        SET @asn = NULL 
	    SET @Arrival = null
		SET @Expected_Arrival = NULL 

        SELECT 
			@asn = Asn,@Arrival = entered_yard 
			,@Expected_Arrival = expected_arrival
          FROM (SELECT TOP 1 asn_id AS Asn, entered_yard,expected_arrival
                FROM #_asn_detail AD 
                WHERE item_number = @itnbr AND quantity_shipped >= @Demand 
                AND asn_id NOT IN (SELECT Asn FROM #Demand WHERE Asn > '') 
                ORDER BY quantity_shipped ASC, entered_yard ASC) TopNeed 

        IF @asn IS NULL 
          BEGIN 
             SELECT @asn = Asn, @Arrival= entered_yard
					,@Expected_Arrival=expected_arrival
              FROM (SELECT TOP 1 asn_id as Asn, entered_yard
							,expected_arrival
                    FROM  #_asn_detail AD 
                    WHERE item_number = @itnbr
                    AND asn_id NOT IN (SELECT Asn FROM #Demand WHERE Asn > '') 
                    ORDER BY quantity_shipped DESC,entered_yard ASC) TopNeed 
          END 
      END 

      IF @asn IS NOT NULL 
       BEGIN 
           UPDATE #Demand 
               SET Net_demand = Net_demand - quantity_shipped,
					Sort = CASE WHEN item_number <> @itnbr  THEN CASE WHEN Demand = 0 THEN 0 ELSE(Net_demand)/(Demand * 1.000)END 
								ELSE Sort 
								END
            FROM (SELECT item_number, SUM(quantity_shipped) AS quantity_shipped
               	  FROM #_asn_detail 
              	  WHERE item_number <> 'SAMPLE'  AND asn_id = @asn
                  GROUP BY item_number) t1
            WHERE #Demand.Itnbr = item_number 
				AND #Demand.Asn = ''

           UPDATE #Demand SET Asn = @asn, Arrival = @Arrival
							,Expected_Arrival = @Expected_Arrival
            WHERE #Demand.Itnbr = @itnbr AND #Demand.Priority = @Priority 
						AND Asn = '' AND @itnbr <> 'SAMPLE'

           UPDATE #Demand SET Asn = @asn, Arrival = @Arrival 
							,Expected_Arrival=@Expected_Arrival
            WHERE #Demand.Itnbr = 'SAMPLE' AND Sample_asn = @asn 

           SET @Count = @Count + 1

           IF @itnbr <> 'SAMPLE'
              BEGIN
                DELETE FROM #Demand WHERE #Demand.Sample_asn = @asn AND #Demand.Itnbr = 'SAMPLE' 
              END

           INSERT INTO #Demand (Priority, Itnbr, Demand, Sort, Asn, Net_demand) 
				 SELECT Priority, Itnbr, Net_demand, 
						CASE WHEN Demand = 0 THEN 0 ELSE(Net_demand)/(Demand * 1.000) END AS Sort,
						'' AS asn, Net_demand 
					FROM #Demand 
					WHERE Asn = @asn AND Net_demand > 0  AND Itnbr <> 'SAMPLE' AND Priority = @Priority 

             DELETE FROM #Demand WHERE Net_demand <= 0 AND Asn = '' AND Priority <> 'E' 
          END
        ELSE 
          BEGIN 
            DELETE FROM  #Demand WHERE Itnbr = @itnbr AND Asn = '' 
          END 
END  

SELECT AD.item_number,asn_id AS Asn2, 
        ISNULL(BLDG.building, @BldgPick) AS forward_pick_building,
        ISNULL(overflow_building, @BldgPick) AS overflow_pick_building, 
        ISNULL(length,1) AS length,ISNULL(width,1) AS width,ISNULL(height,1) AS height, 
        SUM(ISNULL(AD.quantity_shipped,0)) AS asn_qty, 
        SUM(ISNULL(AD.quantity_received,0)) AS asn_recvd, 
        SUM(ISNULL(onhand_fwd_pick_bldg,0)) AS onhand_fwd_pick_bldg, 
        SUM(ISNULL(onhand_whse,0)) AS onhand_whse, 
        SUM(ISNULL(fwd_pick_bldg_thresh,0)) AS fwd_pick_bldg_thresh, 
        SUM(ISNULL(on_site_threshold,0)) AS on_site_threshold 
INTO #Disposition 
FROM #_asn_detail AD
LEFT JOIN dbo.t_item_uom IM WITH(NOLOCK) ON AD.item_number = IM.item_number AND default_pick_uom = 'YES'
LEFT JOIN #Demand DM ON AD.asn_id = DM.Asn 
LEFT JOIN (SELECT MAX(LEFT(location_id,2)) AS building, item_number,wh_id 
				FROM dbo.t_fwd_pick WITH(NOLOCK) 
				GROUP BY item_number,wh_id) BLDG      
		ON BLDG.item_number = AD.item_number
			AND BLDG.wh_id=IM.wh_id 
LEFT JOIN dbo.t_class CL WITH(NOLOCK) ON IM.class_id = CL.class_id
			AND IM.wh_id = CL.wh_id
LEFT JOIN dbo.t_inventory_position INV WITH(NOLOCK) ON IM.item_number = INV.item_number AND IM.wh_id = INV.wh_id 
LEFT JOIN dbo.t_item_planning PL WITH(NOLOCK) ON PL.item_number = IM.item_number AND PL.wh_id = IM.wh_id 
GROUP BY asn_id, AD.item_number, overflow_building, BLDG.building, length, width, height 

CREATE INDEX Asn ON #Disposition (Asn2)
CREATE INDEX item ON #Disposition (item_number)

SELECT DISTINCT d1.*, wod.codis_order_number, wod.line_number 
INTO #mdc_trailers 
FROM #Disposition d1
JOIN dbo.t_mdcrdc_wave_order_detail wod (NOLOCK) ON wod.item_number = d1.item_number
WHERE (wod.released_quantity - wod.staged_quantity > 0) AND (wod.staged_quantity - wod.shipped_quantity >= 0 )
		AND   wod.codis_order_number IS NOT NULL

--DELETE all items that are not max qty.
DELETE x FROM (
  SELECT *, rn=row_number() OVER (PARTITION BY Asn2 ORDER BY asn_qty DESC)
  FROM #mdc_trailers 
) x
WHERE rn > 1;

UPDATE d 
SET d.Itnbr=mdc.item_number, isMDCRDC_with_net_demand=1
FROM #Demand d 
JOIN #mdc_trailers mdc ON mdc.Asn2=d.Asn and d.Itnbr=mdc.item_number
WHERE d.Net_demand > 0

UPDATE #Disposition SET forward_pick_building = ISNULL(@BldgOvrflw, @BldgPick), 
		overflow_pick_building = ISNULL(@BldgOvrflw, @BldgPick),
       length = 1, width = 1, height = 1 
WHERE item_number = 'SAMPLE'

DROP INDEX #Demand.itnbr
CREATE NONCLUSTERED INDEX priority ON #Demand (Priority, Net_demand DESC, Sort DESC)


DECLARE Suggested CURSOR 
FOR 
   --- Generate the list of all ASN's that do not have a disposition assigned.
   SELECT Asn FROM #Demand 
   WHERE ISNULL(Disposition,'') = '' AND Asn <> ''  
   ORDER BY Priority, Sort DESC
OPEN Suggested
FETCH NEXT FROM Suggested INTO @asn
WHILE (@@FETCH_STATUS <> -1) 
BEGIN 
   IF (@@FETCH_STATUS <> -2) 
   BEGIN 
      IF LEN(@asn) > 0 
	 BEGIN 
    	UPDATE #Demand 
          SET Suggested_Disposition = CASE WHEN fwd_pick_cubes >= overflow_cubes 
                                           THEN forward_pick_building 
                                           ELSE overflow_pick_building 
                                      END
			  --Percent_complete = CASE WHEN asn_qty IS NULL OR asn_recvd IS NULL THEN 0 
     --                                 WHEN asn_qty > 0 THEN ROUND((asn_recvd/asn_qty) * 100,0) 
     --                                 ELSE 0 
     --                            END 
  		  FROM (SELECT TOP 1 Asn2, SUM(asn_recvd) AS asn_recvd, SUM(asn_qty) AS asn_qty,
                       forward_pick_building, overflow_pick_building, 
			           SUM(CASE WHEN fwd_pick_bldg_thresh - onhand_fwd_pick_bldg > 0 
			                    AND fwd_pick_bldg_thresh - onhand_fwd_pick_bldg < asn_qty 
			                    THEN (length * width * height) * (fwd_pick_bldg_thresh - onhand_fwd_pick_bldg) 
                                ELSE 0 
                           END + 
			               CASE WHEN fwd_pick_bldg_thresh - onhand_fwd_pick_bldg >= asn_qty 
			  THEN (length * width * height) * asn_qty 
                                ELSE 0 
                           END) AS fwd_pick_cubes, 
			           SUM(CASE WHEN onhand_fwd_pick_bldg >  fwd_pick_bldg_thresh  
			                    Then (length*width*height)* asn_qty 
                                ELSE 0 
                           END + 
			               CASE WHEN asn_qty > (fwd_pick_bldg_thresh-onhand_fwd_pick_bldg)  
			                    Then (length*width*height)* (asn_qty - (fwd_pick_bldg_thresh-onhand_fwd_pick_bldg)) 
                                ELSE 0 
                           END) AS overflow_cubes
			    FROM #Disposition
                WHERE Asn2 = @asn
			    GROUP BY Asn2,forward_pick_building, overflow_pick_building
				ORDER BY fwd_pick_cubes DESC) T1 
        WHERE Asn = Asn2 AND Suggested_Disposition IS NULL 

		UPDATE #Disposition
             SET onhand_fwd_pick_bldg = CASE WHEN onhand_fwd_pick_bldg + D2.asn_qty > fwd_pick_bldg_thresh
                                             THEN fwd_pick_bldg_thresh 
                                             ELSE onhand_fwd_pick_bldg + D2.asn_qty 
                                             END
             FROM #Disposition D1, (SELECT item_number, asn_qty 
                                    FROM #Disposition
                                    WHERE Asn2 = @asn) D2
        WHERE D1.item_number = D2.item_number    

       END 
   END 
   FETCH NEXT FROM Suggested INTO @asn
END 
CLOSE Suggested
DEALLOCATE Suggested

UPDATE #Demand SET Disposition = disposition FROM dbo.t_asn (NOLOCK) 
WHERE Asn = asn_id  AND Disposition IS NULL

--2023/06/13 Grace correct percentage complete 
UPDATE dd
   SET dd.Percent_complete = CASE WHEN asn_qty IS NULL OR asn_recvd IS NULL THEN 0 
                                  WHEN asn_qty > 0 THEN ROUND((asn_recvd/asn_qty) * 100,0) 
                                  ELSE 0 
                              END 
FROM #Demand dd
JOIN (
		SELECT Asn2, SUM(asn_recvd) AS asn_recvd, SUM(asn_qty) AS asn_qty
          FROM #Disposition 
		 GROUP BY Asn2
)d
ON dd.Asn=d.Asn2

--end


--Step 5, Return the TOP 500
SELECT Priority, 
            CASE WHEN Priority IN ('A','B')
                 THEN LDM.load_id
                 ELSE NULL
            END AS load_id, 	--BC V4.0
            CASE WHEN Priority IN ('A','B')
                 THEN (LDM.dispatch_date + ' ' + RIGHT(LDM.dispatch_time,8))
                 ELSE NULL
            END AS dispatch_date, 	--BC V4.0
			CAST('' AS VARCHAR(2)) AS first_drop_state,
			Sort, Demand, t_asn.asn_number, t_asn.equipment_id, c.carrier_name, Itnbr, Arrival,
            ISNULL(Suggested_Disposition, Disposition) AS Suggested_Disposition, Disposition, 
            ISNULL(#t_trailer.status,'IN TRANSIT') AS status, location_name,
            ISNULL(#t_ya_work_q.zone,'None') AS Scheduled_To, Disposition_Unit,
            Review_Inventory, 
			Expected_Arrival,
            ISNULL(Percent_complete,0) AS Percent_complete, 
            CASE WHEN LDM.load_id IS NULL THEN 1
                 ELSE 0
            END AS Null_Sort,
			LDM.trip_type_id
INTO #_demand_equip_unload_tripped
FROM #Demand
JOIN dbo.t_asn (NOLOCK) 
  ON Asn = asn_id 
LEFT OUTER JOIN dbo.t_order_detail ORD WITH(NOLOCK)			
  ON ORD.item_number = Itnbr
 AND ORD.qty > ORD.qty_shipped
LEFT OUTER JOIN 
  (SELECT l.*, pkd.item_number, pkd.order_number 
		FROM #t_load_master_with_exclusion l 
			JOIN dbo.t_pick_detail pkd WITH(NOLOCK)
				ON l.load_id = pkd.load_id
	  			AND l.wh_id = pkd.wh_id 
		WHERE l.status IN ('R', 'A', 'H', 'C', 'W')
				AND l.trip_type_id <> 'U'
				AND l.load_type <> 'X'
				AND (pkd.planned_quantity - pkd.picked_quantity) > 0
				AND pkd.status NOT IN ('STAGED','LOADED')
   UNION
   SELECT l.*, ord.item_number, ord.order_number 
		FROM #t_load_master_with_exclusion l 
			join t_order (NOLOCK) orm on l.load_id=orm.load_id and l.wh_id=orm.wh_id
			join t_order_detail (NOLOCK) ord  on orm.order_number=ord.order_number and orm.wh_id=ord.wh_id
		WHERE l.status IN ('N','M')
	) AS LDM
	ON LDM.order_number= ORD.order_number   ---Grace change
	AND LDM.item_number = Itnbr
	AND LDM.wh_id = ORD.wh_id 
LEFT OUTER JOIN dbo.t_trailer_asn WITH(NOLOCK) ON t_asn.asn_id = t_trailer_asn.asn_id 
LEFT OUTER JOIN #t_trailer 
  ON t_trailer_asn.trailer_id = #t_trailer.trailer_id 
LEFT OUTER JOIN #t_ya_location
  ON #t_trailer.location_id = #t_ya_location.location_id
LEFT OUTER JOIN #t_ya_work_q 
  ON #t_trailer.trailer_id = #t_ya_work_q.trailer_id 
  AND #t_ya_work_q.status = 'UNASSIGNED' 
  AND #t_ya_work_q.type = '52'
LEFT OUTER JOIN #t_carrier c 
ON c.carrier_id = #t_trailer.carrier_id
WHERE #t_trailer.status NOT IN ('HISTORY') 
AND #t_trailer.state NOT IN ('EMPTY')											
ORDER BY Null_Sort, Priority,LDM.dispatch_date,	LDM.dispatch_time, Itnbr, Demand DESC, Sort DESC, Arrival	

UPDATE t SET first_drop_state = (SELECT TOP 1 ocn.ship_to_state  
						FROM dbo.t_order_c_number ocn (NOLOCK) 
						JOIN dbo.t_order orm (NOLOCK) ON orm.wh_id = ocn.wh_id AND orm.order_number = ocn.order_number   ---grace add
						WHERE orm.load_id LIKE t.load_id+'%'  
						)
						FROM  #_demand_equip_unload_tripped t
						WHERE t.Priority in ('A','B') 


--Step 5.1 Create Tripless Order Version
SELECT Priority, 
            CASE WHEN Priority IN ('A','B')
            THEN LDM.order_number
                 ELSE NULL
            END AS load_id, 	--BC V4.0
            CASE WHEN Priority IN ('A','B')
                 THEN LDM.promise_date
                 ELSE NULL
            END AS dispatch_date, 	--BC V4.0
	       CASE WHEN Priority in('A','B')
		        THEN (SELECT TOP 1 state FROM dbo.t_whse (NOLOCK))
				ELSE NULL 
			END AS first_drop_state,
			Sort, Demand, t_asn.asn_number, t_asn.equipment_id, c.carrier_name, Itnbr, Arrival,
            ISNULL(Suggested_Disposition, Disposition) AS Suggested_Disposition, Disposition, 
            ISNULL(#t_trailer.status,'IN TRANSIT') AS status, location_name,
            ISNULL(#t_ya_work_q.zone,'None') AS Scheduled_To, Disposition_Unit,
            Review_Inventory, 
			Expected_Arrival,
            ISNULL(Percent_complete,0) AS Percent_complete, 
            CASE WHEN LDM.order_number IS NULL THEN 1
                 ELSE 0
            END as Null_Sort,
			'U' as trip_type_id
INTO #_demand_equip_unload_tripless
FROM #Demand 
JOIN dbo.t_asn (NOLOCK) 
  ON Asn = asn_id 
LEFT OUTER JOIN dbo.t_order_detail ORD WITH(NOLOCK)			
  ON ORD.item_number = Itnbr
 AND ORD.qty > ORD.qty_shipped
LEFT OUTER JOIN 
  (SELECT o2.*, pkd.item_number 
	FROM dbo.t_order (NOLOCK) o2
    JOIN dbo.t_pick_detail pkd WITH(NOLOCK) ON o2.order_number = pkd.order_number AND o2.wh_id = pkd.wh_id 
   WHERE 1=1 
		--and pkd.status IN ('RELEASED','PENDING','NEW')
		and pkd.status not in ('BACKORDER','CANCELED')
		--AND o2.status NOT IN ('CANCELED', 'SHIPPED')
		and o2.status  IN ('NEW','RELEASED') 
		AND (pkd.planned_quantity - pkd.picked_quantity) > 0
		AND o2.order_type_2 = 'U'
	) AS LDM
	ON LDM.order_number = ORD.order_number
	AND (LDM.item_number = Itnbr or LDM.item_number IS NULL)
	AND LDM.wh_id = ORD.wh_id 
LEFT OUTER JOIN dbo.t_trailer_asn WITH(NOLOCK) ON t_asn.asn_id = t_trailer_asn.asn_id 
LEFT OUTER JOIN #t_trailer 
  ON t_trailer_asn.trailer_id = #t_trailer.trailer_id 
LEFT OUTER JOIN #t_ya_location 
  ON #t_trailer.location_id = #t_ya_location.location_id
LEFT OUTER JOIN #t_ya_work_q 
  ON #t_trailer.trailer_id = #t_ya_work_q.trailer_id 
  AND #t_ya_work_q.status = 'UNASSIGNED' 
  AND #t_ya_work_q.type = '52'
LEFT OUTER JOIN #t_carrier c 
ON c.carrier_id = #t_trailer.carrier_id
WHERE #t_trailer.status NOT IN ('HISTORY') 
AND #t_trailer.state NOT IN ('EMPTY')
AND LDM.order_type_2 = 'U'											
ORDER BY Null_Sort, Priority,LDM.dispatch_date,	LDM.dispatch_time, Itnbr, Demand DESC, Sort DESC, Arrival	


--Tripless Billable Xdock
SELECT ldm.*,o2.promise_date,pkd.order_number, pkd.item_number
		INTO #LDM
		FROM dbo.t_order (NOLOCK) o2
		JOIN dbo.t_pick_detail pkd WITH(NOLOCK) ON o2.order_number = pkd.order_number AND o2.wh_id = pkd.wh_id
		JOIN #Demand d ON pkd.item_number = Itnbr
		JOIN #t_load_master ldm (NOLOCK)ON ldm.load_id = o2.load_id AND ldm.wh_id = o2.wh_id
	WHERE pkd.status NOT IN ('STAGED','LOADED')
		AND o2.status NOT IN ('CANCELED', 'SHIPPED')
		AND (pkd.planned_quantity - pkd.picked_quantity) > 0
		AND ldm.load_type = 'X'

SELECT Priority, 
            CASE WHEN Priority IN ('A','B')
                 THEN LDM.load_id
                 ELSE NULL
            END as load_id, 	--BC V4.0
            CASE WHEN Priority IN ('A','B')
                 THEN  (LDM.dispatch_date + ' ' + right(LDM.dispatch_time,8))
                 ELSE NULL
            END AS dispatch_date, 	--BC V4.0
	       CASE WHEN Priority IN ('A','B')
		        Then (SELECT TOP 1 state FROM dbo.t_whse (NOLOCK))
				ELSE NULL 
			END AS first_drop_state,
			Sort, Demand, t_asn.asn_number, t_asn.equipment_id, c.carrier_name, Itnbr, Arrival,
            ISNULL(Suggested_Disposition, Disposition) AS Suggested_Disposition, Disposition, 
            ISNULL(#t_trailer.status,'IN TRANSIT') AS status, location_name,
            ISNULL(#t_ya_work_q.zone,'None') AS Scheduled_To, Disposition_Unit,
            Review_Inventory, 
			Expected_Arrival,
            ISNULL(Percent_complete,0) AS Percent_complete, 
            CASE WHEN LDM.order_number IS NULL THEN 1
                 ELSE 0
            END as Null_Sort,
			LDM.trip_type_id as trip_type_id
INTO #_demand_equip_unload_triplessxdock
FROM #Demand 
JOIN dbo.t_asn (NOLOCK) 
  ON Asn = asn_id 
LEFT OUTER JOIN dbo.t_order_detail ORD WITH(NOLOCK)			
  ON ORD.item_number = Itnbr
 AND ORD.qty > ORD.qty_shipped
LEFT OUTER JOIN #LDM LDM
 -- (SELECT ldm.*,o2.promise_date,pkd.order_number, pkd.item_number 
	--	FROM dbo.t_order (NOLOCK) o2
	--	JOIN dbo.t_pick_detail pkd WITH(NOLOCK) ON o2.order_number = pkd.order_number AND o2.wh_id = pkd.wh_id
	--	JOIN #t_load_master ldm ON ldm.load_id = o2.load_id AND ldm.wh_id = o2.wh_id
	--WHERE pkd.status NOT IN ('STAGED','LOADED')
	--	AND o2.status NOT IN ('CANCELED', 'SHIPPED')
	--	AND (pkd.planned_quantity - pkd.picked_quantity) > 0
	--	AND ldm.load_type = 'X'
 --  ) AS LDM
	ON LDM.order_number = ORD.order_number
	AND (LDM.item_number = Itnbr OR LDM.item_number IS NULL)
	AND LDM.wh_id = ORD.wh_id 
LEFT OUTER JOIN dbo.t_trailer_asn WITH(NOLOCK) ON t_asn.asn_id = t_trailer_asn.asn_id 
LEFT OUTER JOIN #t_trailer 
  ON t_trailer_asn.trailer_id = #t_trailer.trailer_id 
LEFT OUTER JOIN #t_ya_location  
  ON #t_trailer.location_id = #t_ya_location.location_id
LEFT OUTER JOIN #t_ya_work_q  
  ON #t_trailer.trailer_id = #t_ya_work_q.trailer_id 
  AND #t_ya_work_q.status = 'UNASSIGNED' 
  AND #t_ya_work_q.type = '52'
LEFT OUTER JOIN #t_carrier c 
ON c.carrier_id = #t_trailer.carrier_id
WHERE #t_trailer.status NOT IN ('HISTORY') 
AND #t_trailer.state NOT IN ('EMPTY')
AND LDM.load_type = 'X'											
ORDER BY Null_Sort, Priority,LDM.dispatch_date,	LDM.dispatch_time, Itnbr, Demand DESC, Sort DESC, Arrival	


 SELECT *
 INTO #_demand_equip_unload_tmp
 FROM (
 SELECT * FROM #_demand_equip_unload_tripped
  UNION ALL
 SELECT * FROM #_demand_equip_unload_tripless
  UNION ALL
  SELECT * FROM #_demand_equip_unload_triplessxdock)
 XYZ

SELECT *
 INTO #_demand_equip_unload
 FROM #_demand_equip_unload_tmp
 ORDER BY Null_Sort, Priority,dispatch_date, Itnbr, Demand DESC, Sort DESC, Arrival


DROP TABLE #_demand_equip_unload_tmp
DROP TABLE #_demand_equip_unload_tripless
DROP TABLE #_demand_equip_unload_tripped
DROP TABLE #_demand_equip_unload_triplessxdock


DROP TABLE #Demand
DROP TABLE #Disposition
DROP TABLE #temp_transfer 
DROP TABLE #temp_backorder

--Start BC V4.0
CREATE TABLE #DemandTable (Priority VARCHAR(1), load_id VARCHAR(30), dispatch_date DATETIME, 
first_drop_state VARCHAR(10),
	Sort DECIMAL(12,4), Demand DECIMAL(12,0), asn_number VARCHAR(30), equipment_id VARCHAR(50),  carrier_name VARCHAR(100), 
	Itnbr VARCHAR(15), Arrival DATETIME,Suggested_Disposition VARCHAR(30), Disposition VARCHAR(30), 
	status VARCHAR(50),	location_name VARCHAR(50), Scheduled_To VARCHAR(50), 
	Disposition_Unit VARCHAR(5) DEFAULT 'Go To', Review_Inventory VARCHAR(5) DEFAULT 'Go To', 
	Expected_Arrival DATETIME, 
	 Percent_complete DECIMAL (7,0), Null_Sort INT
	 ,backorder_cube INT DEFAULT(0)
	 ,trip_type_id VARCHAR(10) 
	 )

CREATE TABLE #SEFU_Temp
(
highlight VARCHAR(30),
unload_priority VARCHAR (1),
load_id VARCHAR(30),
dispatch_date DATETIME,
first_drop_state VARCHAR(10),
equipment_id VARCHAR(50),
carrier_name VARCHAR(100),
Itnbr VARCHAR(15),
status VARCHAR(50),
location_name VARCHAR(50),
Suggested_Disposition VARCHAR(30),
Disposition_Unit VARCHAR(5),
Disposition VARCHAR(30),
zone VARCHAR(50),
priority VARCHAR(3),
scheduled_by VARCHAR(50),
asn_number VARCHAR(30),
Arrival DATETIME,
Expected_Arrival DATETIME, 
Percent_complete DECIMAL (7,0),
 Review_Inventory VARCHAR(5),
trailer_id INT,
area_id INT,
work_q_id INT,
Null_Sort INT,
Demand DECIMAL(12,0),
Sort DECIMAL(12,4),
backorder_cube INT
)
INSERT INTO #DemandTable(Priority 
,load_id
,dispatch_date
,first_drop_state
,Sort
,Demand
,asn_number
,equipment_id
,carrier_name
,Itnbr
,Arrival 
,Suggested_Disposition
,Disposition
,status
,location_name
,Scheduled_To  
,Disposition_Unit 
,Review_Inventory
,Expected_Arrival   
,Percent_complete
,Null_Sort
,trip_type_id
)
SELECT Priority 
,load_id
,dispatch_date
,first_drop_state
,Sort
,Demand
,asn_number
,equipment_id
,carrier_name
,Itnbr
,Arrival 
,Suggested_Disposition
,Disposition
,status
,location_name
,Scheduled_To  
,Disposition_Unit 
,Review_Inventory
,Expected_Arrival   
,Percent_complete
,Null_Sort
,trip_type_id
FROM 
(
SELECT DISTINCT	* ,
				RANK() OVER (PARTITION BY equipment_id 
							ORDER BY Null_Sort, Itnbr,
							CASE WHEN trip_type_id = 'M' AND Priority = 'A' then 'A' 
								 WHEN trip_type_id = 'U' AND Priority = 'A' then 'A' 
								 ELSE 'Z' end , 
							dispatch_date, Priority, Demand, Sort, Arrival, load_id, asn_number,
							equipment_id, Suggested_Disposition, Disposition, status, location_name,
							Scheduled_To, Disposition_Unit, Review_Inventory, Expected_Arrival, Percent_complete, carrier_name,first_drop_state
) rnk
FROM #_demand_equip_unload 
 
 )t WHERE rnk = 1  
 ORDER BY Null_Sort, Itnbr, dispatch_date, Priority, Demand DESC, Sort DESC, Arrival, load_id
  
 EXEC usp_get_ASN_cube

 --2023/04/10 Grace add for 977772 exclude ecoms order duplicated display
 IF EXISTS(SELECT load_id,Itnbr,count(DISTINCT asn_number) AS asn_count
			FROM #DemandTable 
			where 1=1
				and load_id in (SELECT order_number
								FROM dbo.t_order (NOLOCK)
								WHERE order_type_2 = 'U')
			GROUP BY load_id,Itnbr
			HAVING count(DISTINCT asn_number)>=2
			)

 --exec usp_update_ecoms_order_P @wh_id
 EXEC usp_update_ecoms_order @wh_id 

--2023/04/10 end of change 
IF @in_vch_sefu_version IN ('DEFAULT','SHUTTLE') --08/12/2023 - Pallav - 1075119 - SEFU Consolidation
BEGIN


IF @in_select = 'UPH'
INSERT INTO #SEFU_Temp
SELECT  CASE WHEN  U.trip_type_id = 'U' AND U.Priority IN ('A') THEN  '{{BGCOLOR=RED}}'
             WHEN  U.trip_type_id = 'M' AND U.Priority IN ('A') THEN  '{{BGCOLOR=YELLOW}}'
			ELSE  '' END AS highlight,
	 U.Priority AS unload_priority, U.load_id, U.dispatch_date,
	U.first_drop_state,	
		U.equipment_id, U.carrier_name, U.Itnbr, U.status, U.location_name, U.Suggested_Disposition, 
		(CASE WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type = 'X' WHERE container_id = t_asn.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL ELSE U.Disposition_Unit END) AS Disposition_Unit, 
		U.Disposition, #t_ya_work_q.zone, #t_ya_work_q.priority,
        (SELECT TOP 1 user_name 
			FROM dbo.t_ya_tran_log WITH(NOLOCK) 
			WHERE trailer_id = T.trailer_id AND tran_type IN ('300','399')
			ORDER BY ended DESC) AS scheduled_by, U.asn_number, U.Arrival,
	U.Expected_Arrival,
	    U.Percent_complete, U.Review_Inventory, T.trailer_id, T.area_id, #t_ya_work_q.work_q_id
	,Null_Sort, Demand, Sort
	,U.backorder_cube  /*---Grace add  */
	FROM #DemandTable U 
    JOIN dbo.t_asn (NOLOCK)
            ON t_asn.asn_number = U.asn_number
	JOIN  dbo.t_area_wh_id ahse (NOLOCK)  ON  ahse.area_id=t_asn.area_id 
    LEFT OUTER JOIN dbo.t_trailer_asn TRA (NOLOCK)
            ON TRA.asn_id = t_asn.asn_id
    LEFT OUTER JOIN #t_trailer T 
            ON TRA.trailer_id = T.trailer_id           
            AND T.status NOT IN ('HISTORY')          
            AND T.state <> 'EMPTY'
LEFT OUTER JOIN #t_ya_location loc 
	   ON loc.location_id = T.location_id
    LEFT OUTER JOIN #t_ya_work_q 
            ON T.trailer_id = #t_ya_work_q.trailer_id
            AND #t_ya_work_q.status = 'UNASSIGNED' 
            AND #t_ya_work_q.type = '52' 
     LEFT OUTER JOIN #t_carrier c 
     ON T.carrier_id = c.carrier_id
	 LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = t_asn.asn_id
	WHERE (U.Itnbr IN (SELECT item_number FROM dbo.t_item_master WITH(NOLOCK)
						--WHERE LEFT(t_item_master.class_id,3) = 'UPH'
						WHERE t_item_master.pick_put_id='UPH'  --2023/03/02 Grace change
						) 
		OR U.Itnbr = 'SAMPLE')
		AND T.area_id LIKE @in_area
	
UNION 

SELECT '' AS highlight, 
	  'F'         AS unload_priority,
       ''                     AS load_id,
       NULL                   AS dispatch_date,
       ''                     AS first_drop_state,
       ASN.equipment_id,
       ASN.carrier_name,
    ASN.item_number        AS Itnbr,
       ASN.status,
       loc.location_name,
       ''                     AS Suggested_Disposition,
       ( CASE
           WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type = 'X' WHERE container_id = ASN1.asn_number AND  x.asn_id IS NOT NULL)
			)  THEN NULL
 ELSE 'Go To'
         END )                AS Disposition_Unit,
       loc.location_name      AS Disposition,
       #t_ya_work_q.zone,
       #t_ya_work_q.priority,
       (SELECT TOP 1 user_name
        FROM   dbo.t_ya_tran_log WITH(NOLOCK)
        WHERE  trailer_id = T.trailer_id
               AND tran_type IN ( '300', '399' )
        ORDER  BY ended DESC) AS scheduled_by,
       ASN1.asn_number,
       ASN.entered_yard       AS Arrival,
       ASN.expected_arrival   AS Expected_Arrival,
       ( CASE
           WHEN ASN.quantity_received IS NULL
                 OR ASN.quantity_received IS NULL THEN 0
           WHEN ASN.quantity_received > 0 THEN Round(( ASN.quantity_received / ASN.quantity_shipped ) * 100, 0)
           ELSE 0
         END )                AS Percent_complete,
       'Go To'                AS Review_Inventory,
       T.trailer_id,
       T.area_id,
       #t_ya_work_q.work_q_id,
       0                      AS Null_Sort,
       0                      AS Demand,
       0                      AS Sort
	, ASN.backorder_cube  /*---Grace add  */
FROM   #_asn_detail ASN 
       JOIN (SELECT MIN(asn.item_number) AS item_number,
                    equipment_id
             FROM   #_asn_detail asn 
			 JOIN dbo.t_item_master itm(NOLOCK) ON itm.item_number = asn.item_number
			 WHERE  commodity_code NOT LIKE  'Z__K' AND commodity_code LIKE 'Z%'
             GROUP  BY equipment_id) temp
         ON ASN.equipment_id = temp.equipment_id
            AND ASN.item_number = temp.item_number
       JOIN dbo.t_asn ASN1 (NOLOCK)
         ON ASN.asn_id = ASN1.asn_id
       LEFT OUTER JOIN dbo.t_trailer_asn TRA (NOLOCK)
                    ON TRA.asn_id = ASN.asn_id
      LEFT OUTER JOIN #t_trailer T 
                    ON TRA.trailer_id = T.trailer_id
                       AND T.status NOT IN ( 'HISTORY' )
                       AND T.state <> 'EMPTY'
       LEFT OUTER JOIN #t_ya_location loc 
                    ON loc.location_id = T.location_id
       LEFT OUTER JOIN #t_ya_work_q 
                    ON T.trailer_id = #t_ya_work_q.trailer_id
                       AND #t_ya_work_q.status = 'UNASSIGNED'
                       AND #t_ya_work_q.type = '52'
       LEFT OUTER JOIN #t_carrier c 
                    ON T.carrier_id = c.carrier_id
	  LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = ASN1.asn_id
WHERE  (ASN.item_number IN (SELECT item_number
                           FROM   dbo.t_item_master WITH(NOLOCK)
                           --WHERE  LEFT(t_item_master.class_id, 3) = 'UPH'
						   WHERE t_item_master.pick_put_id='UPH'  --2023/03/02 Grace change
						   )
        OR ASN.item_number = 'SAMPLE' )
           AND T.area_id LIKE @in_area
           AND ASN.equipment_id NOT IN (SELECT equipment_id
        FROM   #DemandTable)
ORDER  BY unload_priority,
          Null_Sort,
          dispatch_date,
          Demand DESC,
          Sort DESC,
          Arrival,
          Itnbr,
          load_id 

ELSE

IF @in_select = 'NONUPH'
INSERT INTO #SEFU_Temp
SELECT CASE WHEN  U.trip_type_id = 'U' and U.Priority IN ('A') then  '{{BGCOLOR=RED}}'
            WHEN  U.trip_type_id = 'M' AND U.Priority IN ('A') THEN  '{{BGCOLOR=YELLOW}}'
			 ELSE  '' END AS highlight,
	U.Priority AS unload_priority, U.load_id, U.dispatch_date,	
	U.first_drop_state,	
		U.equipment_id, U.carrier_name, U.Itnbr, U.status, U.location_name, U.Suggested_Disposition, 
		(CASE WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm (NOLOCK) INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type = 'X' WHERE container_id = t_asn.asn_number AND  x.asn_id IS NOT NULL)
			)  THEN NULL ELSE U.Disposition_Unit END) AS Disposition_Unit, 
		U.Disposition, #t_ya_work_q.zone, #t_ya_work_q.priority,
        (SELECT TOP 1 user_name 
			FROM dbo.t_ya_tran_log WITH(NOLOCK) 
			WHERE trailer_id = T.trailer_id AND tran_type IN ('300','399')
			ORDER BY ended DESC) AS scheduled_by, U.asn_number, U.Arrival, 
	     U.Expected_Arrival,
	    U.Percent_complete, U.Review_Inventory, T.trailer_id, T.area_id, #t_ya_work_q.work_q_id
	,Null_Sort, Demand, Sort	
	,U.backorder_cube  /*---Grace add  */
	FROM #DemandTable U 
    JOIN dbo.t_asn (NOLOCK) 
            ON t_asn.asn_number = U.asn_number
	JOIN  dbo.t_area_wh_id ahse (NOLOCK)  ON  ahse.area_id = t_asn.area_id  

    LEFT OUTER JOIN dbo.t_trailer_asn TRA WITH(NOLOCK)
            ON TRA.asn_id = t_asn.asn_id
    LEFT OUTER JOIN #t_trailer T 
            ON TRA.trailer_id = T.trailer_id 
             AND T.status NOT IN ('HISTORY')
             AND T.state <> 'EMPTY'
LEFT OUTER JOIN #t_ya_location loc 
	   ON loc.location_id = T.location_id

    LEFT OUTER JOIN #t_ya_work_q 
            ON T.trailer_id = #t_ya_work_q.trailer_id
            AND #t_ya_work_q.status = 'UNASSIGNED' 
            AND #t_ya_work_q.type = '52' 
     LEFT OUTER JOIN #t_carrier c 
			ON T.carrier_id = c.carrier_id
	LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = t_asn.asn_id
		WHERE (U.Itnbr IN (SELECT item_number FROM dbo.t_item_master WITH(NOLOCK)
					--WHERE LEFT(ISNULL(t_item_master.class_id,'NEW'),3) <> 'UPH'
					WHERE t_item_master.pick_put_id <> 'UPH'   --2023/03/02 Grace change
					) 
		OR U.Itnbr = 'SAMPLE')
		AND T.area_id LIKE @in_area
		
UNION 

SELECT ''                     AS highlight, 	
	   'F'                    AS unload_priority,
       ''                     AS load_id,
       NULL                   AS dispatch_date,
       ''                AS first_drop_state,
 ASN.equipment_id,
       ASN.carrier_name,
       ASN.item_number        AS Itnbr,
       ASN.status,
       loc.location_name,
       ''                     AS Suggested_Disposition,
       ( CASE
WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type = 'X' WHERE container_id = ASN1.asn_number AND  x.asn_id IS NOT NULL)
			)  THEN NULL
           ELSE 'Go To'
         END )                AS Disposition_Unit,
       loc.location_name      AS Disposition,
       #t_ya_work_q.zone,
       #t_ya_work_q.priority,
       (SELECT TOP 1 user_name
  FROM   dbo.t_ya_tran_log WITH(NOLOCK)
        WHERE  trailer_id = T.trailer_id
               AND tran_type IN ( '300', '399' )
        ORDER  BY ended DESC) AS scheduled_by,
       ASN1.asn_number,
       ASN.entered_yard       AS Arrival,
       ASN.expected_arrival   AS Expected_Arrival,
       ( CASE
           WHEN ASN.quantity_received IS NULL
                 OR ASN.quantity_received IS NULL THEN 0
           WHEN ASN.quantity_received > 0 THEN ROUND(( ASN.quantity_received / ASN.quantity_shipped ) * 100, 0)
           ELSE 0
         END )                AS Percent_complete,
       'Go To'                AS Review_Inventory,
       T.trailer_id,
       T.area_id,
       #t_ya_work_q.work_q_id,
       0                      AS Null_Sort,
       0                      AS Demand,
       0                      AS Sort
	,ASN.backorder_cube  /*---Grace add  */
FROM   #_asn_detail ASN WITH(NOLOCK)
       JOIN (SELECT MIN(asn.item_number) AS item_number,
                    equipment_id
             FROM   #_asn_detail asn 
			 JOIN dbo.t_item_master itm(NOLOCK) ON itm.item_number = asn.item_number
			 WHERE  commodity_code NOT LIKE  'Z__K' AND commodity_code LIKE 'Z%'
             GROUP  BY equipment_id) temp
         ON ASN.equipment_id = temp.equipment_id
            AND ASN.item_number = temp.item_number
       JOIN dbo.t_asn ASN1(NOLOCK)
ON ASN.asn_id = ASN1.asn_id
       LEFT OUTER JOIN dbo.t_trailer_asn TRA (NOLOCK)
                    ON TRA.asn_id = ASN.asn_id
       LEFT OUTER JOIN #t_trailer T 
                    ON TRA.trailer_id = T.trailer_id
                       AND T.status NOT IN ( 'HISTORY' )
                       AND T.state <> 'EMPTY'
       LEFT OUTER JOIN #t_ya_location loc 
                    ON loc.location_id = T.location_id
       LEFT OUTER JOIN #t_ya_work_q 
                    ON T.trailer_id = #t_ya_work_q.trailer_id
                       AND #t_ya_work_q.status = 'UNASSIGNED'
                       AND #t_ya_work_q.type = '52'
       LEFT OUTER JOIN #t_carrier c 
                    ON T.carrier_id = c.carrier_id
		LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = ASN1.asn_id
WHERE ( ASN.item_number IN (SELECT item_number
                           FROM   dbo.t_item_master (NOLOCK)
                           --WHERE  LEFT(ISNULL(t_item_master.class_id, 'NEW'), 3) <> 'UPH'
						   WHERE t_item_master.pick_put_id <> 'UPH'  --2023/03/02 Grace change
						   )
        OR ASN.item_number = 'SAMPLE')
           AND T.area_id LIKE @in_area
           AND ASN.equipment_id NOT IN (SELECT equipment_id FROM   #DemandTable)
ORDER  BY unload_priority,
    Null_Sort,
          dispatch_date,
          Demand DESC,
          Sort DESC,
          Arrival,
          Itnbr,
          load_id 
ELSE
IF @in_select = 'ALL'
INSERT INTO #SEFU_Temp
SELECT CASE WHEN  U.trip_type_id = 'U' and U.Priority IN ('A') THEN  '{{BGCOLOR=RED}}'
            WHEN  U.trip_type_id = 'M' AND U.Priority IN ('A') THEN  '{{BGCOLOR=YELLOW}}'
			ELSE  '' END as highlight,
	U.Priority as unload_priority, U.load_id, U.dispatch_date,
	U.first_drop_state,	
	U.equipment_id, U.carrier_name, U.Itnbr, U.status, U.location_name, U.Suggested_Disposition,
		(CASE WHEN (loc.[type] = 'DRAYAGE'			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type='X' WHERE container_id = t_asn.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL ELSE U.Disposition_Unit END) AS Disposition_Unit, 
		U.Disposition, #t_ya_work_q.zone, #t_ya_work_q.priority,

        (SELECT TOP 1 user_name 
			FROM dbo.t_ya_tran_log WITH(NOLOCK) 
			WHERE trailer_id = T.trailer_id AND tran_type IN ('300','399')
			ORDER BY ended DESC) AS scheduled_by, U.asn_number, U.Arrival, 
	       U.Expected_Arrival,
	    U.Percent_complete, U.Review_Inventory, T.trailer_id, T.area_id, #t_ya_work_q.work_q_id
	,Null_Sort, Demand, Sort
	,U.backorder_cube  /*---Grace add  */
	FROM #DemandTable U 
    JOIN dbo.t_asn (NOLOCK)
            ON t_asn.asn_number = U.asn_number
	JOIN  dbo.t_area_wh_id ahse (NOLOCK)  ON  ahse.area_id=t_asn.area_id 
    LEFT OUTER JOIN dbo.t_trailer_asn TRA WITH(NOLOCK)
            ON TRA.asn_id = t_asn.asn_id
    LEFT OUTER JOIN #t_trailer T WITH(NOLOCK)
            ON TRA.trailer_id = T.trailer_id 
            AND T.status NOT IN ('HISTORY')
            AND T.state <> 'EMPTY'
	LEFT OUTER JOIN #t_ya_location loc 
	   ON loc.location_id = T.location_id
    LEFT OUTER JOIN #t_ya_work_q 
            ON T.trailer_id = #t_ya_work_q.trailer_id
            AND #t_ya_work_q.status = 'UNASSIGNED' 
            AND #t_ya_work_q.type = '52' 
    LEFT OUTER JOIN #t_carrier c 
			ON T.carrier_id = c.carrier_id
	LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = t_asn.asn_id
    WHERE T.area_id LIKE @in_area
UNION 

SELECT ''                    AS highlight, 
       'F'                    AS unload_priority,
       ''              AS load_id,
       NULL                   AS dispatch_date,
       ''                     AS first_drop_state,
       ASN.equipment_id,
       ASN.carrier_name,
       ASN.item_number        AS Itnbr,
       ASN.status,
       loc.location_name,
       ''                     AS Suggested_Disposition,
       ( CASE
           WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type='X' WHERE container_id = ASN1.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL
           ELSE 'Go To'
         END )                AS Disposition_Unit,
       loc.location_name      AS Disposition,
       #t_ya_work_q.zone,
       #t_ya_work_q.priority,
       (SELECT TOP 1 user_name
        FROM   dbo.t_ya_tran_log WITH(NOLOCK)
        WHERE  trailer_id = T.trailer_id
    AND tran_type IN ( '300', '399' )
        ORDER  BY ended DESC) AS scheduled_by,
       ASN1.asn_number,
       ASN.entered_yard       AS Arrival,
       ASN.expected_arrival   AS Expected_Arrival,
       ( CASE
           WHEN ASN.quantity_received IS NULL
                 OR ASN.quantity_received IS NULL THEN 0
           WHEN ASN.quantity_received > 0 THEN Round(( ASN.quantity_received / ASN.quantity_shipped ) * 100, 0)
           ELSE 0
         END )                AS Percent_complete,
       'Go To'                AS Review_Inventory,
       T.trailer_id,
       T.area_id,
       #t_ya_work_q.work_q_id,
       0                    AS Null_Sort,
       0                      AS Demand,
       0                      AS Sort
	,ASN.backorder_cube  /*---Grace add  */
FROM   #_asn_detail ASN 
       JOIN (SELECT MIN(asn.item_number) AS item_number,
                    equipment_id
             FROM   #_asn_detail asn 
			 JOIN dbo.t_item_master itm(NOLOCK) ON itm.item_number=asn.item_number
			 WHERE  commodity_code NOT LIKE  'Z__K' AND commodity_code LIKE 'Z%' 
             GROUP  BY equipment_id) temp
         ON ASN.equipment_id = temp.equipment_id
            AND ASN.item_number = temp.item_number
       JOIN dbo.t_asn ASN1(NOLOCK)
         ON ASN.asn_id = ASN1.asn_id
       LEFT OUTER JOIN dbo.t_trailer_asn TRA WITH(NOLOCK)
                    ON TRA.asn_id = ASN.asn_id
       LEFT OUTER JOIN #t_trailer T 
                    ON TRA.trailer_id = T.trailer_id
                       AND T.status NOT IN ( 'HISTORY' )
                       AND T.state <> 'EMPTY'
       LEFT OUTER JOIN #t_ya_location loc 
                    ON loc.location_id = T.location_id
       LEFT OUTER JOIN #t_ya_work_q 
                    ON T.trailer_id = #t_ya_work_q.trailer_id
                       AND #t_ya_work_q.status = 'UNASSIGNED'
                       AND #t_ya_work_q.type = '52'
       LEFT OUTER JOIN #t_carrier c 
                    ON T.carrier_id = c.carrier_id
		LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = ASN1.asn_id
WHERE  T.area_id LIKE @in_area
       AND ASN.equipment_id NOT IN (SELECT equipment_id
                                    FROM   #DemandTable)
ORDER  BY unload_priority,
          Null_Sort,
          dispatch_date,
          Demand DESC,
          Sort DESC,
          Arrival,
          Itnbr,
          load_id 

END

ELSE IF  @in_vch_sefu_version IN ('RM')
BEGIN


IF @in_select = 'KITS'
BEGIN
INSERT INTO #SEFU_Temp
SELECT CASE WHEN  U.trip_type_id = 'U' and U.Priority IN ('A') THEN  '{{BGCOLOR=RED}}'
            WHEN  U.trip_type_id = 'M' AND U.Priority IN ('A') THEN  '{{BGCOLOR=YELLOW}}'
			ELSE  '' END as highlight,
	U.Priority as unload_priority, U.load_id, U.dispatch_date,
	U.first_drop_state,	
	U.equipment_id, U.carrier_name, U.Itnbr, U.status, U.location_name, U.Suggested_Disposition,
		(CASE WHEN (loc.[type] = 'DRAYAGE'			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type='X' WHERE container_id = t_asn.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL ELSE U.Disposition_Unit END) AS Disposition_Unit, 
		U.Disposition, #t_ya_work_q.zone, #t_ya_work_q.priority,

        (SELECT TOP 1 user_name 
			FROM dbo.t_ya_tran_log (NOLOCK) 
			WHERE trailer_id = T.trailer_id AND tran_type IN ('300','399')
			ORDER BY ended DESC) AS scheduled_by, U.asn_number, U.Arrival, 
	       U.Expected_Arrival,
	    U.Percent_complete, U.Review_Inventory, T.trailer_id, T.area_id, #t_ya_work_q.work_q_id
	,Null_Sort, Demand, Sort
	,U.backorder_cube  /*---Grace add  */
	FROM #DemandTable U 
    JOIN dbo.t_asn (NOLOCK)
            ON t_asn.asn_number = U.asn_number
	JOIN  dbo.t_area_wh_id ahse (NOLOCK)  ON  ahse.area_id=t_asn.area_id 
    LEFT OUTER JOIN dbo.t_trailer_asn TRA (NOLOCK)
            ON TRA.asn_id = t_asn.asn_id
    LEFT OUTER JOIN #t_trailer T 
            ON TRA.trailer_id = T.trailer_id 
            AND T.status NOT IN ('HISTORY')
            AND T.state <> 'EMPTY'
	LEFT OUTER JOIN #t_ya_location loc 
	   ON loc.location_id = T.location_id
    LEFT OUTER JOIN #t_ya_work_q 
            ON T.trailer_id = #t_ya_work_q.trailer_id
            AND #t_ya_work_q.status = 'UNASSIGNED' 
            AND #t_ya_work_q.type = '52' 
    LEFT OUTER JOIN #t_carrier c 
			ON T.carrier_id = c.carrier_id
	LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = t_asn.asn_id
    WHERE T.area_id LIKE @in_area
		AND ( U.Itnbr IN (SELECT item_number FROM dbo.t_item_master (NOLOCK)
						WHERE LEFT(t_item_master.class_id,3)='KIT')
			  OR U.Itnbr = 'SAMPLE' )
UNION 

SELECT ''                    AS highlight, 
       'F'                    AS unload_priority,
       ''                     AS load_id,
       NULL                   AS dispatch_date,
       ''                     AS first_drop_state,
       ASN.equipment_id,
       ASN.carrier_name,
       ASN.item_number        AS Itnbr,
       ASN.status,
       loc.location_name,
       ''                     AS Suggested_Disposition,
       ( CASE
           WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type='X' WHERE container_id = ASN1.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL
           ELSE 'Go To'
         END )                AS Disposition_Unit,
       loc.location_name      AS Disposition,
       #t_ya_work_q.zone,
       #t_ya_work_q.priority,
       (SELECT TOP 1 user_name
        FROM   dbo.t_ya_tran_log (NOLOCK)
        WHERE  trailer_id = T.trailer_id
    AND tran_type IN ( '300', '399' )
        ORDER  BY ended DESC) AS scheduled_by,
       ASN1.asn_number,
       ASN.entered_yard       AS Arrival,
       ASN.expected_arrival   AS Expected_Arrival,
       ( CASE
           WHEN ASN.quantity_received IS NULL
                 OR ASN.quantity_received IS NULL THEN 0
           WHEN ASN.quantity_received > 0 THEN Round(( ASN.quantity_received / ASN.quantity_shipped ) * 100, 0)
           ELSE 0
         END )                AS Percent_complete,
       'Go To'                AS Review_Inventory,
       T.trailer_id,
       T.area_id,
       #t_ya_work_q.work_q_id,
       0                    AS Null_Sort,
       0                      AS Demand,
       0                      AS Sort
	,ASN.backorder_cube  /*---Grace add  */
FROM   #_asn_detail ASN 
       JOIN (SELECT MIN(asn.item_number) AS item_number,
                    equipment_id
             FROM   #_asn_detail asn (NOLOCK)
			 JOIN dbo.t_item_master itm(NOLOCK) ON itm.item_number=asn.item_number
			 WHERE  commodity_code LIKE  'Z__K' AND commodity_code LIKE 'Z%' 
             GROUP  BY equipment_id) temp
         ON ASN.equipment_id = temp.equipment_id
         AND ASN.item_number = temp.item_number
       JOIN dbo.t_asn ASN1(NOLOCK)
         ON ASN.asn_id = ASN1.asn_id
       LEFT OUTER JOIN dbo.t_trailer_asn TRA (nolock)
                    ON TRA.asn_id = ASN.asn_id
       LEFT OUTER JOIN #t_trailer T 
                    ON TRA.trailer_id = T.trailer_id
                       AND T.status NOT IN ( 'HISTORY' )
                       AND T.state <> 'EMPTY'
       LEFT OUTER JOIN #t_ya_location loc 
                    ON loc.location_id = T.location_id
       LEFT OUTER JOIN #t_ya_work_q 
                    ON T.trailer_id = #t_ya_work_q.trailer_id
                       AND #t_ya_work_q.status = 'UNASSIGNED'
                       AND #t_ya_work_q.type = '52'
       LEFT OUTER JOIN #t_carrier c 
                    ON T.carrier_id = c.carrier_id
		LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = ASN1.asn_id
WHERE  T.area_id LIKE @in_area
       AND ASN.equipment_id NOT IN (SELECT equipment_id
                                    FROM   #DemandTable)
		AND ( ASN.item_number IN (SELECT item_number FROM dbo.t_item_master (NOLOCK)
						WHERE LEFT(t_item_master.class_id,3)='KIT')
				OR ASN.item_number = 'SAMPLE' )
ORDER  BY unload_priority,
          Null_Sort,
          dispatch_date,
          Demand DESC,
          Sort DESC,
          Arrival,
          Itnbr,
          load_id 
END

IF @in_select = 'ALL'
BEGIN
INSERT INTO #SEFU_Temp
SELECT CASE WHEN  U.trip_type_id = 'U' and U.Priority IN ('A') THEN  '{{BGCOLOR=RED}}'
            WHEN  U.trip_type_id = 'M' AND U.Priority IN ('A') THEN  '{{BGCOLOR=YELLOW}}'
			ELSE  '' END as highlight,
	U.Priority as unload_priority, U.load_id, U.dispatch_date,
	U.first_drop_state,	
	U.equipment_id, U.carrier_name, U.Itnbr, U.status, U.location_name, U.Suggested_Disposition,
		(CASE WHEN (loc.[type] = 'DRAYAGE'			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm(NOLOCK) INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type='X' WHERE container_id = t_asn.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL ELSE U.Disposition_Unit END) AS Disposition_Unit, 
		U.Disposition, #t_ya_work_q.zone, #t_ya_work_q.priority,

        (SELECT TOP 1 user_name 
			FROM dbo.t_ya_tran_log (NOLOCK) 
			WHERE trailer_id = T.trailer_id AND tran_type IN ('300','399')
			ORDER BY ended DESC) AS scheduled_by, U.asn_number, U.Arrival, 
	       U.Expected_Arrival,
	    U.Percent_complete, U.Review_Inventory, T.trailer_id, T.area_id, #t_ya_work_q.work_q_id
	,Null_Sort, Demand, Sort
	,U.backorder_cube  /*---Grace add  */
	FROM #DemandTable U 
    JOIN dbo.t_asn (NOLOCK)
            ON t_asn.asn_number = U.asn_number
	JOIN  dbo.t_area_wh_id ahse (NOLOCK)  ON  ahse.area_id=t_asn.area_id 
    LEFT OUTER JOIN dbo.t_trailer_asn TRA (NOLOCK)
            ON TRA.asn_id = t_asn.asn_id
    LEFT OUTER JOIN #t_trailer T 
            ON TRA.trailer_id = T.trailer_id 
            AND T.status NOT IN ('HISTORY')
            AND T.state <> 'EMPTY'
	LEFT OUTER JOIN #t_ya_location loc 
	   ON loc.location_id = T.location_id
    LEFT OUTER JOIN #t_ya_work_q 
            ON T.trailer_id = #t_ya_work_q.trailer_id
            AND #t_ya_work_q.status = 'UNASSIGNED' 
            AND #t_ya_work_q.type = '52' 
    LEFT OUTER JOIN #t_carrier c 
			ON T.carrier_id = c.carrier_id
	LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = t_asn.asn_id
    WHERE T.area_id LIKE @in_area
UNION 

SELECT ''                    AS highlight, 
       'F'                    AS unload_priority,
       ''                     AS load_id,
       NULL                   AS dispatch_date,
       ''                     AS first_drop_state,
       ASN.equipment_id,
       ASN.carrier_name,
       ASN.item_number        AS Itnbr,
       ASN.status,
       loc.location_name,
       ''                     AS Suggested_Disposition,
       ( CASE
          WHEN (loc.[type] = 'DRAYAGE' 			OR  EXISTS
			(	SELECT TOP 1 ldm.load_id FROM  #t_load_master ldm INNER JOIN dbo.t_pick_detail pkd  (NOLOCK) 
				ON ldm.load_id = LEFT (pkd.order_number,10) AND ldm.load_type='X' WHERE container_id = ASN1.asn_number AND  x.asn_id IS NOT NULL)
			) THEN NULL
           ELSE 'Go To'
         END )                AS Disposition_Unit,
       loc.location_name      AS Disposition,
       #t_ya_work_q.zone,
       #t_ya_work_q.priority,
       (SELECT TOP 1 user_name
        FROM   dbo.t_ya_tran_log (NOLOCK)
        WHERE  trailer_id = T.trailer_id
    AND tran_type IN ( '300', '399' )
        ORDER  BY ended DESC) AS scheduled_by,
       ASN1.asn_number,
       ASN.entered_yard       AS Arrival,
       ASN.expected_arrival   AS Expected_Arrival,
       ( CASE
           WHEN ASN.quantity_received IS NULL
                 OR ASN.quantity_received IS NULL THEN 0
           WHEN ASN.quantity_received > 0 THEN Round(( ASN.quantity_received / ASN.quantity_shipped ) * 100, 0)
           ELSE 0
         END )                AS Percent_complete,
       'Go To'                AS Review_Inventory,
       T.trailer_id,
       T.area_id,
       #t_ya_work_q.work_q_id,
       0                    AS Null_Sort,
       0                      AS Demand,
       0                      AS Sort
	,ASN.backorder_cube  /*---Grace add  */
FROM   #_asn_detail ASN 
       JOIN (SELECT MIN(asn.item_number) AS item_number,
                    equipment_id
             FROM   #_asn_detail asn 
			 JOIN dbo.t_item_master itm(NOLOCK) ON itm.item_number=asn.item_number
			 WHERE  commodity_code LIKE  'Z__K' AND commodity_code LIKE 'Z%' 
             GROUP  BY equipment_id) temp
         ON ASN.equipment_id = temp.equipment_id
            AND ASN.item_number = temp.item_number
       JOIN dbo.t_asn ASN1(NOLOCK)
         ON ASN.asn_id = ASN1.asn_id
       LEFT OUTER JOIN dbo.t_trailer_asn TRA (NOLOCK)
                    ON TRA.asn_id = ASN.asn_id
       LEFT OUTER JOIN #t_trailer T 
                    ON TRA.trailer_id = T.trailer_id
                       AND T.status NOT IN ( 'HISTORY' )
                       AND T.state <> 'EMPTY'
       LEFT OUTER JOIN #t_ya_location loc 
                    ON loc.location_id = T.location_id
       LEFT OUTER JOIN #t_ya_work_q 
                    ON T.trailer_id = #t_ya_work_q.trailer_id
                       AND #t_ya_work_q.status = 'UNASSIGNED'
                       AND #t_ya_work_q.type = '52'
       LEFT OUTER JOIN #t_carrier c 
                    ON T.carrier_id = c.carrier_id
		LEFT  OUTER JOIN dbo.t_asn_xdock x(NOLOCK) ON x.asn_id = ASN1.asn_id
WHERE  T.area_id LIKE @in_area
       AND ASN.equipment_id NOT IN (SELECT equipment_id
                                    FROM   #DemandTable)
ORDER  BY unload_priority,
          Null_Sort,
          dispatch_date,
          Demand DESC,
          Sort DESC,
          Arrival,
          Itnbr,
          load_id 

END


END

----------------------------------------------V2 START-----------------------------

EXEC dbo.usp_calc_core_vs_fringe
----------------------------------------------V2 END----------------------------------
	 
SELECT a.equipment_id,c.item_number,
	--SUM(NULLIF(total_quantity,quantity_shipped)) AS total_piece,
	--SUM((NULLIF(total_quantity,quantity_shipped))*ISNULL(ISNULL(NULLIF(d.nested_volume,0),d.unit_volume),0))/1728 AS total_cubes
	SUM(ISNULL(quantity_shipped,0))  AS total_piece
	,SUM((ISNULL(quantity_shipped,0)) * ISNULL(d.nested_volume,d.unit_volume)) AS total_cubes
	,SUM(ISNULL(quantity_shipped,0)-ISNULL(quantity_received,0)) as open_piece --V7.1
INTO #total_asn_quantity
FROM dbo.t_asn a WITH (NOLOCK)
INNER JOIN #SEFU_Temp b ON a.equipment_id = b.equipment_id
INNER JOIN dbo.t_asn_detail c WITH (NOLOCK) ON a.asn_id = c.asn_id
INNER JOIN dbo.t_item_master d WITH (NOLOCK) ON c.item_number = d.item_number
WHERE a.status = 'CHECKED IN'
GROUP BY a.equipment_id,c.item_number

--Find the items that are partially eligible by creteria
SELECT DISTINCT d.item_number,f.wh_id 
INTO #temp_partial_elig_item
FROM dbo.t_asn a (NOLOCK)
INNER JOIN #SEFU_Temp b ON a.equipment_id = b.equipment_id AND a.area_id = b.area_id
INNER JOIN dbo.t_area_wh_id c WITH (NOLOCK) ON c.area_id = a.area_id
INNER JOIN dbo.t_asn_detail d WITH (NOLOCK) ON a.asn_id = d.asn_id 
INNER JOIN dbo.t_item_master e WITH (NOLOCK) ON d.item_number = e.item_number AND c.wh_id = e.wh_id
INNER JOIN dbo.t_item_uom f WITH (NOLOCK) ON f.item_number = e.item_number AND e.wh_id = f.wh_id
INNER JOIN dbo.t_pallet g WITH (NOLOCK) ON g.pallet_id = f.pallet_id
WHERE f.uom = 'SCOOP'
AND e.inventory_type = 'FG'
AND g.pallet IN ('5 X 5','5 X 6','5 X 7')
AND e.unit_weight <= 260
AND a.status = 'CHECKED IN'

--Find the First Highest Item Dim
SELECT a.item_number,a.wh_id
	,CASE WHEN a.length >= a.width	AND a.length >= a.height THEN a.length
		WHEN a.width >= a.length AND a.width >= a.height THEN a.width
		WHEN a.height >= a.length AND a.height >= a.width THEN a.height
		END AS first_highest_dim_val
	,CASE WHEN a.length >= a.width AND a.length >= a.height THEN 'Y' ELSE 'N' END AS is_length_highest_dim
	,CASE WHEN a.width >= a.length AND a.width >= a.height  THEN 'Y' ELSE 'N' END AS is_width_highest_dim
	,CASE WHEN a.height >= a.length AND a.height >= a.width	THEN 'Y' ELSE 'N' END AS is_height_highest_dim
INTO #tmp_first_highest
FROM dbo.t_item_master a WITH(NOLOCK)
INNER JOIN #temp_partial_elig_item b 
ON b.item_number = a.item_number AND b.wh_id = a.wh_id

--Find the Second Highest 
SELECT tmpfh.item_number,
itm.wh_id,
itm.length,
itm.width,
itm.height,
CASE WHEN is_length_highest_dim='Y' THEN 'Length'
	WHEN is_width_highest_dim='Y' THEN 'Width'
	WHEN is_height_highest_dim='Y' THEN 'Height'
	END AS first_highest,
CASE 
	WHEN ((is_length_highest_dim  = 'Y' AND width>=height) OR (is_height_highest_dim  = 'Y' AND width>length)) THEN 'Width'
	WHEN ((is_length_highest_dim  = 'Y' AND height>width) OR (is_width_highest_dim  = 'Y' AND height>length)) THEN 'Height'
	WHEN ((is_width_highest_dim  = 'Y' AND length>=height) OR (is_height_highest_dim  = 'Y' AND length>=width)) THEN 'Length' 
	END as second_highest,
tmpfh.first_highest_dim_val, 
CASE 
	WHEN ((is_length_highest_dim = 'Y' AND width>=height)  OR (is_height_highest_dim = 'Y' AND width>length)) THEN width
	WHEN ((is_length_highest_dim = 'Y' AND height>=width)  OR (is_width_highest_dim  = 'Y' AND height>length)) THEN height
	WHEN ((is_width_highest_dim  = 'Y' AND length>=height) OR (is_height_highest_dim = 'Y' AND length>=width)) THEN length
	END AS second_highest_dim_val
INTO #tmp_dims
FROM dbo.t_item_master itm WITH(NOLOCK)
INNER JOIN #tmp_first_highest tmpfh ON tmpfh.item_number = itm.item_number 

SELECT item_number,wh_id,
length,width,height,first_highest,second_highest,first_highest_dim_val,second_highest_dim_val,
CASE WHEN ((first_highest = 'Width' )  AND  (second_highest = 'Length' )) OR 
		  ((first_highest = 'Length' )  AND  (second_highest = 'Width' )) THEN height
	 WHEN ((first_highest = 'Length' )  AND  (second_highest = 'Height' )) OR 
		  ((first_highest = 'Height' )  AND  (second_highest = 'Length' )) THEN width
	 WHEN ((first_highest = 'Width' )  AND  (second_highest = 'Height' )) OR 
		  ((first_highest = 'Height' )  AND  (second_highest = 'Width' )) THEN length
	 END AS third_highest_dim_val
INTO #temp_final_dims
FROM #tmp_dims 




SELECT asn.equipment_id,asd.item_number,
SUM(CASE WHEN snm.po_number <> pom.po_number THEN 1 ELSE 0 END) AS duplicate_count,
SUM(CASE WHEN snm.po_number = pom.po_number THEN 1 ELSE 0 END ) AS received_count,
SUM(CASE WHEN snm.po_number <> pom.po_number THEN ISNULL(itm.nested_volume,itm.unit_volume) ELSE 0 END) AS duplicate_cube,
SUM(CASE WHEN snm.po_number = pom.po_number THEN ISNULL(itm.nested_volume,itm.unit_volume) ELSE 0 END ) AS received_cube
INTO #tmp_duplicate_serials
FROM dbo.t_asn asn WITH(NOLOCK)
INNER JOIN #total_asn_quantity totalasn ON totalasn.equipment_id = asn.equipment_id
INNER JOIN dbo.t_asn_detail asd WITH(NOLOCK) ON asn.asn_id = asd.asn_id AND asd.item_number = totalasn.item_number
INNER JOIN dbo.t_item_master itm WITH(NOLOCK) ON itm.item_number = asd.item_number 
INNER JOIN dbo.t_po_master pom  WITH (NOLOCK) ON pom.po_number = asd.customer_po_number
INNER JOIN dbo.t_serial_master snm  WITH (NOLOCK) ON (snm.serial_number BETWEEN asd.serial_number_start AND asd.serial_number_end)
WHERE asn.equipment_id IN (SELECT DISTINCT equipment_id FROM #SEFU_Temp)
AND asn.status = 'CHECKED IN'
AND (
              (snm.serial_number IS NOT NULL AND pom.type_id = 20) OR
              (snm.serial_number IS NOT NULL AND pom.type_id = 21 AND snm.wh_id <> 'INT')
       )
GROUP BY asn.equipment_id,asd.item_number

UPDATE total SET total.total_piece=total.total_piece-dup.received_count , total.total_cubes = total.total_cubes -dup.received_cube
FROM #total_asn_quantity total 
INNER JOIN #tmp_duplicate_serials dup
ON dup.equipment_id = total.equipment_id
AND dup.item_number = total.item_number

--select '#tmp_duplicate_serials',* from #tmp_duplicate_serials
/*V7.1 build table to exclude all received or exist duplicated serial items*/
SELECT total.equipment_id,total.item_number
INTO #total_open_item 
FROM #total_asn_quantity total
LEFT JOIN #tmp_duplicate_serials dup
ON dup.equipment_id = total.equipment_id
		AND dup.item_number = total.item_number  
WHERE total.open_piece > 0 and ISNULL(dup.duplicate_count,0)=0
/*V7.1 End*/

--select '#total_asn_quantity',* from #total_asn_quantity
--select '#total_open_item',* from #total_open_item



	SELECT s.equipment_id
,(SUM(ISNULL(total_piece,0)-ISNULL(f.duplicate_count,0)))  AS eligible_piece
,(SUM(ISNULL(total_cubes,0)-ISNULL(f.duplicate_cube,0))) AS eligible_cubes
,COUNT(o.item_number) as item_qty--V7.0 WW-465 MVP for Automation candidates logic
INTO #total_eligible_quantity
FROM dbo.t_asn s WITH (NOLOCK)
INNER JOIN #total_asn_quantity e ON s.equipment_id = e.equipment_id
INNER JOIN dbo.t_item_master b WITH (NOLOCK) ON e.item_number = b.item_number
INNER JOIN dbo.t_item_uom  c WITH (NOLOCK) ON b.item_number = c.item_number AND c.wh_id = b.wh_id
AND c.uom = 'SCOOP'  AND b.unit_weight <= 260
INNER JOIN #temp_final_dims d ON c.item_number = d.item_number AND c.wh_id = d.wh_id
LEFT JOIN t_rr_item_exclusion rie (NOLOCK)  ON rie.item_number=b.item_number  
LEFT JOIN #tmp_duplicate_serials f ON f.equipment_id = e.equipment_id AND f.item_number = e.item_number
LEFT JOIN #total_open_item o (NOLOCK) ON o.equipment_id = e.equipment_id AND o.item_number = e.item_number--V7.1
WHERE d.first_highest_dim_val BETWEEN  11 AND 84
	AND d.second_highest_dim_val BETWEEN  4 AND 60
	AND d.third_highest_dim_val >= 3
	AND rie.item_number is null
	AND s.status = 'CHECKED IN'
	GROUP BY s.equipment_id
	HAVING (SUM(ISNULL(total_piece,0)-ISNULL(f.duplicate_count,0))) > 0

--select '#total_eligible_quantity',* from #total_eligible_quantity
	
SELECT CAST((b.eligible_cubes / NULLIF(a.total_cubes, 0)) * 100 AS DECIMAL(16, 2)) AS 'Automation Cube'
	,CAST((b.eligible_piece / NULLIF(a.total_piece, 0)) * 100 AS DECIMAL(16, 2)) AS 'Automation Pieces'
	,b.item_qty AS 'item_qty' --V7.0 WW-465 MVP for Automation candidates logic
		,ROUND(b.eligible_cubes,0) AS 'Remaining Cube'
	,b.eligible_piece AS 'Remaining Pieces'
	,t.unload_priority AS 'priority'
	,t.equipment_id AS 'equipment_id'
	,t.location_name AS 'location'
	,CASE WHEN yoc.type = 'DOOR' THEN NULL ELSE t.Disposition_Unit END AS 'schedule_to_door'
	,t.area_id AS 'area_id'	
INTO #AllQualified
FROM #SEFU_Temp t
INNER JOIN (SELECT equipment_id,SUM(total_piece) as total_piece,SUM(total_cubes) as total_cubes
			FROM #total_asn_quantity  GROUP BY equipment_id) a
			ON t.equipment_id = a.equipment_id
INNER JOIN #total_eligible_quantity b ON t.equipment_id = b.equipment_id
	AND b.equipment_id = a.equipment_id
left join #t_ya_location yoc on  yoc.location_name=t.location_name
WHERE CAST((b.eligible_piece / NULLIF(a.total_piece, 0)) * 100 AS DECIMAL(16, 2)) > 0
	AND CAST((b.eligible_cubes / NULLIF(a.total_cubes, 0)) * 100 AS DECIMAL(16, 2)) > 0
ORDER BY CAST((b.eligible_cubes / NULLIF(a.total_cubes, 0)) * 100 AS DECIMAL(16, 2)) desc ,t.unload_priority desc

---2023/08/30 Grace add
IF @in_vch_seltable ='1'
  BEGIN
/*V7.0 WW-465 MVP for Automation candidates logic Start*/
	IF OBJECT_ID('tempdb..#rrcube') IS NOT NULL 
		BEGIN
			INSERT INTO #rrcube
											( 
											cube,
											pieces,
											item_qty,
											remaining_cube,
											remaining_pieces,
											priority,
											trailer_number,
											location,
											schedule_to_door,
											area_id		
											) 
			 SELECT [Automation Cube],[Automation Pieces],[item_qty],[Remaining Cube],[Remaining Pieces],[priority],[equipment_id],[location],[schedule_to_door],[area_id] FROM #AllQualified   
			 GOTO ExistLable
		 END
	ELSE
/*V7.0 WW-465 MVP for Automation candidates logic End*/
/*Start of V6.1 */
	  IF OBJECT_ID('tempdb..#dch_count_rr_contailers') IS NOT NULL 
		  INSERT INTO #dch_count_rr_contailers
										( 
										cube,  
										piece,  
										remaining_cube,  
										remaining_pieces,  
										priority,
										trailer_number,  
										location,  
										schedule_to_door,  
										area_id 
										) 
		 SELECT [Automation Cube],[Automation Pieces],[Remaining Cube],[Remaining Pieces],[priority],[equipment_id],[location],[schedule_to_door],[area_id] FROM #AllQualified   
	 ELSE 
 /*End of V6.1 */ 
		SELECT [Automation Cube],[Automation Pieces],[Remaining Cube],[Remaining Pieces],[priority],[equipment_id],[location],[schedule_to_door],[area_id] FROM #AllQualified
	GOTO ExistLable
  END
--end

DECLARE @CubeCompliant INT 
SET @CubeCompliant  = 0
IF NOT EXISTS (SELECT 1 FROM dbo.t_control WITH(NOLOCK) WHERE control_type = 'RR_SEFU_THRESHLD')
BEGIN
	INSERT INTO t_control VALUES ('RR_SEFU_THRESHLD','Recv Robotics SEFU Threshold',30,'SHOW_VA',1,'',NULL,0)
END

SELECT @CubeCompliant =next_value
FROM dbo.t_control (NOLOCK) WHERE 
control_type = 'RR_SEFU_THRESHLD'

     
/*V7.0 WW-465 MVP for Automation candidates logic START*/
IF OBJECT_ID('tempdb..#sefumatch') IS NOT NULL          
BEGIN        
INSERT INTO #sefumatch(            
  highlight,              
  unload_priority,            
  Cube,              
  Piece,    
  item_qty,          
  load_id,              
  dispatch_date,              
  first_drop_state,              
  sefu.equipment_id,              
  carrier_name,              
  Itnbr,              
  status,              
  location_name,              
  Suggested_Disposition,              
  Disposition_Unit,   
  Disposition,              
  zone,              
  priority,              
  scheduled_by,           
    asn_number,              
  Arrival,              
  Expected_Arrival,              
  Percent_complete,              
  Review_Inventory,              
  trailer_id,              
  area_id,              
  work_q_id,              
  Null_Sort,              
  Demand,              
  Sort,              
  backorder_cube)            
SELECT DISTiNCT              
highlight ,              
unload_priority ,              
automation.[Automation Cube] as'Cube%',              
automation.[Automation Pieces] as'Piece%',
automation.item_qty,           
load_id ,              
dispatch_date ,              
first_drop_state ,              
sefu.equipment_id ,              
carrier_name ,             
Itnbr ,              
status ,              
location_name ,              
Suggested_Disposition,             
Disposition_Unit ,              
Disposition ,              
zone ,              
sefu.priority ,              
scheduled_by ,           
asn_number ,              
Arrival ,              
Expected_Arrival ,               
Percent_complete ,              
 Review_Inventory ,              
trailer_id ,              
sefu.area_id ,              
work_q_id ,              
Null_Sort ,              
Demand ,              
Sort ,              
backorder_cube              
FROM #SEFU_Temp sefu LEFT JOIN #AllQualified automation              
ON sefu.equipment_id = automation.equipment_id              
AND automation.[Automation Cube] >=@CubeCompliant                 
END 
ELSE
/*V7.0 WW-465 MVP for Automation candidates logic End*/
----V6 STARTS------------------------ 
BEGIN
IF OBJECT_ID('tempdb..#SEFU') IS NOT NULL          
BEGIN        
INSERT INTO #SEFU (            
  highlight,              
  unload_priority,            
  Cube,              
  Piece,              
  load_id,              
  dispatch_date,              
  first_drop_state,              
  sefu.equipment_id,              
  carrier_name,              
  Itnbr,              
  status,              
  location_name,              
  Suggested_Disposition,              
  Disposition_Unit,   
  Disposition,              
  zone,              
  priority,              
  scheduled_by,           
    asn_number,              
  Arrival,              
  Expected_Arrival,              
  Percent_complete,              
  Review_Inventory,              
  trailer_id,              
  area_id,              
  work_q_id,              
  Null_Sort,              
  Demand,              
  Sort,              
  backorder_cube)            
SELECT DISTiNCT              
highlight ,              
unload_priority ,              
automation.[Automation Cube] as'Cube%',              
automation.[Automation Pieces] as'Piece%',              
load_id ,              
dispatch_date ,              
first_drop_state ,              
sefu.equipment_id ,              
carrier_name ,              
Itnbr ,              
status ,              
location_name ,              
Suggested_Disposition,--v2              
Disposition_Unit ,              
Disposition ,              
zone ,              
sefu.priority ,              
scheduled_by ,           
asn_number ,              
Arrival ,              
Expected_Arrival ,               
Percent_complete ,              
 Review_Inventory ,              
trailer_id ,              
sefu.area_id ,              
work_q_id ,              
Null_Sort ,              
Demand ,              
Sort ,              
backorder_cube              
FROM #SEFU_Temp sefu LEFT JOIN #AllQualified automation              
ON sefu.equipment_id = automation.equipment_id              
AND automation.[Automation Cube] >=@CubeCompliant                 
END                  
ELSE                  
BEGIN              
SELECT DISTiNCT              
highlight ,              
unload_priority ,              
automation.[Automation Cube] as'Cube%',              
automation.[Automation Pieces] as'Piece%',              
load_id ,              
dispatch_date ,              
first_drop_state ,              
sefu.equipment_id ,              
carrier_name ,              
Itnbr ,              
status ,              
location_name ,              
Suggested_Disposition,--v2              
Disposition_Unit ,              
Disposition ,              
zone ,              
sefu.priority ,              
scheduled_by ,              
asn_number ,              
Arrival ,              
Expected_Arrival ,               
Percent_complete ,              
 Review_Inventory ,              
trailer_id ,              
sefu.area_id ,              
work_q_id ,      
Null_Sort ,              
Demand ,              
Sort ,              
backorder_cube              
FROM #SEFU_Temp sefu LEFT JOIN #AllQualified automation              
ON sefu.equipment_id = automation.equipment_id              
AND automation.[Automation Cube] >=@CubeCompliant              
ORDER  BY unload_priority,              
          Null_Sort,              
          dispatch_date,              
          Demand DESC,              
          Sort DESC,              
       Arrival,              
          Itnbr,              
          load_id              
END
END
----V6 ENDS------------------------    
    

ExistLable:

IF Object_id ('tempdb..#_asn_detail') IS NOT NULL
  BEGIN
        DROP TABLE #_asn_detail
  END
--DROP TABLE #DemandTable	
IF Object_id ('tempdb..#DemandTable') IS NOT NULL
  BEGIN
        DROP TABLE #DemandTable
  END
--DROP TABLE #_demand_equip_unload
IF Object_id ('tempdb..#_demand_equip_unload') IS NOT NULL
  BEGIN
        DROP TABLE #_demand_equip_unload
  END
IF Object_id ('tempdb..#_inventory_position') IS NOT NULL
 BEGIN
        DROP TABLE #_inventory_position 
  END
    --V7.1
  IF Object_id ('tempdb..#total_open_item') IS NOT NULL
 BEGIN
        DROP TABLE #total_open_item
  END
  --
SET QUOTED_IDENTIFIER OFF

SET NOCOUNT OFF

END
