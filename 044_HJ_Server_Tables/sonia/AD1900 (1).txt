
CREATE     PROCEDURE [dbo].[usp_diagnose_replenishment]
	@in_vchWhID			VARCHAR(10),
	@in_vchItem         VARCHAR(30),
	@in_vchLocation		VARCHAR(50),
	@in_vchRuleName		VARCHAR(50),		-- If not null, only the rule specified will be run in diagnostic mode.  If null, all rules will be run in normal mode and the results reported for all rules.
	@in_vchCondition	VARCHAR(10) = 'ALL',
	@in_vchDescription  VARCHAR(100)

AS
/********************************************************************************
 *    Company			: Ashley Furniture Industries								
 *    System   			: HighJump  		 
 *    Module			: Replenishment
 *    Procedure			: usp_diagnose_replenishment
 *    Author			: Leo Schmidt
 *    Date				: 02-Nov-2011
 *	  Version			: 1.0					
 *    Description		: Diagnose replenishment generation rules.
 *    Modification Log  : Date 		Modified By 	Task ID		Description
 *						02-Nov-2011	Leo Schmidt		PV2191-1292	Created for diagnosing the replenishment rules.
 *						 22-Feb-2018  Ajeeth            FIFO to pick 'oldest' not just old    
 *						2022/06/20  Grace Liu		820358 PM A demand include transfer open qty                
 *                      2025/01/09  Sairam			1247628- Performance Improvement to SP - usp_generate_replenishment - Research/Design    --V6.0                    
 ********************************************************************************/
BEGIN
DECLARE @v_vchErrorMsg        VARCHAR(200),
        @v_nErrorNumber       INT,
        @v_nLogLevel          TINYINT,
        @v_nLogErrorNum       INT,
        @c_vchObjName         VARCHAR(30),
        @v_vchRule            VARCHAR(100),
		@v_dtStartTime		  DATETIME,
		@v_nElapsedSecs		  FLOAT,

        @v_nRowCount          INT,

        @v_nNumOfItems        SMALLINT,
        @v_nNumOfRules        SMALLINT,
        @v_nRuleCntr          SMALLINT,
        
        @v_nReturn            INT,
        
        @e_nGenSqlError       INT,
        @e_nSprocError        INT,
		@v_vchState			  CHAR(3),
		@v_execution_time	  DATETIME = GETDATE(),
		@v_execiton_end_time  DATETIME = GETDATE()
		--@v_debug			  INT  =1

-- Set constant values.
SET @c_vchObjName = 'usp_diagnose_replenishment'

SET @e_nGenSqlError = 1
SET @e_nSprocError = 2
 
 -- Grab the database object log level.
EXECUTE @v_nReturn = usp_db_obj_log_level @v_nLogLevel OUTPUT
IF @v_nReturn <> 0 -- A zero means success.
BEGIN
    SET @v_vchErrorMsg = 'An error occurred in a stored procedure with a return code of ' +
    	ISNULL(CONVERT(VARCHAR(30),@v_nReturn),'(NULL)') + '.'
    SET @v_nLogErrorNum = @e_nSprocError
    GOTO ErrorHandler			
END

SET @v_nLogLevel=3
IF(@v_nLogLevel>2)
BEGIN
print 'EXECUTION Started'+ CAST(@v_execution_time as VARCHAR(50))
END

CREATE TABLE #tmp_rule_set
(
   sequence				INT IDENTITY(1,1),
   rule_id				INT,
   description			VARCHAR(100),
   sproc_name			VARCHAR(100),
   result				VARCHAR(30),     --2022/06/20  Grace change from 6 to 30
   location_id			VARCHAR(50),
   replen_quantity		FLOAT,
   priority				VARCHAR(3),
   execution_seconds	FLOAT,
   insert_count			INT,
   update_count			INT,
   delete_count			INT
) 

--BEGIN V6.0

IF OBJECT_ID(N'tempdb..#t_fwd_priority_sub') IS NOT NULL
DROP TABLE #t_fwd_priority_sub

IF OBJECT_ID(N'tempdb..#t_location_sub') IS NOT NULL
DROP TABLE #t_location_sub

IF OBJECT_ID(N'tempdb..#tmp_item_master_sub') IS NOT NULL
DROP TABLE #tmp_item_master_sub

IF OBJECT_ID(N'tempdb..#tmp_candidate_replen_qty_loc_sub') IS NOT NULL
DROP TABLE #tmp_candidate_replen_qty_loc_sub

IF OBJECT_ID(N'tempdb..#t_temp_sto_sub') IS NOT NULL
DROP TABLE #t_temp_sto_sub

IF OBJECT_ID(N'tempdb..#t_temp_sto1_sub') IS NOT NULL
DROP TABLE #t_temp_sto1_sub

IF OBJECT_ID(N'tempdb..#tmp_candidate_priority') IS NOT NULL
DROP TABLE #tmp_candidate_priority

IF OBJECT_ID(N'tempdb..#t_work_q_sub') IS NOT NULL  
DROP TABLE #t_work_q_sub  

IF OBJECT_ID(N'tempdb..#tmp_work_q') IS NOT NULL  
DROP TABLE #tmp_work_q  



IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'Drop Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) as VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END
--END V6.0

SET NOCOUNT ON

SELECT  wh_id,location_id,status,zone,type,building INTO #t_location_sub FROM  dbo.t_location (NOLOCK)  

IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'Create #t_location_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) as VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END

-- Create a temporary table of all parameters passed into this procedure.
SELECT  @in_vchWhID AS param_wh_id,
		@in_vchItem AS param_item_number,
		@in_vchLocation	AS param_location,
		@in_vchRuleName AS param_rule_name,
		@in_vchCondition AS param_condition,
		@in_vchDescription AS param_description
	INTO #tmp_param

IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'Create #tmp_param Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) as VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END
-- Fill the temporary table with rules to execute for the item.
INSERT INTO #tmp_rule_set (rule_id, description, sproc_name)
	SELECT DISTINCT [replenishment_rule_id]
		, [description]
		, [sproc_name]
      FROM t_replenishment_rule

-- Get and Set ErrorHandler Variables
SELECT @v_nErrorNumber = @@ERROR, @v_nNumOfRules = @@ROWCOUNT 
-- Check for any errors. If so, error number will not be equal to zero.

IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'Insert #tmp_rule_set Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) as VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END

IF @v_nErrorNumber <> 0
BEGIN
   SET @v_vchErrorMsg = 'SQL Server System error occured!  Check SQL Server System Log for the exact nature of the error.'
   SET @v_nLogErrorNum = @e_nGenSqlError
   GOTO ErrorHandler
END

IF @v_nNumOfRules = 0
BEGIN
	SELECT @c_vchObjName + ': No Replenishment Rules were found. Check the t_replenishment_rule table.' AS result
	GOTO ExitLabel
END 

IF (@v_nLogLevel >= 4)
 BEGIN
   PRINT @c_vchObjName + ': Here are the replenishment rules:'
   SELECT * FROM #tmp_rule_set
 END

-- Prepare the FIFO Lock tables for use by the rules.  In this case, however, the rules must populate.
SELECT carb.wh_id
	, carb.item_number
	, carb.ship_to_state
	, carb.fifo_lock AS fifo_lock
	, carb.carb_rotation_sequence AS oldest_carb
	, carb.fifo_window_date AS oldest_fifo_date
  INTO #tmp_item_fifo
  FROM [dbo].[udf_carb_fifo_shipment_priority]( @in_vchWhID, @in_vchItem, @v_vchState ) carb
  WHERE 1=2

SELECT carb.wh_id
	, carb.item_number
	, carb.ship_to_state
	, carb.location_id
	, carb.fifo_lock AS loc_fifo_lock
	, carb.carb_rotation_sequence AS loc_oldest_carb
	, carb.fifo_window_date AS loc_oldest_fifo_date
  INTO #tmp_item_location_age
  FROM dbo.udf_carb_fifo_location_age_pick( @in_vchWhID, @in_vchItem, NULL, @v_vchState ) carb
  WHERE 1=2

  
--BEGIN V6.0 



CREATE TABLE #tmp_work_q (
   seq						INT IDENTITY(1,1) NOT NULL,
   location_id				VARCHAR(50)       NOT NULL,
   item_number				VARCHAR(30)		 NOT NULL,
   wh_id					VARCHAR(10)		  NOT NULL,
   replenishment_quantity	FLOAT			  NOT NULL,
   priority					VARCHAR(10)		  NULL,
   hu_id					VARCHAR(22)		  NULL,
   work_q_id				VARCHAR(30)		  NULL
)

IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #tmp_work_q,#tmp_item_location_age,#tmp_item_fifo Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END


SELECT  * INTO  #t_fwd_priority_sub FROM dbo.t_fwd_priority (NOLOCK) 

IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #t_fwd_priority_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END


   SELECT 
	   i.item_number
	 , i.wh_id
	 , i.replen_level
	 , i.overflow_pick_building
	 , i.recv_equipment_class_id
	 ,i.commodity_code
	INTO #tmp_item_master_sub
	FROM dbo.t_item_master i (NOLOCK)
    WHERE i.item_number = @in_vchItem
	  AND i.wh_id = @in_vchWhID
	  AND i.commodity_code NOT IN('LA','TA')

	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #tmp_item_master_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END


IF @in_vchItem IS NULL  
BEGIN  
 CREATE NONCLUSTERED INDEX [tmp_item_master_sub]  
 ON [dbo].[#tmp_item_master_sub] ([item_number],[wh_id])  
 INCLUDE ([recv_equipment_class_id])  

 	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE INDEX [tmp_item_master_sub] Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END

END  
  
  	SELECT 
	   * INTO #tmp_candidate_replen_qty_loc_sub
  FROM #t_location_sub l (NOLOCK)
  WHERE l.type = 'P'
    AND l.location_id = ISNULL(@in_vchLocation,l.location_id)
	AND l.wh_id = ISNULL(@in_vchWhID,l.wh_id)

	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #tmp_candidate_replen_qty_loc_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END
	
  
SELECT   
 sto.item_number  
 , sto.wh_id  
 , sto.location_id  
 ,loc.building  
 , SUM(sto.actual_qty) AS actual_qty  
 INTO #t_temp_sto_sub  
FROM dbo.t_stored_item sto (NOLOCK)  
INNER JOIN #t_location_sub loc (NOLOCK)  
ON loc.location_id = sto.location_id  
AND loc.wh_id = sto.wh_id  
INNER JOIN dbo.t_building bld (NOLOCK)  
ON bld.building = loc.building  
WHERE loc.type IN ('I','M','P')  
AND sto.type = 'STORAGE'  
AND bld.offsite_flag = 'N'  
GROUP BY sto.item_number, sto.wh_id, sto.location_id,loc.building  

	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #t_temp_sto_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END
  
SELECT   
 sto.item_number  
 , sto.wh_id  
 , sto.location_id  
 ,loc.building  
 , SUM(sto.actual_qty) AS actual_qty  
 INTO #t_temp_sto1_sub  
FROM dbo.t_stored_item sto (NOLOCK)  
INNER JOIN #t_location_sub loc (NOLOCK)  
ON loc.location_id = sto.location_id  
AND loc.wh_id = sto.wh_id  
INNER JOIN dbo.t_building bld (NOLOCK)  
ON bld.building = loc.building  
WHERE loc.type IN ('IG', 'F', 'SL')  
AND sto.status <> 'U'  
AND sto.type = 'STORAGE'  
AND bld.offsite_flag = 'N'  
GROUP BY sto.item_number, sto.wh_id, sto.location_id,loc.building  



	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #t_temp_sto1_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END


SELECT *
  INTO #tmp_candidate_priority
  FROM (
	SELECT 'More than '+LTRIM(STR(MAX(percentage)))+'% Full' AS percent_full_range
		 , NULL AS percent_full
		 , Cast('No' AS VARCHAR(3))          AS net_a_demand_deficiency
         , Cast('No' AS VARCHAR(3))          AS net_b_demand_deficiency
		 , Cast('No' AS VARCHAR(3))          AS net_transfer_deficiency
		 ,CASt('Replen To Fwp Capacity Quantity' as VARCHAR(50))  AS replen_quantity_column
		 , '50' AS priority
		 ,CAST('More than '+LTRIM(STR(MAX(percentage)))+'% Full'  as VARCHAR(50)) AS priority_condition
		 , CAST(NULL AS VARCHAR(3)) AS equipment_class_allows_over_replen
		 , CAST('No' AS VARCHAR(3)) AS net_transfer_each_bill_deficiency
		 , 1 as selection_row
	  FROM #t_fwd_priority_sub (NOLOCK)
	UNION
	SELECT 'Up to '+LTRIM(STR(percentage))+'% Full' AS percent_full_range
		 , CAST(percentage AS FLOAT) AS percent_full
		 , Cast('No' AS VARCHAR(3))          AS net_a_demand_deficiency
         , Cast('No' AS VARCHAR(3))          AS net_b_demand_deficiency
		 , Cast('No' AS VARCHAR(3))          AS net_transfer_deficiency
		 ,CAST('Replen To Fwp Capacity Quantity' as VARCHAR(50))  AS replen_quantity_column
		 , priority
		 ,CAST('Up to '+LTRIM(STR(percentage))+'% Full'  as VARCHAR(50)) AS priority_condition
		 , CAST(NULL AS VARCHAR(3)) AS equipment_class_allows_over_replen
		 , CAST('No' AS VARCHAR(3)) AS net_transfer_each_bill_deficiency 
		 , 2 as selection_row
	  FROM #t_fwd_priority_sub (NOLOCK)
	UNION
	SELECT 'Empty' AS percent_full_range
		 , 0 AS percent_full
		 , Cast('No' AS VARCHAR(3))          AS net_a_demand_deficiency
         , Cast('No' AS VARCHAR(3))          AS net_b_demand_deficiency
		 , Cast('No' AS VARCHAR(3))          AS net_transfer_deficiency
		 ,CAST('Replen To Fwp Capacity Quantity' as VARCHAR(50))  AS replen_quantity_column
		 , '90' AS priority
		 ,CAST('Empty'  as VARCHAR(50)) AS priority_condition
		 , CAST(NULL AS VARCHAR(3)) AS equipment_class_allows_over_replen  
		 , CAST('No' AS VARCHAR(3)) AS net_transfer_each_bill_deficiency
		 , 3 as selection_row
	  WHERE NOT EXISTS (SELECT 1 FROM #t_fwd_priority_sub (NOLOCK) WHERE priority = '90')
	 UNION
        SELECT 'Net B Demand Deficiency'         AS percent_full_range,
               NULL                              AS percent_full,
               Cast('No' AS VARCHAR(3))          AS net_a_demand_deficiency,			   
               Cast('Yes' AS VARCHAR(3))         AS net_b_demand_deficiency,	
			   Cast('No' AS VARCHAR(3))          AS net_transfer_deficiency,		   
			   CAST('Replen To B Demand Quantity' as VARCHAR(50)) AS replen_quantity_column,
               '92'                              AS priority,
			   CAST('Net B Demand Deficiency'  as VARCHAR(50)) AS priority_condition,
			   CAST(NULL AS VARCHAR(3)) AS equipment_class_allows_over_replen,
			   CAST('No' AS VARCHAR(3)) AS net_transfer_each_bill_deficiency,
			   4 as selection_row
        WHERE  NOT EXISTS (SELECT 1 FROM   #t_fwd_priority_sub (NOLOCK) WHERE  priority = '92')
        UNION
        SELECT 'Net A Demand Deficiency'     AS percent_full_range,
               NULL                          AS percent_full,
               Cast('Yes' AS VARCHAR(3))     AS net_a_demand_deficiency,			  
               Cast('No' AS VARCHAR(3))      AS net_b_demand_deficiency,
			   Cast('No' AS VARCHAR(3))      AS net_transfer_deficiency,
			   CAST('Replen To A Demand Quantity' as VARCHAR(50)) AS replen_quantity_column,
               '93'                          AS priority,
			   CAST('Net A Demand Deficiency'  as VARCHAR(50)) AS priority_condition,
			    CAST(NULL AS VARCHAR(3)) AS equipment_class_allows_over_replen, 
				CAST('Yes' AS VARCHAR(3)) AS net_transfer_each_bill_deficiency, 
				5 as selection_row
        WHERE  NOT EXISTS (SELECT 1 FROM   #t_fwd_priority_sub (NOLOCK) WHERE  priority = '93')

	) fp
  ORDER BY priority

  	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #tmp_candidate_priority Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END

  SELECT  work_q_id,priority,pick_ref_number,work_status,wh_id,work_type INTO #t_work_q_sub     
FROM dbo.t_work_q wkq (NOLOCK) WHERE work_status <>'C'  AND pick_ref_number in ( 'INTERBUILDING','REPLENISH','LTCREPLENISH') AND work_type = '07'  

 	  IF(@v_nLogLevel>2)
BEGIN
 SET @v_execiton_end_time=GETDATE()
 PRINT 'CREATE #t_work_q_sub Table Execution Completed in '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
 SET @v_execution_time =GETDATE()
END

   --END V6.0

SET @v_nRuleCntr = 1  -- Set the rule counter = 1.

-- Cycle through the sequence of rules.
WHILE @v_nNumOfRules >= @v_nRuleCntr
BEGIN

	IF OBJECT_ID(N'tempdb..#tmp_work_q') IS NOT NULL  
	TRUNCATE TABLE #tmp_work_q 
	-- Find the rule.
	SELECT @v_vchRule = sproc_name
	FROM #tmp_rule_set
	WHERE sequence = @v_nRuleCntr

	select @v_nLogLevel

		IF(@v_nLogLevel>2)
		BEGIN
		 SET @v_execiton_end_time=GETDATE()
		 PRINT 'execution started for rule:'+@v_vchRule
		 SET @v_execution_time =GETDATE()
		END

	IF (@v_nLogLevel >= 4)
	PRINT @c_vchObjName + ': About to execute rule #' + CONVERT(CHAR(2),@v_nRuleCntr) + ', rule: ' + @v_vchRule

	


	IF (@in_vchRuleName IS NULL)
	BEGIN
		SET @v_dtStartTime = GETDATE()
		EXEC @v_vchRule @in_vchWhID, @in_vchItem, @in_vchLocation, 'QUIET'  -- Execute the rule!
		SET @v_nElapsedSecs = DATEDIFF( ms, @v_dtStartTime, GETDATE())/1000.0
	END
	ELSE
	BEGIN
	  IF (@in_vchRuleName = @v_vchRule)
		  EXEC @v_vchRule @in_vchWhID, @in_vchItem, @in_vchLocation, @in_vchCondition  -- Execute the rule!
	END

	-- Get and Set ErrorHandler Variables
	SELECT @v_nErrorNumber = @@ERROR, @v_nRowCount = @@ROWCOUNT 
	-- Check for any errors. If so, error number will not be equal to zero.
	IF(@v_nLogLevel>2)
		BEGIN
		 SET @v_execiton_end_time=GETDATE()
		 PRINT 'execution completed for rule '+@v_vchRule+' '+CAST(DATEDIFF(Millisecond,@v_execution_time,@v_execiton_end_time) AS VARCHAR(50))+' Millisecond'
		 SET @v_execution_time =GETDATE()
		END

	IF @v_nErrorNumber <> 0
	BEGIN
	  SET @v_vchErrorMsg = 'Called stored procedure: ' + @v_vchRule + ' Failed!  Check SQL Server System Log for the exact nature of the error.'
	  SET @v_nLogErrorNum = @e_nSprocError
	  GOTO ErrorHandler
	END

	IF (@in_vchRuleName IS NULL)
	  UPDATE #tmp_rule_set
		  SET execution_seconds = @v_nElapsedSecs
		  WHERE sequence = @v_nRuleCntr    

	-- Increment the counter if a location was not found.
	SET @v_nRuleCntr = @v_nRuleCntr + 1
END

IF (@in_vchRuleName IS NULL)
BEGIN
	IF @in_vchItem IS NULL
	BEGIN
		SELECT sequence
			 , rule_id
			 , sproc_name
			 , description
			 , execution_seconds
			 , insert_count
			 , update_count
			 , delete_count
		  FROM #tmp_rule_set
		  ORDER BY sequence
	END
	ELSE
	BEGIN
		SELECT @in_vchWhID AS wh_id
			 , @in_vchItem AS item_number
			 , ISNULL(location_id,@in_vchLocation) AS location_id
			 , sequence
			 , rule_id
			 , sproc_name
			 , description
			 , resultMYCHE
			 , replen_quantity
			 , priority
			 , execution_seconds
		  FROM #tmp_rule_set
		  ORDER BY sequence
	END
END

GOTO ExitLabel

ErrorHandler:

-- Raise the error with error message, severity, state
RAISERROR(@v_vchErrorMsg, 11, 1)    

ExitLabel:


		--BEGIN V6.0 
IF OBJECT_ID('tempdb..#tmp_rule_set') IS NOT NULL
   DROP TABLE #tmp_rule_set

IF OBJECT_ID(N'tempdb..#t_fwd_priority_sub') IS NOT NULL
DROP TABLE #t_fwd_priority_sub

IF OBJECT_ID(N'tempdb..#t_location_sub') IS NOT NULL
DROP TABLE #t_location_sub

IF OBJECT_ID(N'tempdb..#tmp_item_master_sub') IS NOT NULL
DROP TABLE #tmp_item_master_sub

IF OBJECT_ID(N'tempdb..#tmp_candidate_replen_qty_loc_sub') IS NOT NULL
DROP TABLE #tmp_candidate_replen_qty_loc_sub

IF OBJECT_ID(N'tempdb..#t_temp_sto_sub') IS NOT NULL
DROP TABLE #t_temp_sto_sub

IF OBJECT_ID(N'tempdb..#t_temp_sto1_sub') IS NOT NULL
DROP TABLE #t_temp_sto1_sub

IF OBJECT_ID(N'tempdb..#tmp_candidate_priority') IS NOT NULL
DROP TABLE #tmp_candidate_priority

IF OBJECT_ID(N'tempdb..#t_work_q_sub') IS NOT NULL  
DROP TABLE #t_work_q_sub  

IF OBJECT_ID(N'tempdb..#tmp_work_q') IS NOT NULL  
DROP TABLE #tmp_work_q  
SET NOCOUNT OFF;
--END V6.0

RETURN

END
