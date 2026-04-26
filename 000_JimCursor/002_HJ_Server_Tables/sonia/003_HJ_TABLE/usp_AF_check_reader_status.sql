
/*********************************************************************************************************************************
 *    Author         	: Tessa Lockington                        									 
 *    Date		: 4-04-2007                                       						   	 
 *    Description	: Checks to see what the status of this reader is
 *			  													
 *    Modification Log   :  Date 		Modified By 	  Description				
 * 	  PBI344003		 		2019.9.18	TJP				  Modified to not allow SIM reset on devices that contain allocated inventory						  
 **********************************************************************************************************************************/

CREATE PROCEDURE [dbo].[usp_AF_check_reader_status]
    @in_DeviceID		VARCHAR(30)
AS

  DECLARE
  	--error handling variables
	@error_num			NVARCHAR(100),
	@error_msg			NVARCHAR(500),

	--declare working variables
    @v_nForkInv 	    INT,
    @v_nWorkQCnt 	    INT,
    @v_nWorkQ	 	    INT,
    @v_nRecCount		INT,
	@v_nAllocInv		INT,
	@v_nNonAllocInv		INT,
	@v_nAllocLoc		VARCHAR(50),
	@v_nNonAllocLoc		VARCHAR(50)
  
--Tables for t_work_q    
DECLARE @v_temp_reader		  
    TABLE (
	wh_id				VARCHAR(5),
	device				VARCHAR(30),
	employee			VARCHAR(30),
	fork				VARCHAR(50),
	type				VARCHAR(10),
	inventory			VARCHAR(100),
	work_q				VARCHAR(50),
	action1				VARCHAR(25)
	)

BEGIN TRY

 --Get user assigned to device and check to see if there is inventory on fork  
	INSERT INTO @v_temp_reader (wh_id, device, employee, fork, type, inventory, work_q, action1)
	SELECT e.wh_id, e.device, e.id, loc.location_id, loc.type, '' AS Message, '' AS work_q, 'Clear Reader' AS action1
	FROM dbo.t_employee e (NOLOCK)
	LEFT JOIN dbo.t_location loc on e.id = c1
		WHERE e.device = @in_DeviceID

	IF EXISTS 
		(SELECT 'TRUE' FROM @v_temp_reader WHERE ISNULL(fork, '') <> '')
 
		BEGIN 
		  --Check to see if user has allocated inventory on forks or LTC cart and if non-allocated inventory on forks or LTC cart
			SELECT @v_nAllocInv = SUM(CASE WHEN ISNULL(sto.type, '') <> 'STORAGE' THEN sto.actual_qty ELSE 0 END),
				   @v_nAllocLoc = MAX(CASE WHEN ISNULL(sto.type, '') <> 'STORAGE' THEN sto.location_id ELSE '' END),
				   @v_nNonAllocInv = SUM(CASE WHEN ISNULL(sto.type, '') = 'STORAGE' THEN sto.actual_qty ELSE 0 END),
				   @v_nNonAllocLoc = MAX(CASE WHEN ISNULL(sto.type, '') = 'STORAGE' THEN sto.location_id ELSE '' END)
			FROM @v_temp_reader r
			LEFT JOIN dbo.t_stored_item sto (NOLOCK) ON r.fork = sto.location_id and r.wh_id = sto.wh_id
				WHERE r.device = @in_DeviceID AND r.type IN ('F','CR')

			IF @v_nAllocInv > 0
				BEGIN
					UPDATE @v_temp_reader 
						SET inventory = 'Allocated Inventory on Fork Location: '+ISNULL(@v_nAllocLoc,''), action1 = NULL
						WHERE device = @in_DeviceID
				END
			ELSE IF @v_nNonAllocInv > 0
				BEGIN
					UPDATE @v_temp_reader 
					   SET inventory = 'Non-Allocated Inventory on Fork Location: '+ISNULL(@v_nNonAllocLoc,'')
						WHERE device = @in_DeviceID	
				END
			ELSE 
				BEGIN 
					UPDATE @v_temp_reader 
					   SET inventory = 'No Inventory on Fork Location'
						WHERE device = @in_DeviceID	
				END
		END
	
	IF EXISTS 
		(SELECT 'TRUE' FROM @v_temp_reader WHERE ISNULL(employee, '') <> '')

		BEGIN
		  --If work queue(s) are assigned, then notify
			UPDATE r 
			SET work_q = 'Work Qs Assigned'
			FROM @v_temp_reader r
			JOIN dbo.t_work_q_assignment wka (NOLOCK) ON r.employee = wka.user_assigned AND r.wh_id = wka.wh_id
				WHERE device = @in_DeviceID
		END

    SELECT @v_nRecCount = COUNT(1) FROM @v_temp_reader

    IF(@v_nRecCount < 1)
	INSERT INTO @v_temp_reader (device)
        VALUES ('Nobody assigned to Device.')
         
    SELECT * FROM  @v_temp_reader

END TRY

BEGIN CATCH

	SELECT	@error_num = ERROR_NUMBER(),
			@error_msg = CONVERT(NVARCHAR, ERROR_NUMBER())+' '+ERROR_MESSAGE()

		RAISERROR(@error_msg,18,1)
	
	RETURN

END CATCH

