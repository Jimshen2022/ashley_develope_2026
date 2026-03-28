USE AAD_LA
GO 
CREATE OR ALTER PROCEDURE usp_la_srch_cico_group_action
    @in_vchSrchEmployeeID         NVARCHAR(10),
    @in_vchSrchDepartment         NVARCHAR(30),
    @in_vchSrchWhID               NVARCHAR(10),
    @in_vchSrchWorkShiftName      NVARCHAR(30),
    @in_vchGroupActionType        NVARCHAR(30),
    @in_vchUsername               NVARCHAR(30)   

AS

/*********************************************************************************
--                   Copyright ⌐ 2007-2008.
               HighJump Software   Eden Prairie, Minnesota, USA
**********************************************************************************
 
    PURPOSE:
        This stored procedure will .

    DESCRIPTION:
        

    INPUT:
        

    OUTPUT:
        

**********************************************************************************
    MODIFICATIONS:

    $Log: /HJS/AAD/SQL/SQLServer/Labor Advantage/StoredProcs/usp_la_srch_cico_group_action.sql $
-- 
-- 4     8/02/07 5:38p Walterb
-- Updated.
-- 
-- 3     7/31/07 1:38p Walterb
-- Modified where clause so that teams are not inserted.
-- 
-- 2     11/29/06 2:00p Walterb
-- Changed varchar to nvarchar
-- 
-- 1     10/19/06 10:25a Walterb
-- Created.
-- 
*********************************************************************************/

DECLARE
    -- Error handling variables
    @c_vchObjName               NVARCHAR(30),  -- The name that uniquely tags this object.
    @v_nLogLevel                INT,      -- Holds log level (1-5).
    @v_nSysErrorNum             INT,
    @v_nRowCount                INT,
    @v_vchMsg                   NVARCHAR(1000),
    @v_nReturn                  INT,

    -- Local Variables
    @c_chChangeAction           NCHAR(1)
    
    -- Set Constants
    SET @c_vchObjName = N'usp_la_srch_cico_group_action'
    SET @c_chChangeAction = N'Y'

    -- Intialize Variables
    SET @v_nReturn = 0
    SET @v_nSysErrorNum = 0
       
    SET NOCOUNT ON

-----------------------------------------------------------------------------------
--          Remove all records for this user and group action type.
-----------------------------------------------------------------------------------
DELETE
    t_la_employee_group_action
WHERE
    username = @in_vchUsername
    AND group_action_type = @in_vchGroupActionType

--check for errors
SELECT @v_nSysErrorNum = @@ERROR
IF @v_nSysErrorNum <> 0
BEGIN
    SET @v_vchMsg = 'A SQL error occured while attempting to delete record(s) in t_la_employee_group_action.'
    GOTO ERROR_HANDLER
END

-----------------------------------------------------------------------------------
--          Insert the employee group action record(s)
-----------------------------------------------------------------------------------
IF @in_vchGroupActionType = N'TEAMCLOCKINOUT' OR @in_vchGroupActionType = N'TEAMCLOCKIN' 
    OR @in_vchGroupActionType = N'TEAMCLOCKOUT'
BEGIN
    INSERT INTO t_la_employee_group_action
    SELECT 
        emp.employee_id,
        @in_vchUsername,
        @in_vchGroupActionType,
        @c_chChangeAction
    FROM
        t_employee emp
    WHERE
        emp.employee_id LIKE @in_vchSrchEmployeeID
        AND ISNULL(emp.dept, '%') LIKE @in_vchSrchDepartment
        AND emp.wh_id = @in_vchSrchWhID
        AND emp.work_shift LIKE @in_vchSrchWorkShiftName
        AND ISNULL(emp.team_flag, 'N') <> 'Y'
        AND NOT EXISTS(SELECT id FROM t_la_team_cico WHERE id = emp.id AND wh_id = emp.wh_id AND clock_out IS NULL)
    
    --check for errors
    SELECT @v_nSysErrorNum = @@ERROR
    IF @v_nSysErrorNum <> 0
    BEGIN
        SET @v_vchMsg = 'A SQL error occured while attempting to insert a record into t_la_employee_group_action.'
        GOTO ERROR_HANDLER
    END
END 
ELSE
BEGIN
    INSERT INTO t_la_employee_group_action
    SELECT 
        emp.employee_id,
        @in_vchUsername,
        @in_vchGroupActionType,
        @c_chChangeAction
    FROM
        t_employee emp
    WHERE
        emp.employee_id LIKE @in_vchSrchEmployeeID
        AND ISNULL(emp.dept, '%') LIKE @in_vchSrchDepartment
        AND emp.wh_id = @in_vchSrchWhID
        AND emp.work_shift LIKE @in_vchSrchWorkShiftName
        AND ISNULL(emp.team_flag, 'N') <> 'Y'
        AND NOT EXISTS(SELECT employee_id FROM t_la_employee_clock_in_out WHERE employee_id = emp.employee_id AND clock_out IS NULL)
    
    --check for errors
    SELECT @v_nSysErrorNum = @@ERROR
    IF @v_nSysErrorNum <> 0
    BEGIN
        SET @v_vchMsg = 'A SQL error occured while attempting to insert a record into t_la_employee_group_action.'
        GOTO ERROR_HANDLER
    END
END

GOTO EXIT_LABEL

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

    SET @v_vchMsg = @c_vchObjName + ': ' + ' ' + @v_vchMsg
                          + ' SQL Error = ' + CONVERT(VARCHAR(30), ISNULL(@v_nSysErrorNum,0)) + '.'

    RAISERROR(@v_vchMsg, 11, 1)
        
-----------------------------------------------------------------------------------
--                            Exit the Process
-----------------------------------------------------------------------------------
EXIT_LABEL:

    -- Always leave the stored procedure from here.
    RETURN
