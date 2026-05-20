

with itm as 
(SELECT T1.ITNBR,T1.ITCLS, T1.UNMSR, T1.WEGHT, T1.B2Z95S as Unit_Cube, T1.ITDSC, T2.PRDDDES, T3.PICKPUT,
CASE 
    WHEN T1.ITCLS NOT LIKE 'Z%' THEN 'RP' 
    WHEN T3.PICKPUT = 'UPH' THEN 'UPH'
    WHEN T3.PICKPUT = 'PALLT' THEN 'CG'
    ELSE 'Check' END as Product
FROM MasterData_ItemMaster_AFI.ITMRVA AS T1
JOIN MasterData_ItemMaster_AFI.ITMEXT AS T2 ON T1.ITNBR = T2.ITNBR
JOIN MasterData_ItemMaster_AFI.ITBEXT AS T3 ON T1.ITNBR = T3.ITNBR AND T3.HOUSE = T1.STID
WHERE T1.STID IN ('335') 
),
asn_cte as (
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
WHERE t.asn_id = '1320619' 
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