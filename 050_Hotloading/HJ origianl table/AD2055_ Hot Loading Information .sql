
/********************************************************************************
 *    Company			: Ashley Furniture Industries								
 *    System   			: HighJump  		 
 *    Module			: 
 *    Procedure			: usp_ww_HotLoad_info_report 					  
 *    Author			: Lily Wei
 *    Date				: 09/26/2024 
 *	  Version			: 1.0							
 *    Description		: This procedure is used generate Hot Loading Information report (AD 2055)
 *    Modification Log  : Date 			Modified By 		Description
 Sample:
	DECLARE 				@in_wh_id      VARCHAR(10),
							@in_load_id    VARCHAR(30)
	select @in_wh_id='51', @in_load_id='5'
	execute [dbo].[usp_ww_HotLoad_info_report] @in_wh_id,@in_load_id

 ********************************************************************************/
CREATE PROCEDURE [dbo].[usp_ww_HotLoad_info_report] (@in_wh_id   VARCHAR(10),
                                                     @in_load_id VARCHAR(30))
AS
    SET NOCOUNT ON

    SELECT CASE special_ship_inst WHEN 'Y' THEN '{{BGCOLOR=#FFFF66}}'ELSE '{{BGCOLOR=WHITE}}'END AS Color,
			wh_id,
           load_id,
           ( description + '(' + load_id + ')' )AS transfer_whse_name,
           order_number,
           arrive_date,
           Sum(qty_shipped)                     AS shipped_pieces,
           Sum(qty)                             AS total_pieces,
           Ceiling(Sum(qty_left * cube))        AS left_cubes,
           Ceiling(Sum(qty_left * cube) / 2300) AS need_containers,
           Sum(planned_qty)                     AS Rls_PKD,
           Sum(open_allocation)                 AS open_allocation,
		   special_ship_inst	--1216752
    FROM   (SELECT orm.wh_id,
                   orm.load_id,
                   Isnull(tlk.description, '')                           AS description,
                   orm.order_number,
                   orm.arrive_date,
                   ord.item_number,
                   Sum(ord.qty_shipped)                                  AS qty_shipped,
                   Sum(ord.qty)                                          AS qty,
                   Sum(ord.qty - ord.qty_shipped)                        AS qty_left,
                   Isnull(itm.nested_volume, Isnull(itm.unit_volume, 0)) AS cube,
                   Sum(Isnull(pkd.planned_qty, 0))                       AS planned_qty,
                   Sum(Isnull(allo.open_qty, 0))                         AS open_allocation,
				   (CASE Isnull(tssi.customer_number,'') WHEN '' THEN '' else 'Y' end) AS special_ship_inst	--1216752
            FROM   dbo.t_order (NOLOCK) orm
                   JOIN dbo.t_order_detail (NOLOCK) ord
                     ON orm.order_number = ord.order_number
                        AND orm.wh_id = ord.wh_id
                   JOIN dbo.t_item_master(NOLOCK) itm
                     ON itm.item_number = ord.item_number
                        AND itm.wh_id = ord.wh_id
                   JOIN dbo.t_lookup (NOLOCK) lok
                     ON orm.type_id = lok.lookup_id
                        AND orm.wh_id = lok.wh_id
                   LEFT JOIN dbo.t_lookup (NOLOCK) tlk
                          ON orm.load_id = tlk.text
                             AND orm.wh_id = tlk.wh_id
                             AND tlk.source = 't_load_master'
                             AND tlk.lookup_type = 'TRSFWHID'
                             AND tlk.locale_id = '1033'
                             AND lok.locale_id = '1033'
                   LEFT JOIN (SELECT wh_id,
                                     order_number,
                                     item_number,
                                     line_number,
                                     Sum(planned_quantity) AS planned_qty
                              FROM   dbo.t_pick_detail (NOLOCK)
                              WHERE  work_type = '35'
                                     AND status <> 'SHIPPED'
                              GROUP  BY wh_id,
                                order_number,
                                        item_number,
                                        line_number) pkd
                          ON pkd.wh_id = ord.wh_id
                             AND pkd.order_number = ord.order_number
                             AND pkd.item_number = ord.item_number
                             AND pkd.line_number = ord.line_number
                   LEFT JOIN (SELECT wh_id,
                                     item_number,
                                     load_id,
                                     ( allocation_qty - allocated_qty ) AS open_qty
                              FROM   dbo.t_soft_allocate_hotload (NOLOCK)) allo
                          ON ord.wh_id = allo.wh_id
                             AND ord.item_number = allo.item_number
                             AND orm.load_id = allo.load_id
					--1216752
					LEFT JOIN dbo.t_order_c_number tocn (NOLOCK)
						  ON orm.wh_id = tocn.wh_id AND orm.order_number = tocn.order_number
					LEFT JOIN dbo.t_special_shipping_instructions tssi (NOLOCK)
						  ON tssi.customer_number = tocn.customer_number
            WHERE  lok.source = 't_order'
                   AND lok.text = 'HotLoad Orders'
                   AND orm.status NOT IN( 'S', 'X', 'C' )
                   AND orm.wh_id = @in_wh_id
                   AND ( CASE @in_load_id
                           WHEN '%' THEN orm.load_id
                           ELSE @in_load_id
                         END ) = orm.load_id
            GROUP  BY orm.wh_id,
                      orm.load_id,
                      tlk.description,
                      orm.order_number,
                      ord.item_number,
                      itm.nested_volume,
                      itm.unit_volume,
                      orm.arrive_date,
					  (CASE Isnull(tssi.customer_number,'') WHEN '' THEN '' else 'Y' end)) temp_qty
    GROUP  BY wh_id,
              load_id,
              description,
              order_number,
              arrive_date,
			  special_ship_inst			

SET NOCOUNT OFF

