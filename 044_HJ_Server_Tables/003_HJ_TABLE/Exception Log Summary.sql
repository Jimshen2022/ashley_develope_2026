  
/********************************************************************************************************    
*    Company   : Ashley Furniture Industries                     
*    System    : HighJump            
*    Module    :     
*    Procedure   : usp_search_exception_log    
*    Author    : Pallav Anand     
*    Date    : 20th Sep 2023   
*    Version   : 1.0     
*    Description  : This SP is used in WW page to search and display exception log records.  
*    Modification Log   : Date         Modified By  Description                                                                                                                                                       Version  
                         20/09/2023     Pallav     974367 - Combine Error WW Pages - Capture all exceptions and put in exception log                                                                                    V1.0    
                        11/07/2024     Shakti      1243610 - User should be able to search by License Plate and filter by AULD                                                                                           V1.1    
                        29/01/2025     Vasanth     1282116  - HC1282116 - Menu Consolidation - Need to include the missing fields from Putaway Overrides Page to Exception Log Summary Web Page in Advantage Dashboard    2.0  
  
  
*********************************************************************************************************/    
  
CREATE   PROCEDURE [dbo].[usp_search_exception_log]  
  
  @in_start_tran_date   DATETIME,     
  @in_end_tran_date     DATETIME,    
  @in_start_tran_time   DATETIME,    
  @in_end_tran_time     DATETIME,    
  @in_vch_item_number       VARCHAR(30),    
  @in_vch_tran_type         VARCHAR(10),--The datatype was increased to fit in tran_type that were more than 3 characters ex:AULD.   
  @in_vch_wh_id             VARCHAR(10),    
  @in_vch_location_id       VARCHAR(50),     
  @in_vch_reference_no  VARCHAR(30),    
  @in_vch_po_mo_number  VARCHAR(30),  
  @in_vch_load_id   VARCHAR(30),  
  @in_vch_suggested_value VARCHAR (30),  
  @in_vch_entered_value  VARCHAR (30),  
  @in_vch_lot_number  VARCHAR (30),  
  @in_vch_supervisor        VARCHAR(30),    
  @in_vch_employee_id       VARCHAR(30),    
  @in_vch_dept              VARCHAR(11),    
  @in_vch_pick_put_id       VARCHAR(15),    
  @in_vch_pick_run_id       VARCHAR(30),    
  @in_vch_commodity_code    VARCHAR(22),  
  @in_vch_hu_id    VARCHAR(30)--V1.1(Added new variable hu_id)  
  
  
AS  
SET NOCOUNT ON  
  
BEGIN  
  
SELECT DISTINCT t.item_number,  
  itm.commodity_code,  
  itm.pick_put_id,  
   CASE    
         WHEN t.lot_number IS NOT NULL THEN 1    
         ELSE uom.conversion_factor    
         END AS conversion_factor,  
  t.lot_number,  
  t.wh_id,  
  t.location_id,  
  (SELECT type FROM dbo.t_location (NOLOCK) WHERE location_id = t.location_id AND wh_id=t.wh_id ) AS loc_type,    
  t.location_id_2,  
  (SELECT type FROM dbo.t_location (NOLOCK) WHERE location_id = t.location_id_2 AND wh_id=t.wh_id ) AS loc_type_2,   
  t.reference,  
  t.load_id,  
  t.quantity,  
  --t.hu_id,--V1.1  
  t.tran_type,  
  t.description,  
  t.employee_id,  
  ISNULL (e.name,u.full_name) as employee_name,  
  ISNULL (e.supervisor, u.supervisor) as supervisor,  
  ISNULL (d1.description,d2.description) as department,  
  CONVERT (date, t.exception_date, 101) as exception_date,  
  CONVERT (VARCHAR,t.exception_time,108)  AS exception_time,  
        t.suggested_value,  
        l2.type as suggested_type, --2.0  
        t.suggested_loc_class, --2.0  
        t.entered_value,   
        l3.type as entered_type, --2.0  
        t.entered_loc_class, --2.0  
  t.pick_run_id,  
  t.mo_number,  
  t.asn_no,  
  t.trailer_no,  
  t.equipment_zone,  
  t.work_q_id,  
  t.pallet_type,  
  t.approved_on,  
  t.approved_by,  
  t.replen_qty,  
  t.replen_level,  
  t.capacity_qty,  
  t.sto_qty,  
  t.assign_qty,  
  t.as400_qty,  
  t.adjust_qty,  
  t.remove_qty,  
  t.hjorignqty_shipqty,  
  t.openqty_unreleasedqty,  
  t.remaining_qty,  
  t.line_number,  
  t.hu_id--V1.1(added hu_id in select clause)  
  
  
  
  
  
  
FROM dbo.t_exception_tran_log  t (NOLOCK)  
LEFT JOIN dbo.t_item_master itm (NOLOCK)  
  ON t.item_number=itm.item_number AND t.wh_id=itm.wh_id  
LEFT JOIN dbo.t_item_uom uom (NOLOCK)    
 ON itm.item_number = uom.item_number    
 AND itm.uom = uom.uom    
 AND itm.wh_id = uom.wh_id   
LEFT JOIN dbo.t_location l (NOLOCK)  
  ON l.location_id=t.location_id  
----------------------- 2.0 STARTS ---------------------------------------------------------------------------------------------------  
LEFT JOIN t_location l2 (nolock)   
     ON t.suggested_value = l2.location_id AND t.wh_id = l2.wh_id   
LEFT JOIN t_location l3 (nolock)   
     ON t.entered_value = l3.location_id  AND t.wh_id = l3.wh_id  
  ------------------- 2.0 ENDS ------------------------------------------------------------------------------  
LEFT JOIN dbo.t_employee e (NOLOCK)    
 ON CAST(t.employee_id AS varchar) = CAST(e.id  AS VARCHAR)   
 LEFT JOIN dbo.t_user u (NOLOCK)  
 ON CAST(t.employee_id AS varchar) = CAST(u.id  AS VARCHAR)   
LEFT JOIN dbo.t_department d1 (NOLOCK)    
 ON e.dept = d1.department and e.wh_id = d1.wh_id    
 LEFT JOIN dbo.t_department d2 (NOLOCK)    
 ON u.dept = d2.department and u.wh_id = d2.wh_id    
  
WHERE  
  
 t.exception_date >= CONVERT(VARCHAR(23), Cast(@in_start_tran_date  AS DATETIME), 121)    
       AND t.exception_date <= CONVERT(VARCHAR(23), Cast(@in_end_tran_date+'23:59:59.998' AS DATETIME), 121)    
       AND ( CONVERT(TIME,t.exception_time) >= CONVERT(TIME, @in_start_tran_time  )  
              OR Datediff(dd, t.exception_date, Cast(@in_start_tran_date AS DATETIME)) <> 0 )    
       AND (CONVERT(TIME,t.exception_time) <= CONVERT(TIME,@in_end_tran_time )    
              OR Datediff(dd, t.exception_date, Cast(@in_end_tran_date AS DATETIME)) <> 0 )    
       AND Isnull(t.item_number, '%') LIKE @in_vch_item_number    
       AND ( t.tran_type LIKE @in_vch_tran_type )    
       AND t.wh_id LIKE @in_vch_wh_id    
      AND  ISNULL(t.location_id,'%') LIKE @in_vch_location_id    
       AND (ISNULL(e.supervisor,'') LIKE @in_vch_supervisor  OR ISNULL(u.supervisor,'') LIKE @in_vch_supervisor )  
       AND ISNULL(t.employee_id,'') LIKE @in_vch_employee_id    
       AND (isnull(d1.department,'%') LIKE @in_vch_dept OR isnull(d2.department,'%') LIKE @in_vch_dept )  
    AND ISNULL(t.reference,'%') LIKE @in_vch_reference_no  
    AND ISNULL(t.mo_number,'') LIKE @in_vch_po_mo_number  
    AND ISNULL(t.load_id,'%') LIKE @in_vch_load_id  
    AND ISNULL(t.suggested_value,'%') LIKE @in_vch_suggested_value  
    AND ISNULL(t.entered_value,'%') LIKE @in_vch_entered_value  
    AND ISNULL(t.lot_number,'%') LIKE @in_vch_lot_number  
    AND Isnull(itm.pick_put_id, '%') LIKE @in_vch_pick_put_id    
       AND Isnull(t.pick_run_id, '%') LIKE @in_vch_pick_run_id    
       AND Isnull(itm.commodity_code, '%') LIKE @in_vch_commodity_code   
    AND Isnull(t.hu_id, '%') LIKE @in_vch_hu_id --V1.1 (added hu_id in where condition)  
  
END  
  
  