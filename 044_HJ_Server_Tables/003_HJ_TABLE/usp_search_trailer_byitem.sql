/****************************************************************************************
  Company: Ashley Furniture Industries Inc.
  Name:  usp_search_trailer_byitem
  Description: Took from web wise page .This procedure is used to get the trailer data by Item and some filter     

 ----------------------------------------------------------------------------------------
  Objects accessed:
	dbo.t_item_uom_approval_queue
	dbo.t_item_capacity_approval_queue
	dbo.t_putaway_dimensions
	dbo.v_class_eligible_strata
	dbo.t_modified_xml
 ----------------------------------------------------------------------------------------
 *TESTING :
 
DECLARE @in_locationname VARCHAR(30) ='%',  
    @in_areaname  VARCHAR(50)='%',  
    @in_status  VARCHAR(50)='%',  	 
    @in_state  VARCHAR(10)='%',  	  
    @in_commoditycode  VARCHAR(30)='%',  	 
    @in_trailertypename  VARCHAR(50)='%',  	  
    @in_comments   VARCHAR(50)='%',  	   
    @in_item_id  VARCHAR(30)='%',  	  
	@in_vendorcode  NVARCHAR(10)='%',  	 
    @in_cust_ponumber   NVARCHAR(30) ='%' ,
	@in_itemtype   VARCHAR(30)  ='%'
EXEC [usp_search_trailer_byitem]   
    @in_locationname , @in_areaname, @in_status, @in_state,  	  
    @in_commoditycode , @in_trailertypename, @in_comments,  
    @in_item_id,@in_vendorcode,   @in_cust_ponumber  ,@in_itemtype  
 ----------------------------------------------------------------------------------------
  Change # | Date     | Author            | Product Backlog Item / Defect
 ----------------------------------------------------------------------------------------
    1.1    | 23AUG23  | KOKILA			  | 1002748-Add drop down on Search trailers by item for trailers that contain an RP
*****************************************************************************************/ 
CREATE PROCEDURE [dbo].[usp_search_trailer_byitem]  
    @in_locationname VARCHAR(30),  
    @in_areaname  VARCHAR(50),  
    @in_status  VARCHAR(50),  	 
    @in_state  VARCHAR(10),  	  
    @in_commoditycode  VARCHAR(30),  
    @in_trailertypename  VARCHAR(50),  
    @in_comments   VARCHAR(50),  
    @in_item_id  VARCHAR(30),  
	@in_vendorcode  VARCHAR(10), 
    @in_cust_ponumber   VARCHAR(30),
	@in_itemtype   VARCHAR(30)   
AS  
BEGIN  
	
	--1.1 STARTS
	IF OBJECT_ID('tempdb..#tmp_RP_item_order') IS NOT NULL  
		DROP TABLE #tmp_RP_item_order

	IF OBJECT_ID(N'tempdb..#result_items') IS NOT NULL 
		DROP TABLE #result_items 
	CREATE TABLE #tmp_RP_item_order
	(		
		 item_number	NVARCHAR(60)
		 ,item_type		NVARCHAR(10)
	)

	CREATE TABLE #result_items
	(
		equipment_id VARCHAR(100),
		trailer_id VARCHAR(100),
		status VARCHAR(100),
		state VARCHAR(100),
		carrier_id VARCHAR(100),
		location_name VARCHAR(100),
		zone VARCHAR(100),
		disposition VARCHAR(100),
		customer_po_number VARCHAR(100),
		vendor_code VARCHAR(100),
		counted VARCHAR(100),
		entered_yard VARCHAR(100),
		disposition_unit VARCHAR(100),
		exited_yard VARCHAR(100),
		asn_number VARCHAR(100),
		item_number VARCHAR(100),
		Qty_shipped VARCHAR(100),
		conversion_ship VARCHAR(100),
		Qty_received VARCHAR(100),
		conversion_rec VARCHAR(100),
		Qty_remaining  VARCHAR(100),
		conversion_rem  VARCHAR(100),
		Qty_rec  VARCHAR(100),
		Qty_rem VARCHAR(100),
		trailer_type_name  VARCHAR(100),
		comments  VARCHAR(100),
		Scheduled  VARCHAR(100),
		area_id  VARCHAR(100),
		Item_Type  VARCHAR(100)  
	)

	INSERT INTO #tmp_RP_item_order 
		SELECT distinct d.item_number,'RP' FROM dbo.t_order(NOLOCK) o
		JOIN dbo.t_order_detail(NOLOCK) d ON o.order_number=d.order_number AND  o.wh_id = d.wh_id
		WHERE o.type_id='1159'  

	--1.1 ENDS
IF @in_status ='<ANY>NO LOST/HISTORY'
BEGIN
INSERT INTO #result_items --1.1
SELECT DISTINCT t.equipment_id,
t.trailer_id,
t.status,
t.state,
t.carrier_id,
l.location_name,
t_ya_work_q.zone,
asn.disposition,
d.customer_po_number,
vendor_code
,t.counted,
t.entered_yard,
/* GLR 4/15/11 add schedule to door */
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - Do not allow scheduling of equipment in DRAYAGE locations.
  'Go To' AS disposition_unit, 
*/
(CASE WHEN l.[type] = 'DRAYAGE' THEN NULL ELSE 'Go To' END) AS disposition_unit, 
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - End of change.*/
/* GLR 4/15/11 add schedule to door - END */
t.exited_yard,
asn.asn_number,
d.item_number,
sum(quantity_shipped) AS Qty_shipped,
/* 07/28/11 Angi Brown PV0002169 Add conversion factor for MA */
round(sum(quantity_shipped)/uom.conversion_factor,0) AS conversion_ship,
/* 07/28/11 Angi Brown end change */
sum(quantity_received) AS Qty_received,
/* 07/28/11 Angi Brown PV0002169 Add conversion factor for MA */ 
round(sum(quantity_received)/uom.conversion_factor,0) AS conversion_rec,
/* 07/28/11 Angi Brown end change */
sum(quantity_shipped) - sum(quantity_received) AS Qty_remaining,
/* 07/28/11 Angi Brown PV0002169 Add conversion factor for MA */
round((sum(quantity_shipped) - sum(quantity_received))/uom.conversion_factor,0) AS conversion_rem,
/* 07/28/11 Angi Brown end change */
'', --1.1
'',  --1.1
asn.trailer_type_name,
comments,
CASE
WHEN (t_ya_work_q.zone IS NOT NULL and t_ya_work_q.status = 'UNASSIGNED') THEN 'Y'
ELSE 'N'
END AS 'Scheduled',
a.area_id,
CASE WHEN  ( (ita.inventory_type IN ('FG','RM') AND ita.commodity_code IN ('LA','TA')) OR rpi.item_type='RP' ) THEN 'RP' ELSE 'OTHERS' END AS 'item_type' --1.1
FROM dbo.t_trailer t(NOLOCK)
LEFT JOIN t_trailer_asn trl (NOLOCK) ON t.trailer_id = trl.trailer_id
LEFT JOIN t_asn asn(NOLOCK) 
ON  trl.asn_id = asn.asn_id
AND asn.equipment_id = t.equipment_id
LEFT OUTER JOIN t_ya_work_q(NOLOCK) on t.trailer_id = t_ya_work_q.trailer_id
 AND t_ya_work_q.status = 'UNASSIGNED' and t_ya_work_q.type = '52'
LEFT OUTER JOIN
 (SELECT T2.trailer_id ,comments 
      FROM t_trailer_comments(NOLOCK)
      LEFT OUTER JOIN (Select trailer_id, maxsequence=max(sequence)  
						FROM t_trailer_comments(NOLOCK)
						GROUP BY trailer_id) T2  
		ON t_trailer_comments.trailer_id = T2.trailer_id
		AND t_trailer_comments.sequence = T2.maxsequence ) T3
ON t.trailer_id = T3.trailer_id
JOIN t_asn_detail d(NOLOCK)
ON asn.asn_id = d.asn_id
JOIN t_ya_location l(NOLOCK)
ON t.location_id = l.location_id
JOIN t_area a(NOLOCK) 
ON t.area_id = a.area_id 
JOIN t_po_master p (NOLOCK)             
ON d.customer_po_number = p.po_number
LEFT JOIN t_item_uom uom (nolock)
ON uom.item_number = d.item_number
AND uom.default_receipt_uom = 'YES'
left join t_item_master itm (nolock)
on d.item_number = itm.item_number
left join t_item_attributes ita (nolock)
on d.item_number = ita.item_number
left join #tmp_RP_item_order rpi (nolock)	--1.1
on d.item_number = rpi.item_number			--1.1 
WHERE location_name LIKE @in_locationname            
AND a.area_name LIKE @in_areaname
AND t.state LIKE @in_state
and isnull(asn.trailer_type_name,'') like @in_trailertypename
and isnull(comments,'') like @in_comments
AND d.item_number LIKE @in_item_id
AND itm.commodity_code LIKE @in_commoditycode
AND isnull(p.vendor_code,'') LIKE @in_vendorcode
AND d.customer_po_number LIKE @in_cust_ponumber
AND ((t.status <> 'HISTORY' and t.status <> 'LOST')
AND (t.state = 'IN FULL' or t.state = 'IN PARTIAL')) 
GROUP BY t.equipment_id,t.trailer_id,t.status,t.state,t.carrier_id,l.location_name,t.counted,t.entered_yard,t.exited_yard,asn.asn_number,
d.item_number,asn.trailer_type_name,comments,d.customer_po_number,vendor_code,t_ya_work_q.zone,asn.disposition,t_ya_work_q.status,a.area_id,
uom.conversion_factor
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - Do not allow scheduling of equipment in DRAYAGE locations.*/
, l.[type]
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - End of change.*/ 
,ita.inventory_type,ita.commodity_code,rpi.item_type --1.1
ORDER BY t.entered_yard
END
ELSE
BEGIN
INSERT INTO #result_items
SELECT DISTINCT t.equipment_id,
t.trailer_id,
t.status,
t.state,
t.carrier_id,
l.location_name,
t_ya_work_q.zone,
asn.disposition,
d.customer_po_number,
vendor_code,
t.counted,
t.entered_yard,
/* GLR 4/15/11 add schedule to door */
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - Do not allow scheduling of equipment in DRAYAGE locations.
  'Go To' AS disposition_unit, 
*/
(CASE WHEN l.[type] = 'DRAYAGE' THEN NULL ELSE 'Go To' END) AS disposition_unit, 
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - End of change.*/
/* GLR 4/15/11 add schedule to door - END */
t.exited_yard,
asn.asn_number,
d.item_number,
sum(quantity_shipped) AS Qty_shipped,
/* 07/28/11 Angi Brown PV0002169 Add conversion factor for MA */
round(sum(quantity_shipped)/uom.conversion_factor,0) AS conversion_ship,
/* 07/28/11 Angi Brown end change */
sum(quantity_received) as Qty_received,
/* 07/28/11 Angi Brown PV0002169 Add conversion factor for MA */ 
round(sum(quantity_received)/uom.conversion_factor,0) AS conversion_rec,
/* 07/28/11 Angi Brown end change */
sum(quantity_shipped) - sum(quantity_received) AS Qty_remaining,
/* 07/28/11 Angi Brown PV0002169 Add conversion factor for MA */
round((sum(quantity_shipped) - sum(quantity_received))/uom.conversion_factor,0) as conversion_rem,
/* 07/28/11 Angi Brown end change */
sum(quantity_received) AS Qty_rec, 
sum(quantity_shipped) - sum(quantity_received) AS Qty_rem, 
asn.trailer_type_name,
comments,
CASE
WHEN (t_ya_work_q.zone IS NOT NULL and t_ya_work_q.status = 'UNASSIGNED') THEN 'Y'
ELSE 'N'
END AS 'Scheduled',
a.area_id,
CASE WHEN  ( (ita.inventory_type IN ('FG','RM') AND ita.commodity_code IN ('LA','TA')) OR rpi.item_type='RP' ) THEN 'RP' ELSE 'OTHERS' END AS 'item_type' --1.1
FROM t_trailer t(NOLOCK)
LEFT JOIN t_trailer_asn trl (NOLOCK) ON t.trailer_id = trl.trailer_id
LEFT JOIN t_asn asn(NOLOCK) ON  trl.asn_id = asn.asn_id
AND asn.equipment_id = t.equipment_id
LEFT OUTER JOIN t_ya_work_q(NOLOCK) on t.trailer_id = t_ya_work_q.trailer_id
 AND t_ya_work_q.status = 'UNASSIGNED' AND t_ya_work_q.type = '52'
LEFT OUTER JOIN
 (SELECT T2.trailer_id ,comments 
      FROM t_trailer_comments(NOLOCK)
      LEFT OUTER JOIN (SELECT trailer_id, maxsequence=max(sequence)  
					   FROM t_trailer_comments(NOLOCK)
					   GROUP BY trailer_id) T2  
        ON t_trailer_comments.trailer_id = T2.trailer_id
        AND t_trailer_comments.sequence = T2.maxsequence ) T3
ON t.trailer_id = T3.trailer_id
JOIN t_asn_detail d(NOLOCK)
ON asn.asn_id = d.asn_id
JOIN t_ya_location l(NOLOCK)
ON t.location_id = l.location_id 
JOIN t_area a(NOLOCK)
ON t.area_id = a.area_id 
JOIN t_po_master p (NOLOCK)  
ON d.customer_po_number = p.po_number  
LEFT JOIN t_item_uom uom (NOLOCK)
ON uom.item_number = d.item_number
and uom.default_receipt_uom = 'YES'   
left join t_item_master itm (nolock)
on d.item_number = itm.item_number 
left join t_item_attributes ita (nolock)
on d.item_number = ita.item_number  
left join #tmp_RP_item_order rpi (nolock) --1.1
on d.item_number = rpi.item_number		  --1.1  
WHERE location_name LIKE @in_locationname    
AND a.area_name LIKE @in_areaname
AND t.status LIKE @in_status
AND t.state LIKE @in_state
and isnull(asn.trailer_type_name,'') like @in_trailertypename
and isnull(comments,'') like @in_comments
AND d.item_number LIKE @in_item_id
AND itm.commodity_code LIKE @in_commoditycode
AND isnull(p.vendor_code,'') LIKE @in_vendorcode
AND d.customer_po_number LIKE @in_cust_ponumber
and ((t.state = 'IN FULL' or t.state = 'IN PARTIAL'))
group by t.equipment_id,t.trailer_id,t.status,t.state,t.carrier_id,l.location_name,t.counted,t.entered_yard,t.exited_yard,asn.asn_number,
d.item_number,asn.trailer_type_name,comments,d.customer_po_number,vendor_code,t_ya_work_q.zone,asn.disposition,t_ya_work_q.status, a.area_id,
uom.conversion_factor
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - Do not allow scheduling of equipment in DRAYAGE locations.*/
, l.[type]
/* 01-Feb-2013 LES - PV4952 Whitehall Split from Arcadia - End of change.*/ 
,ita.inventory_type,ita.commodity_code,rpi.item_type --1.1
ORDER BY t.entered_yard
END

--1.1 STARTS
IF @in_itemtype = 'RP'
	select * from #result_items  where equipment_id in 
	(select equipment_id from  #result_items where Item_Type ='RP')
ELSE
	select * from #result_items
--1.1 ENDS 
  
END 

