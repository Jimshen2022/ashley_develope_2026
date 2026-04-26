-- *******************************************************************************
-- Stored Procedure: usp_ww_pick_run_report.sql
-- *******************************************************************************
/*****************************************************************************************

Author					: Sonia Xu
Date					: 11.05.2012
Description				: get pick run logging for trip number
Modification Log		: Date 		       Modified By 		Description 
									2013/03/13	Sonia Xu		   added fields for pick run id link to transaction report
                                    09/29/2014  Stephen Chen       task add muti wh_id for wanek		
									2015/12/11  Grace Liu			fix due to PICK Run work queue is null (more work queue) and cause lots of records				
									2018/09/07  Lily Wei			DMND0127282 picking quality report, add more filter conditions.
									2018/09/26	Lily				Hot Fix: show all employees base on dept, sup and emp                                                             
									2018/12/12	Lily				DMND000000 - Picking Quality data capture/logging
									04/28/2022  Dharani             806509-WW - Operational Visibility - Required phase 1
									2023/06/15  Grace Liu			1013393  fix picking fragment show issue due to night shift cross date
									2023/08/02  Sonia Xu             1042032 - Fragmented pick issue
									2024/01/16  Gaurav Patil  V1.1   User Story 1099786: Web Wise Page Change - Pick Run Report, Picking Quality Report.
									2024/01/17  Dharani       V1.2   PRB1083961 - Hard lock on MDC/RDC users 
									2024/02/16	KOKILA		  V1.3	1098565- Long Picking with double capacity ?New Scanner Menu and Pick assignment
									2024/03/29  Sonia Xu    1136718 - Pick runs in the Pick Run Report not Showing completed when ESR is pressed, and no more items to pick.
									2025/12/09  Grace Liu	WW-528  transfer pick run V14
******************************************************************************************/
CREATE PROCEDURE [dbo].[usp_ww_pick_run_report]
    @in_vchWhID				NVARCHAR(10),
    @in_vchEmpID			NVARCHAR(10),
    @in_vchTripNbr			NVARCHAR(30),
    @in_vchStartDate		DATETIME,
    @in_vchEndDate			DATETIME,
	@in_vchBatch_id		    VARCHAR(100),
	/*DMND0127282 begin*/
	@in_vchFilter     NVARCHAR(1),--D:Department,S:Supervisor,E:Employee
    @in_vchSupID      NVARCHAR(10),
     @in_vchDeptID     NVARCHAR(11),
	/*DMND0127282 end*/
    @out_vchOutCode      NVARCHAR(10)   OUTPUT,
    @out_vchOutMsg			NVARCHAR(100)   OUTPUT
   
AS
	
	
SET NOCOUNT ON	    
    
  --declare variables
  DECLARE
    -- Error handling and logging variables.
    @c_vchObjName						VARCHAR(20), 
    @c_nModuleNumber				INT, -- The # that uniquely tags the WA collection of objects.
    @c_nFileNumber						INT, -- The # that uniquely tags this object.
    @v_nLogErrorNum					INT, -- The # that uniquely tags the error message. 
    @v_nLogLevel							INT, -- Holds log level (1-5).
    @v_vchErrorMsg						NVARCHAR(500),
    @v_nErrorNumber					INT,
    @v_nRowCount						INT,
    @v_nReturn								INT,
    @v_dtStartDate						DATETIME,
    @v_dtEndDate							DATETIME
         
       
    -- Local Variables
    SET @out_vchOutCode = 'NOT SET';
    SET @out_vchOutMsg = 'NOT SET';    
  
    SET @c_vchObjName = 'usp_ww_pick_run_report'
    SET @out_vchOutMsg = 'SUCCESS'
    SET @v_nReturn = 0
    
    SET @v_dtStartDate = @in_vchStartDate + ' 00:00:00.000'
    SET @v_dtEndDate = @in_vchEndDate + ' 23:59:59.000'

	/*DMND0127282 begin*/
	    DECLARE @v_nEmpID     NVARCHAR(10),
            @v_nSupID     NVARCHAR(10),
            @v_nDeptID    NVARCHAR(11)

	IF @in_vchEmpID = '%'
      SET @v_nEmpID = NULL
    ELSE
      SET @v_nEmpID = @in_vchEmpID

    IF @in_vchSupID = '%'
      SET @v_nSupID = NULL
    ELSE
      SET @v_nSupID = @in_vchSupID

    IF @in_vchDeptID = '%'
      SET @v_nDeptID = NULL
    ELSE
      SET @v_nDeptID = @in_vchDeptID

    IF Object_id('tempdb..#tblEmp') IS NOT NULL
      DROP TABLE #tblEmp

    CREATE TABLE #tblEmp
      (
         wh_id          NVARCHAR(10),
         id             NVARCHAR (10),
         name           NVARCHAR(30),
         employee_id    INT,
         supervisor_nbr INT,
         supervisor     NVARCHAR(30),
         dept           NVARCHAR(11),
         dept_name      NVARCHAR(100)
      )

	   INSERT INTO #tblEmp
                  (wh_id,
                   id,
                   name,
                   employee_id,
                   supervisor_nbr,
                   supervisor,
                   dept,
                   dept_name
   )
	 SELECT emp.wh_id,
             emp.id,
             emp.name,
             emp.employee_id,
             emp.supervisor_nbr,
             emp.supervisor,
             emp.dept,
             dept.description
      FROM   v_active_employees emp(nolock)
             INNER JOIN t_department dept(nolock)
                     ON emp.dept = dept.department
      WHERE  emp.wh_id = @in_vchWhID
             AND ( @v_nEmpID IS NULL
                    OR emp.id = @v_nEmpID )
             AND ( @v_nSupID IS NULL
                    OR emp.supervisor_nbr = @v_nSupID )
             AND ( @v_nDeptID IS NULL
                    OR emp.dept = @v_nDeptID )
	/*DMND0127282 end*/

   Create table #temp_tran_log 
   (
	wh_id							nvarchar(3),
	tran_type					nvarchar(3),
	routing_code				int,
	employee_id				nvarchar(10),
	item_number				nvarchar(30),
	control_number			nvarchar(30),
	control_number_2		nvarchar(30),
	start_date					datetime,
	end_date					datetime,	
	tran_qty						float
	
   )

    
    IF @in_vchWhID IS NULL OR @in_vchEmpID IS NULL OR @in_vchTripNbr IS NULL
	BEGIN 
		SELECT @out_vchOutCode = '-20001'
        SET @out_vchOutMsg = 'Missing input data'
        GOTO ERROR_HANDLER
	END
 ---- get tran_log data		  
		insert into #temp_tran_log
		select trn.wh_id
			,tran_type
			,routing_code
			,trn.employee_id
			,item_number
			,control_number
			,control_number_2
			,convert (varchar(10),start_tran_date,23)+' '+ convert(varchar(10),start_tran_time,108) as start_date
			,convert (varchar(10),end_tran_date,23)+' '+ convert(varchar(10),end_tran_time,108) as end_date
			,tran_qty			
		from t_tran_log trn(nolock) 
		/*DMND0127282 begin*/
		join #tblEmp emp(nolock) on trn.wh_id = emp.wh_id and trn.employee_id=emp.id
		/*DMND0127282 end*/
		where trn.wh_id = @in_vchWhID
			--and trn.employee_id like @in_vchEmpID 
			and control_number_2 like @in_vchTripNbr
			and start_tran_date >= @in_vchStartDate
			and end_tran_date <= @in_vchEndDate +1
			and tran_type in ('363','365')    ---V14
			and routing_code is not null
		order by log_id 

		create clustered index [i_routing_code]on #temp_tran_log (routing_code,start_date,end_date)
		 
		select a.pick_run_id 
			,sum(a.plate_section_qty) as uph_plate_picked
			,sum(a.tran_qty)as uph_qty
		  into #temp_UPH
		  from (
				select 
					trn.item_number
					,trn.tran_qty
					,trn.tran_qty * ips.plate_section as plate_section_qty
					,pick_run_id
				from #temp_tran_log trn(nolock) 
				join t_pick_run pkr(nolock)
					on trn.routing_code = pkr.pick_run_id
					and pkr.work_type in('42','66','35')  --V14
				join t_item_plate_section ips (nolock)
					on trn.item_number = ips.item_number
					and trn.wh_id = ips.wh_id
				where  trn.wh_id = @in_vchWhID
					and	trn.control_number_2 like @in_vchTripNbr 
					and pkr.plate_section_capacity is not null  --V14
			) a group by a.pick_run_id 
		

/*================Not uph's actual total cubes ========================*/
		select b.pick_run_id
			,ROUND(sum(b.factored_cube)/1728,0) as cg_cubes_picked
			,sum(b.tran_qty) as cg_qty
		  into #temp_CG 
		  from (
				select 
					trn.item_number
					,trn.tran_qty
					,pkr.pick_run_id
					,factored_cube
					,itm.pick_put_id
				from #temp_tran_log trn(nolock) 
				join t_pick_run pkr(nolock)
					on trn.routing_code = pkr.pick_run_id
					and pkr.work_type not in ('42','66')
				join t_item_master itm (nolock)
					on trn.item_number = itm.item_number
					and trn.wh_id = itm.wh_id
				join v_item_uom_factored_cube vitm (nolock)
					on itm.item_number = vitm.item_number
					and itm.uom = vitm.uom
					and itm.wh_id = vitm.wh_id
				where trn.wh_id = @in_vchWhID
					and trn.control_number_2 like @in_vchTripNbr 
					and pkr.cube_capacity is not null    --V14
				)b group by b.pick_run_id
/*=========================end of not UPH =========================================*/
		select p.pick_run_id
	     ,sum(case when e1.tran_type is null then 0 else 1 end) as f1_qty
		 ,sum(case when e2.tran_type is null then 0 else 1 end) as f3_qty
		 ,sum(case when e3.tran_type is null then 0 else 1 end) as f7_qty
		 ,sum(case when e8.tran_type is null then 0 else 1 end) as f6_qty
		  ,sum(case when e4.tran_type is null then 0 else 1 end) as f5_qty --DMND000000
		  ,sum(case when e5.tran_type is null then 0 else 1 end) as f8_qty --DMND000000
		  ,sum(case when e6.tran_type is null then 0 else 1 end) as nofp_qty --DMND000000
		  ,sum(case when e7.tran_type is null then 0 else 1 end) as dcn_qty --DMND000000
		  ,sum(case when e9.tran_type is null then 0 else 1 end) as fcbre_qty --V1.1
		  ,sum(case when e10.tran_type is null then 0 else 1 end) as ovitm_qty --V14
		into #temp_pick_run
		from t_pick_run (nolock) p
		join #tblEmp (nolock) emp on p.employee_id=emp.id
		left join t_exception_log (nolock) e1 on p.pick_run_id=e1.suggested_value and e1.tran_type='DCF1' and p.employee_id=e1.employee_id
		left join t_exception_log (nolock) e2 on p.pick_run_id=e2.suggested_value and e2.tran_type='DCF3' and p.employee_id=e2.employee_id
		left join t_exception_log (nolock) e3 on p.pick_run_id=e3.suggested_value and e3.tran_type IN('303F7','305F7') and p.employee_id=e3.employee_id  --v14
		left join t_exception_log (nolock) e8 on CONVERT(VARCHAR(20),p.pick_run_id)=e8.suggested_value and e8.tran_type='DCF6'and p.employee_id=e8.employee_id
		left join t_exception_log (nolock) e4 on p.pick_run_id=e4.suggested_value and e4.tran_type='302A'and p.employee_id=e4.employee_id
		left join t_exception_log (nolock) e5 on p.pick_run_id=e5.suggested_value and e5.tran_type='DCF8'and p.employee_id=e5.employee_id
		left join t_exception_log (nolock) e6 on p.pick_run_id=e6.suggested_value and e6.tran_type='NOFP'and p.employee_id=e6.employee_id
		left join t_exception_log (nolock) e7 on p.pick_run_id=e7.suggested_value and e7.tran_type='DCN'and p.employee_id=e7.employee_id
		LEFT JOIN t_exception_log (NOLOCK) e9 ON p.pick_run_id=e9.suggested_value AND e9.tran_type='FCBRE' AND p.employee_id=e9.employee_id --V1.1
		LEFT JOIN t_exception_log (NOLOCK) e10 ON p.pick_run_id=e10.suggested_value AND e10.tran_type='OVITM' AND p.employee_id=e10.employee_id  --V14
		where p.start_date_time >= @v_dtStartDate
		and  ISNULL( p.end_date_time ,p.start_date_time) <= @v_dtEndDate
		group by p.pick_run_id
/*=================================batch id===========================================*/

	SELECT bat.batch_id,ldm.load_id,bat.status,ldm.wh_id
	INTO #t_load_master_batch_id
	FROM dbo.t_load_master ldm (NOLOCK)
	LEFT JOIN dbo.t_load_master_batch bat(NOLOCK)
	ON ldm.load_id=bat.load_id
	AND ldm.wh_id=bat.wh_id 
	where (bat.load_id LIKE @in_vchTripNbr + '%' or ldm.load_id LIKE @in_vchTripNbr+ '%')
	AND bat.status='R' 
	AND ldm.wh_id=@in_vchWhID	
---------------------------------------------------------------------------------
--V1.1 START Updating the column fork_capacity_breached 'Y' or 'N' in t_pick_run 
---------------------------------------------------------------------------------
UPDATE pr
SET pr.fork_capacity_breached = CASE 
		WHEN tpr.fcbre_qty > 0
			THEN 'Y'
		ELSE 'N'
		END
FROM #temp_pick_run tpr
JOIN t_pick_run pr ON tpr.pick_run_id = pr.pick_run_id;

--------------------------------
--V1.1 END
--------------------------------

/*========================report===================================================*/
			select 
				pkr.pick_run_id
				,emp.name		
				,case when t.f1_qty >0 then 'Y' else 'N' end as DCF1
				,case when t.ovitm_qty >0 then 'Y' else 'N' end as OVITM   --V14
				,case when t.f3_qty >0 then 'Y' else 'N' end as DCF3	
				,case when t.f7_qty >0 then 'Y' else 'N' end as DCF7
				,case when t.f6_qty >0 then 'Y' else 'N' end as letdown	
				,case when t.f5_qty >0 then 'Y' else 'N' end as DCF5	--DMND000000
				,case when t.f8_qty >0 then 'Y' else 'N' end as DCF8	--DMND000000
				,case when t.nofp_qty >0 then 'Y' else 'N' end as NOFP	--DMND000000	 				 
				,case when t.dcn_qty >0 then 'Y' else 'N' end as DCN	--DMND000000
				,pkr.planned_pcs
				,isnull(cg.cg_qty,0) + isnull(uph.uph_qty,0) as actual_pcs
				,pkr.planned_pcs - isnull(cg.cg_qty,0) - isnull(uph.uph_qty,0) as fragmented_pcs
			    ,CASE WHEN t.fcbre_qty >0 THEN 'Y' ELSE 'N' END AS fork_capacity_breached --V1.1
				,ROUND(isnull(pkr.planned_total_cube,0)/1728,0) as cg_cubes_assigned
				,isnull(cg.cg_cubes_picked,0) as cg_cubes_picked
				,isnull(pkr.planned_total_plate,0) as uph_plate_assigned
				,isnull(uph.uph_plate_picked,0) as uph_plate_picked
				,wkq.work_q_id		
				,(select stuff(( select distinct ';'+control_number_2 FROM(select control_number_2 from #temp_tran_log where routing_code=pkr.pick_run_id)A
					 FOR XML PATH('')),1,1,'')) as pick_ref_number 
				,pkr.zone as equi_zone
				,wkq.zone as wkq_zone 
				,CASE WHEN ISNULL(pkr.end_date_time,'') ='' then 'N'
				ELSE 'Y' 
			    END AS	 complete_status
				,pkr.start_date_time  
				,pkr.end_date_time AS pkr_end_date
				,@in_vchStartDate	as StartDate
				,'00:00:00.001' as StartTime
				,@in_vchEndDate	as EndDate
				,'23:59:59.998' as EndTime
				,pkr.employee_id 
				,wkq.wh_id   
				,'%' as per
	   INTO #t_pick_rprt
			from t_pick_run pkr(nolock)
			join #tblEmp emp(nolock) on pkr.employee_id=emp.id --Lily
			left join #temp_pick_run (nolock) t on t.pick_run_id=pkr.pick_run_id --Grace
			left join t_work_q (nolock) wkq
			       on pkr.work_q_id = wkq.work_q_id 
			left join #temp_UPH  uph (nolock)
				on  pkr.pick_run_id = uph.pick_run_id
			left join #temp_CG  cg (nolock)
				on pkr.pick_run_id = cg.pick_run_id
			where 
				 isnull(wkq.pick_ref_number,'') like @in_vchTripNbr   
				and pkr.start_date_time >= @v_dtStartDate
				and isnull (pkr.end_date_time, pkr.start_date_time )<= @v_dtEndDate  --2024/04/29 Sonia
				and emp.wh_id=@in_vchWhID  
			order by pkr.pick_run_id

  
/*=========================report batch id==============================*/
	SELECT 
				pick_run_id
				,name		
				,DCF1
				,OVITM   --V14
				,DCF3	
				,DCF7
				,letdown	
				,DCF5	--DMND000000
				,DCF8	--DMND000000
				,NOFP	--DMND000000	 				 
				,DCN	--DMND000000
				,planned_pcs
				,actual_pcs
				,fragmented_pcs
				,fork_capacity_breached --V1.1
				,cg_cubes_assigned
				,cg_cubes_picked
				,uph_plate_assigned
				,uph_plate_picked
				,work_q_id		
				,CASE WHEN id.status='R' THEN id.batch_id ELSE pick_ref_number END AS pick_ref_number
				,equi_zone
				,wkq_zone 
				,complete_status
				,start_date_time
				,pkr_end_date  
				,StartDate
				,StartTime
				,EndDate
				,EndTime
				,employee_id 
				,rprt.wh_id   
				,per
		FROM #t_pick_rprt rprt 
			LEFT JOIN  #t_load_master_batch_id id 
			    ON rprt.pick_ref_number=id.load_id
				WHERE 1= CASE WHEN @in_vchBatch_id ='%' THEN 1
				                WHEN id.batch_id = @in_vchBatch_id THEN 1 
								ELSE 0
				            END
					         
/*==========================================================*/

SELECT @v_nErrorNumber = @@ERROR
    IF @v_nErrorNumber <> 0
    BEGIN
        SELECT @out_vchOutCode = '-20005'
        SET @out_vchOutMsg = 'A SQL error occured while selecting the report data for pick run.'
        GOTO ERROR_HANDLER
    END
--                            Error Handling
-----------------------------------------------------------------------------------

GOTO ExitLabel

ERROR_HANDLER:

    SET @out_vchOutMsg = @c_vchObjName + ': [' + @out_vchOutCode + '] ' + @out_vchOutMsg
                    + ' [SQL Error = ' + CONVERT(VARCHAR(30), ISNULL(@v_nErrorNumber,0)) + '].'

    RAISERROR(@out_vchOutCode, @out_vchOutMsg, 11, 1)
    
    
ExitLabel: 
if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#temp_tran_log')) 
begin 
	drop table #temp_tran_log
end
if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#temp_pkr_end_date')) 
begin 
	drop table #temp_pkr_end_date
end
if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#temp_UPH')) 
begin 
	drop table #temp_UPH
end
if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#temp_CG')) 
begin 
	drop table #temp_CG
end
 
 /*DMND0127282 begin*/
 if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#tblEmp')) 
begin 
	drop table #tblEmp
end

 if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#temp_pick_run')) 
begin 
	drop table #temp_pick_run
end
	/*DMND0127282 end*/
	-------------------
 if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#t_load_master_batch_id')) 
begin 
	drop table #t_load_master_batch_id
end

 if exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#t_pick_rprt')) 
begin 
	drop table #t_pick_rprt
end

    RETURN 


