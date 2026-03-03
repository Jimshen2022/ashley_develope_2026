-- PR query
-- 相同 ponum 中 statusdate 最大的那行
with po as (
	SELECT 
    ponum,
    purchaseagent,
    description,
    orderdate,
    requireddate,
    potype,
    po_status,
    statusdate,
    vendor,
    totalcost
FROM (
    SELECT 
        t.ponum,
        t.purchaseagent,
        t.description,
        t.orderdate,
        t.requireddate,
        t.potype,
        t.[status] as po_status,
        t.statusdate,
        t.vendor,
        t.totalcost,
        ROW_NUMBER() OVER (PARTITION BY t.ponum ORDER BY t.statusdate DESC) as rn
    FROM Manufacturing_Maximo.Po as t 
    WHERE siteid = 'VNM.ASPM'
) as ranked
WHERE rn = 1
),
vendor as (
select [Vendor ID],
       [VD Org ID],
       [Vendor Name]
from Maximo_DW.DimMROVendorDetails
)
select t.reqnum as PR_No,
	t.description as PR_Description,
	t.requesteddate as Requested_Date,
	t.requireddate as Required_Date,
	t.category as Category,
    t1.vnprlinenum,
	t1.itemnum as Item_Code,
	t1.description as Item_Desc,
	t1.orderqty as Qty,
	t1.orderunit as UOM,
	t1.wonum as Work_Order,
	t.[status] as PR_Status,
    '' as Pending_to,
	t1.ponum as PO,
    po.po_status,
   -- po.vendor as Vendor_id,
    vendor.[Vendor Name] as Vendor_Name,
    po.orderdate as PO_Order_Date,
    t.requestedby as Requester,
    t1.linecost as pr_line_cost,
    t.totalcost as pr_totalcost,
    po.totalcost as po_totalcost
from Manufacturing_Maximo.vnpr  as t
join Manufacturing_Maximo.vnprline as t1 on t.vnprid = t1.vnprid
left join po on t1.ponum = po.ponum
left join vendor on po.vendor = vendor.[Vendor ID]
where t.siteid = 'VNM.ASPM' and t.status != 'CAN' and t.requesteddate >= '2025-01-01'
order by t.apprdate, t.reqnum, t1.vnprlinenum 