

/********************************************************************************
 *    Company			: Ashley Furniture Industries								
 *    System   			: HighJump  		 
 *    Module			: Advantage Dashboard									
 *    Procedure			: usp_ww_forward_pick_locations_report					  
 *    Author			: Schen
 *    Date				: 03/25/2015
 *	  Version			: 1.0							
 *    Description		: This procedure is used to load page 1369
 *    Modification Log  : Date 		Modified By 		Description
 *                       03/25/2015 Stephen Chen        Pieces going to the forward pick and pieces coming out of the forward pick by date and hour
 ********************************************************************************/
CREATE PROCEDURE [dbo].[usp_ww_forward_pick_locations_report]
@location_id as varchar(50),
@item_number as varchar(30),
@wh_id as varchar(10),
@status as char(1),
@commodity_code as varchar(22),
@report_type as varchar(10)
AS

  --Fill in the cacl with the fwd sto and others storage sto in the temp table.
 SELECT f.wh_id,
         f.location_id,
         l.type,
         f.item_number,
         f.replen_level,
         f.replen_qty,
         f.uom,
         isnull(f.capacity_qty,0) as capacity_qty,
		 case when f.capacity_qty>0
		 then f.capacity_qty
		 when f.replen_level+f.replen_qty>0
		 then f.replen_level+f.replen_qty
		 end capacity_qty_actual,
         l.status,
         i.commodity_code,
         i.pick_put_id,
         i.class_id,
         t.display_desc                   AS pallet_type,
         Isnull(trn.qty, 0)               AS pick_trans_qty,
         (SELECT Sum(Isnull(sto.actual_qty, 0))
          FROM   t_stored_item sto (nolock)
          WHERE  sto.item_number = f.item_number
                 AND sto.location_id = f.location_id
				  AND sto.type = 'STORAGE'
                 AND sto.status = 'A'
                 AND sto.wh_id = f.wh_id) AS fwd_qty,
         (SELECT Sum(Isnull(o_sto.actual_qty, 0))
          FROM   t_stored_item o_sto(nolock)
                 INNER JOIN t_location o_loc(nolock)
                         ON o_sto.wh_id = o_loc.wh_id
                            AND o_sto.location_id = o_loc.location_id
                            AND o_loc.type = 'I'
          WHERE  o_sto.wh_id = f.wh_id
                 AND o_sto.item_number = f.item_number
                 AND o_sto.location_id <> f.location_id
                 AND o_sto.type = 'STORAGE'
                 AND o_sto.status = 'A')  AS notfwd_qty
	INTO #TmpFwd
  FROM   t_fwd_pick f(nolock)
         JOIN t_location l(nolock)
           ON l.location_id = f.location_id
              AND l.wh_id = f.wh_id ---add by schen 2015/3/25
         JOIN t_item_master i (nolock)
           ON f.item_number = i.item_number
              AND i.wh_id = f.wh_id ---add by schen 2015/3/25
         --------2012/12/26 Grace Liu add Pallet type
         JOIN t_pallet (nolock) t
           ON i.pallet_id = t.pallet_id
         LEFT JOIN (SELECT wh_id,---add by schen 2015/3/25
                           item_number,
                           Count(1) AS qty
                    FROM   t_tran_log (nolock)
                    WHERE  tran_type = '303'
                    GROUP  BY wh_id,
                              item_number) trn
                ON f.item_number = trn.item_number
                   AND f.wh_id = trn.wh_id---add by schen 2015/3/25
  --------2012/12/26 Grace Liu end of add
  --- to add by schen 2015/3/25
  WHERE  f.location_id LIKE @location_id
         AND f.item_number LIKE @item_number
         AND f.wh_id LIKE @wh_id
         --Task 1320 AMB add active/inactive choice and finished/nonfinished choice
         AND i.commodity_code NOT LIKE 'ZZ%'
         AND i.commodity_code NOT LIKE 'ZC%'
         AND i.commodity_code NOT LIKE 'ZG%'
         AND i.commodity_code NOT LIKE 'ZR%'
         AND i.commodity_code NOT LIKE 'ZL%'
         AND ( l.status LIKE @status
            OR ( ( @status = 'A'
                       AND l.status IN ( 'E', 'F', 'P' ) )
                      OR ( @status = l.status ) ) )
         AND ( ( @commodity_code = 'F'
                 AND i.commodity_code LIKE 'Z%[^K]' )
                OR ( @commodity_code = 'NF'
                     AND i.commodity_code NOT LIKE 'Z%[^K]' ) )
  GROUP  BY l.type,
            f.location_id,
            f.wh_id,
            f.item_number,
            f.replen_level,
            f.replen_qty,
            f.uom,
            f.capacity_qty,
            l.status,
            i.commodity_code,
            i.pick_put_id,
            i.class_id
            ---add by Grace Liu 2012/12/26
            ,
            t.display_desc,
            Isnull(trn.qty, 0) 
  

if @report_type='DR'
----For the detail report datas
SELECT wh_id,
       location_id,
       type,
       item_number,
       replen_level,
       replen_qty,
       uom,
       capacity_qty,
       status,
       commodity_code,
       pick_put_id,
       class_id,
	     isnull(fwd_qty,0) as fwd_qty,
      Cast(Cast(Isnull(fwd_qty, 0)/capacity_qty_actual*100 AS NUMERIC(18, 2)) AS NVARCHAR(50))+'%' AS current_utilized,---add by schen 2015/3/25
      isnull(notfwd_qty,0) as notfwd_qty,
	  Cast(Cast((Isnull(notfwd_qty, 0)+Isnull(fwd_qty, 0))/capacity_qty_actual*100 AS NUMERIC(18, 2)) AS NVARCHAR(50))+'%' as  potential_utilized, ---add by schen 2015/3/25
       pallet_type,
       pick_trans_qty
	 from #TmpFwd

--ORDER BY l.type
---end of add
else

---for the summary report datas grouy by the class_id
 SELECT class_id,
      Cast(Cast(Isnull(fwd_qty, 0)/capacity_qty_actual*100 AS NUMERIC(18, 2)) AS NVARCHAR(50))+'%' as per_cur_of_cap,---add by schen 2015/3/25
      Cast(Cast((Isnull(notfwd_qty, 0)+Isnull(fwd_qty, 0))/capacity_qty_actual*100 AS NUMERIC(18, 2)) AS NVARCHAR(50))+'%' as per_pot_of_cap ---add by schen 2015/3/25
FROM   (SELECT class_id,
               sum(capacity_qty_actual) as capacity_qty_actual,
               Sum(fwd_qty)        AS fwd_qty,
               Sum(notfwd_qty)     AS notfwd_qty
       		from #TmpFwd
        GROUP  BY class_id
		) summary_report

	IF Object_id ('tempdb..#TmpFwd') IS NOT NULL
  BEGIN
      DROP TABLE #TmpFwd
  END



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    RETURN


