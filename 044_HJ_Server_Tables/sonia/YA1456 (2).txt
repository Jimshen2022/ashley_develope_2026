~~Default(header)~~
SELECT '<table style="font-size:11px">'+
'<tr><td width = "5%" style="background-color:red">&nbsp;</td>'+
'<td width = "95%">Records highlighted in RED are needed for Express Trips</td></tr>'+
'<tr><td width = "5%" style="background-color:yellow">&nbsp;</td>'+
'<td width = "95%">Records highlighted in YELLOW are needed for MDC/RDC Trips</td></tr></table>'
AS heading
~~Default~~


~~SQLServer~~
/*2014/07/24 Annie changed begin*/
/*Exec usp_Get_Asn_Equipment_Unload '~Select~','~area_id~'*/
/* --Exec usp_Get_Asn_Equipment_Unload '~Select~','~area_id~','~flag~' */
/*2014/07/24 Annie changed end */

/*V2.0 WW-465 MVP for Automation candidates logic Start*/
DECLARE @ItemCnt INT 
IF NOT EXISTS (SELECT 1 FROM dbo.t_control WITH(NOLOCK) WHERE control_type = 'RR_VALID_ITEM_QTY')
BEGIN
	INSERT INTO dbo.t_control (control_type,description,next_value,config_display,allow_edit)
	VALUES('RR_VALID_ITEM_QTY','Number of valid items on an inbound trailer to qualify for receiving automation','5','SHOW_VA','1')
END

SELECT @ItemCnt =ISNULL(next_value,5) FROM dbo.t_control (NOLOCK) WHERE control_type = 'RR_VALID_ITEM_QTY'

IF OBJECT_ID('tempdb..#sefumatch') IS NOT NULL
     BEGIN
	DROP TABLE #sefumatch
     END

CREATE TABLE #sefumatch (              
    highlight varchar(100),              
    unload_priority varchar(100),              
    Cube varchar(100),              
    Piece varchar(100),    
    item_qty int,          
    load_id varchar(100),              
    dispatch_date DATETIME,              
    first_drop_state varchar(100),              
    equipment_id varchar(100),              
    carrier_name varchar(100),              
    Itnbr varchar(100),              
    status varchar(100),              
    location_name varchar(100),              
    Suggested_Disposition varchar(100),              
    Disposition_Unit varchar(100),              
    Disposition varchar(100),              
    zone varchar(100),              
    priority varchar(100),              
    scheduled_by varchar(100),              
    asn_number varchar(100),              
    Arrival DATETIME,              
    Expected_Arrival DATETIME,              
    Percent_complete varchar(100),              
    Review_Inventory varchar(100),              
    trailer_id varchar(100),              
    area_id varchar(100),              
    work_q_id varchar(100),              
    Null_Sort varchar(100),              
    Demand varchar(100),              
    Sort varchar(100),              
    backorder_cube varchar(100)              
  )  
--V2.0 WW-465 MVP for Automation candidates logic, improve the performance, move insert to usp_Get_Asn_Equipment_Unload 

IF ( '~sefu_version~' = 'RM' )

Exec usp_Get_Asn_Equipment_Unload '~Select2~','~area_id~','~flag~','0','~sefu_version~'  -- 13/12/2023 - Pallav - 1075119 - SEFU Consolidation - Development

ELSE

Exec usp_Get_Asn_Equipment_Unload '~Select~','~area_id~','~flag~','0','~sefu_version~'

--V2.0 WW-465 MVP for Automation candidates logic
select  highlight,unload_priority,CASE WHEN item_qty<= @ItemCnt THEN 'Y' ELSE '' END as Automation,
 load_id, dispatch_date,first_drop_state,equipment_id,carrier_name,              
 Itnbr,status,location_name,Suggested_Disposition,Disposition_Unit,Disposition,zone,priority,scheduled_by,asn_number,
 Arrival,Expected_Arrival,Percent_complete,Review_Inventory,trailer_id,area_id,work_q_id,Null_Sort,Demand,Sort,backorder_cube
 from #sefumatch