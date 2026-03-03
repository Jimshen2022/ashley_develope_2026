SELECT  *  FROM t_import_ASN where transaction_string like '5478704%'
SELECT  *  FROM  t_asn where asn_number = '5478704'
SELECT TOP 10 *  FROM  t_asn 

SELECT  *  FROM  t_asn_detail where asn_id = '1393369'
SELECT TOP 10 *  FROM  t_asn
/* status
NEW
CLOSED
CHECKED IN
*/

SELECT TOP 10 *  FROM  t_asn
SELECT TOP 10 *  FROM  t_asn_detail
SELECT TOP 10  *  FROM  t_trailer  
SELECT TOP 10 *  FROM  t_trailer_asn 
SELECT TOP 10 *  FROM  t_ya_location 

SELECT  DISTINCT status  FROM  t_trailer 
/* status 
IN DOOR
IN YARD CHASSIS
HISTORY
IB SHUTTLE
HOLD
*/
SELECT TOP 10 *  FROM  t_ya_location 



select *  FROM t_tran_log  WHERE tran_type in ('151','951') and hu_id_2 = '5392021'  and start_tran_date > '2025-12-01' order by return_disposition
select *  FROM t_tran_log  WHERE tran_type in ('347') and start_tran_date > '2025-12-20'
select *  FROM t_tran_log  WHERE tran_type in ('951') and start_tran_date > '2025-01-01' order by return_disposition
SELECT *  FROM  t_asn where asn_id = '1320619'
SELECT TOP 10 *  FROM  t_asn_detail where asn_id = '1320619'

with asn_cte as (
SELECT 
    t.asn_id, 
    t.asn_number,
    t.vendor_id, 
    t.total_quantity, 
    t.total_volume,
    t.equipment_id, 
    t.trailer_type_name, 
    t.status, 
    t.sent_101_flag, 
    t.sent_103_flag, 
    t.unload_date_xml_status, 
    t1.sn_coo, 
    SUM(t1.quantity_shipped) as quantity_shipped, 
    SUM(t1.quantity_received) as quantity_received, 
    COUNT(DISTINCT t1.item_number) as SKUs, 
    
    /* 修改部分开始：使用子查询先 DISTINCT 再 STRING_AGG */
    (
        SELECT STRING_AGG(sub_po, ', ') 
        FROM (
            SELECT DISTINCT customer_po_number AS sub_po
            FROM t_asn_detail sub
            WHERE sub.asn_id = t.asn_id 
              AND sub.sn_coo = t1.sn_coo -- 确保只聚合当前分组(ASN+COO)下的PO
        ) distinct_table
    ) as PO_number
    /* 修改部分结束 */

FROM t_asn as t 
JOIN t_asn_detail as t1 ON t.asn_id = t1.asn_id 
--WHERE t.asn_id = '1320619' 
GROUP BY 
    t.asn_id, 
    t.asn_number,
    t.vendor_id, 
    t.total_quantity, 
    t.total_volume,
    t.equipment_id, 
    t.trailer_type_name, 
    t.status, 
    t.sent_101_flag, 
    t.sent_103_flag, 
    t.unload_date_xml_status, 
    t1.sn_coo
)
select  *  
FROM t_tran_log as t2 
left join asn_cte as t3 on t2.control_number_2 = t3.customer_po_number and t2.item_number = t3.item_number and t2.hu_id_2 = t3.asn_number
WHERE t2.tran_type in ('151','951') 
	and t2.start_tran_date > '2025-12-01' 
order by t2.start_tran_date, t2.start_tran_time


