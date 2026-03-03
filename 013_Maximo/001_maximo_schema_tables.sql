/***
schema.file
Manufacturing_Maximo.a_serviceaddress
Manufacturing_Maximo.alndomain
Manufacturing_Maximo.asset
Manufacturing_Maximo.AssetAttribute
Manufacturing_Maximo.Assetlocusercust
Manufacturing_Maximo.AssetMeter
Manufacturing_Maximo.AssetSpec
Manufacturing_Maximo.Assignment
Manufacturing_Maximo.classstructure
Manufacturing_Maximo.Commodities
Manufacturing_Maximo.companies
Manufacturing_Maximo.Contract
Manufacturing_Maximo.Contractline
Manufacturing_Maximo.Contractmaster
Manufacturing_Maximo.FailureRemark
Manufacturing_Maximo.FailureReport
Manufacturing_Maximo.GlComponents
Manufacturing_Maximo.invbalances
Manufacturing_Maximo.invcost
Manufacturing_Maximo.inventory
Manufacturing_Maximo.Invlot
Manufacturing_Maximo.Invoicecost
Manufacturing_Maximo.Invoiceline
Manufacturing_Maximo.Invreserve
Manufacturing_Maximo.Invtrans
Manufacturing_Maximo.Invuseline
Manufacturing_Maximo.InvVendor
Manufacturing_Maximo.item
Manufacturing_Maximo.Itemorginfo
Manufacturing_Maximo.Jobitem
Manufacturing_Maximo.Joblabor
Manufacturing_Maximo.Jobplan
Manufacturing_Maximo.Jobtask
Manufacturing_Maximo.labor
Manufacturing_Maximo.LaborData
Manufacturing_Maximo.labtrans
Manufacturing_Maximo.Locations
Manufacturing_Maximo.Lochierarchy
Manufacturing_Maximo.MachineMaintenance
Manufacturing_Maximo.MachineOperatorPM
Manufacturing_Maximo.MachinePIVComplianceMetric
Manufacturing_Maximo.MachinePIVDTperCAMetric
Manufacturing_Maximo.MachinePIVReactiveCorrective
Manufacturing_Maximo.MachinePIVTargetStartMetric
Manufacturing_Maximo.Masterpm
Manufacturing_Maximo.Matrectrans
Manufacturing_Maximo.MatUseTrans
Manufacturing_Maximo.meterreading
Manufacturing_Maximo.numericdomain
Manufacturing_Maximo.organization
Manufacturing_Maximo.person
Manufacturing_Maximo.Phone
Manufacturing_Maximo.Plusgincevent
Manufacturing_Maximo.Plusgincperson
Manufacturing_Maximo.Plusginevent
Manufacturing_Maximo.Plusginjorill
Manufacturing_Maximo.Plusgoutcome
Manufacturing_Maximo.plustassetalias
Manufacturing_Maximo.Plustassetsthist
Manufacturing_Maximo.Plustcomp
Manufacturing_Maximo.Plustitemwarr
Manufacturing_Maximo.Plustpos
Manufacturing_Maximo.Plustwoasset
Manufacturing_Maximo.Plustwpserv
Manufacturing_Maximo.Pm
Manufacturing_Maximo.PmMeter
Manufacturing_Maximo.Po
Manufacturing_Maximo.Poline
Manufacturing_Maximo.serviceaddress
Manufacturing_Maximo.Servrectrans
Manufacturing_Maximo.site
Manufacturing_Maximo.Synonymdomain
Manufacturing_Maximo.Ticket
Manufacturing_Maximo.Warrantyline
Manufacturing_Maximo.WorkOrder
Manufacturing_Maximo.WPitem
Manufacturing_Maximo.WPlabor

Manufacturing_Maximo.vnprline
Manufacturing_Maximo.vnpr


select top 10 * from dw_developer.tabledictionary where tpktablename like '%WorkOrder%'
select top 10 * from dw_developer.tabledictionary where tpkSchemaName like '%Manufacturing_Maximo%'
select top 10 * from dw_developer.tabledictionary where tpktablename like '%invbalances%'
select top 10 * from dw_developer.tabledictionary where tpktablename like '%PR%'
Manufacturing_Maximo
***//



select TOP 10 *	FROM Manufacturing_Maximo.vnprline AS t WHERE t.siteid = 'VNM.ASPM'
select TOP 10 *	FROM Manufacturing_Maximo.vnpr AS t WHERE t.siteid = 'VNM.ASPM'

select TOP 10 *	FROM  Manufacturing_Maximo.Invtrans as t 

select Transtype, Enterby, Month(Transdate) as trx_Month, sum(Quantity) as total_quantity
from  Manufacturing_Maximo.Invtrans as t 
where t.Storeloc = 'MROSTORE' 
	and t.Transdate >= '2025-01-01'  
	and enterby in ('KAYTRUONG','THIMAI')
group by Transtype,Enterby, Month(Transdate)
order by trx_Month desc

select *
from  Manufacturing_Maximo.Invtrans as t 
where t.Storeloc = 'MROSTORE' 
	and t.Transdate >= '2025-01-01'  
	and enterby in ('KAYTRUONG','THIMAI')



select TOP 10 *	FROM  Manufacturing_Maximo.Po as t WHERE t.siteid = 'VNM.ASPM' 
select *	FROM  Manufacturing_Maximo.Invtrans as t WHERE t.Siteid = 'VNM.ASPM' ORDER BY t.Transdate desc
select TOP 10 *	FROM Manufacturing_Maximo.labtrans  as t WHERE t.Siteid = 'VNM.ASPM' ORDER BY t.Transdate desc
select TOP 1000 *	FROM Manufacturing_Maximo.Matrectrans as t WHERE t.Siteid = 'VNM.ASPM' ORDER BY t.Transdate desc  -- transfer
select TOP 1000 *	FROM Manufacturing_Maximo.MatUseTrans as t WHERE t.Siteid = 'VNM.ASPM' ORDER BY t.Transdate desc   -- issue and return 
select TOP 10 *	FROM Manufacturing_Maximo.Servrectrans
select TOP 10 *	FROM PowerBI_ADSMaximo.FiscalTransactionCalendar
select TOP 10 *	FROM PowerBI_ADSMaximo.Labtrans
select TOP 10 *	FROM PowerBI_ADSMaximo.Matrectrans
select TOP 10 *	FROM PowerBI_ADSMaximo.Matusetrans
select TOP 10 *	FROM PowerBI_ADSMaximo.SERVRECTRANS


select TOP 10 *	FROM Manufacturing_Maximo.Invtrans as t where t.Siteid = 'VNM.ASPM'
	--select TOP 10 * from Manufacturing_Maximo.item t where t.itemsetid = 'VNMSET'

select TOP 10 *	FROM Manufacturing_Maximo.invbalances AS t1
select TOP 10 *	FROM Manufacturing_Maximo.item AS t0 
select TOP 10 *	FROM  Manufacturing_Maximo.Commodities as t where t.itemsetid= 'VNMSET'
select * FROM Manufacturing_Maximo.invcost as t where t.siteid = 'VNM.ASPM' and t.location = 'MROSTORE'
select TOP 10 *	FROM  Manufacturing_Maximo.Invoicecost  as t 
select distinct t.siteid 	FROM Manufacturing_Maximo.Invoicecost  as t where t.siteid = 'VNM.ASPM'

select TOP 10 *	FROM Manufacturing_Maximo.Invlot
select TOP 10 *	FROM Manufacturing_Maximo.Invoicecost
select TOP 10 *	FROM Manufacturing_Maximo.Invoiceline
select TOP 10 *	FROM Manufacturing_Maximo.Invreserve

select TOP 10 *	FROM Manufacturing_Maximo.Invuseline
select TOP 10 *	FROM Manufacturing_Maximo.InvVendor


select TOP 10 *	FROM  PowerBI_Maximo.MachineMaintenanceReport
select TOP 10 *	FROM PowerBI_Maximo.WarehouseMaster

select *	FROM Maximo_Enh.WorkOrderDetails as t where t.wodsite = 'VNM.ASPM'

select distinct wodsite	FROM Maximo_Enh.WorkOrderDetails


select  * from  Manufacturing_Maximo.WorkOrder as t where t.siteid = 'VNM.ASPM' and t.woclass = 'WORKORDER'  order by t.reportdate desc



select  distinct t.siteid from  Manufacturing_Maximo.WorkOrder as t where t.siteid = 'VNM.ASPM'  AND t.reportdate > '2025-01-01' order by t.reportdate desc







select  * from Maximo_Enh.WorkOrderDetails as t where t.wodsite = 'VNM.ASPM' 

select top 10 * from Maximo_DW.DimMROWorkOrderDetails as t where t.[Site ID]= 'VNM.ASPM'  order by t.[Report Date] desc
order by t.wodActualStartDate DESC

select TOP 10 * from  PowerBI_ADSMaximo.PO

select TOP 10 * from PowerBI_Maximo.Commodities

select * from Manufacturing_Maximo.Commodities as t where t.itemsetid= 'VNMSET'


select TOP 10 * from Maximo_DW.DimDateFile
select TOP 10 * from Maximo_DW.DimMROAssetDetails
select TOP 10 * from Maximo_DW.DimMROCommoditiesDetails
select TOP 10 * from Maximo_DW.DimMROExpenseAnalysisDetails
select TOP 10 * from Maximo_DW.DimMROItemDetails
select TOP 10 * from Maximo_DW.DimMROOrganizationDetails
select TOP 10 * from Maximo_DW.DimMROPersonDetails
select TOP 10 * from Maximo_DW.DimMROPurchaseOrderDetails
select TOP 10 * from Maximo_DW.DimMROSiteDetails
select TOP 10 * from Maximo_DW.DimMROVendorDetails
select TOP 10 * from Maximo_DW.DimMROWorkcenter
select TOP 10 * from Maximo_DW.DimMROWorkOrderDetails
select TOP 10 * from Maximo_DW.FactMROExpenseAnalysis
select TOP 10 * from Maximo_DW.FactMROHistorical
select TOP 10 * from Maximo_DW.FactMROItem
select TOP 10 * from Maximo_DW.FactMROPurchaseOrder
select TOP 10 * from Maximo_DW.FactMROWorkOrder

select TOP 10 * from Maximo_DW.FactMROHistorical

select TOP 10 * from Manufacturing_Maximo.item t where t.itemsetid = 'VNMSET'


select top 10 *  from Manufacturing_Maximo.Invtrans  as t where t.itemnum = '1003-2139'
select top 10 *  from  Manufacturing_Maximo.Matrectrans as t where t.itemnum = '1003-2139'


select top 10 *  from Manufacturing_Maximo.Invoiceline as t where t.itemnum = '1003-2139'
select top 10 *  from Manufacturing_Maximo.invcost as t where t.itemnum = '1003-2139'


select top 10 *  from  Manufacturing_Maximo.Po
select top 10 *  from Manufacturing_Maximo.Poline as t where t.itemnum = '1003-2139'


select  *  from  Manufacturing_Maximo.WorkOrder t 
where t.siteid = 'VNM.ASPM' 
	and t.woclass = 'WORKORDER'
	--and t.wonum = '511456'
ORDER BY t.reportdate desc 


SELECT  
	t.status, 
	YEAR(t.reportdate) AS report_year,
	--MONTH(t.reportdate) AS report_month,
	COUNT(DISTINCT t.wonum) AS wonum_qty
FROM  
	Manufacturing_Maximo.WorkOrder t 
WHERE  
	t.siteid = 'VNM.ASPM' 
	AND t.woclass = 'WORKORDER'
	--AND t.wonum = '511456'
GROUP BY  
	t.status, 
	YEAR(t.reportdate)
	--, MONTH(t.reportdate)
ORDER BY  
	t.status, 
	YEAR(t.reportdate)
	--, MONTH(t.reportdate)


SELECT 
	status,
	report_year,
	ISNULL([1], 0) AS Jan,
	ISNULL([2], 0) AS Feb,
	ISNULL([3], 0) AS Mar,
	ISNULL([4], 0) AS Apr,
	ISNULL([5], 0) AS May,
	ISNULL([6], 0) AS Jun,
	ISNULL([7], 0) AS Jul,
	ISNULL([8], 0) AS Aug,
	ISNULL([9], 0) AS Sep,
	ISNULL([10], 0) AS Oct,
	ISNULL([11], 0) AS Nov,
	ISNULL([12], 0) AS Dec
FROM (
	SELECT 
		t.status,
		YEAR(t.reportdate) AS report_year,
		MONTH(t.reportdate) AS report_month,
		t.wonum
	FROM Manufacturing_Maximo.WorkOrder t
	WHERE 
		t.siteid = 'VNM.ASPM'
		AND t.woclass = 'WORKORDER'
) AS source
PIVOT (
	COUNT(DISTINCT wonum)
	FOR report_month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS pivot_table
ORDER BY status, report_year;


select top 100 *  from  Maximo_Enh.WorkOrderDetails as t where t.wodsite = 'VNM.ASPM' 

SELECT 
    t.wodOriginalStatus, 
    t.wodStatus, 
    COUNT(DISTINCT [t].[wodWO#]) AS wodWO_Count
FROM 
    Maximo_Enh.WorkOrderDetails AS t
WHERE 
    t.wodsite = 'VNM.ASPM'
GROUP BY 
    t.wodOriginalStatus, 
    t.wodStatus;


select top 10 *  from  Manufacturing_Maximo.Invtrans as t where t.Storeloc = 'MROSTORE' and t.Transdate > '2025-01-01'  order by t.Transdate desc


select top 10 * from Manufacturing_Maximo.labtrans
select *  from Manufacturing_Maximo.Matrectrans where tostoreloc = 'MROSTORE' and itemsetid ='VNMSET' AND siteid LIKE 'VNM.ASPM%'
select top 10 *  from Manufacturing_Maximo.MatUseTrans
select top 10 *  from Manufacturing_Maximo.Servrectrans


select  * from  Manufacturing_Maximo.inventory
where siteid = 'VNM.ASPM';


WITH LatestSnapshot AS (
    SELECT MAX(SnapshotDate) AS SnapshotDate 
    FROM Manufacturing_Maximo.inventory 
where siteid = 'VNM.ASPM'
)
select t.itemnum, 
	sum(t.orderqty) as orderqty,
	sum(t.issueytd) as issued_ytd
from  Manufacturing_Maximo.inventory as t
join LatestSnapshot as t2 on t.SnapshotDate = t2.SnapshotDate
where t.siteid = 'VNM.ASPM'
group by t.itemnum





select *,  CAST(transdate AS DATE) AS transaction_date
from Manufacturing_Maximo.MatUseTrans
where siteid = 'VNM.ASPM' 
	and storeloc = 'MROSTORE'
	and transdate >= '2025-03-11'
order by transdate DESC




select  TOP 10 * from Manufacturing_Maximo.invcost


select  distinct t.itemsetid  from Manufacturing_Maximo.item as t
select  * from Manufacturing_Maximo.item as t  ORDER BY t.itemnum

select  DISTINCT T.itemsetid from Manufacturing_Maximo.item as t  WHERE t.itemsetid = 'VNMSET'

WHERE t.itemnum in ('1100-0067','1100-2946','1100-2817','1100-2851')

select top 10 * from Manufacturing_Maximo.inventory as t
where t.modelnum like '001-0999%'


select top 10 * from Manufacturing_Maximo.item





-- transaction:
select issuetype, sum(quantity) as trx_quantity
from Manufacturing_Maximo.MatUseTrans 
WHERE siteid = 'VNM.ASPM' 
group by issuetype


select top 10 * from Manufacturing_Maximo.MatUseTrans as t  WHERE t.siteid = 'VNM.ASPM' order by t.transdate desc


select top 100 * from Manufacturing_Maximo.Po as t
where t.itemsetid = 'VNMSET'


where ponum in ('PF000740','PF000733')






select * from  Manufacturing_Maximo.item WHERE itemsetid = 'VNMSET'

select top 10 * from Manufacturing_Maximo.Locations



select top 10 * from Manufacturing_Maximo.Poline




-- Inventory on hand cretaed by Jim,Shen on Mar.27.2025
WITH LatestSnapshot AS (
    SELECT MAX(SnapshotDate) AS SnapshotDate 
    FROM Manufacturing_Maximo.invbalances 
    WHERE location = 'MROSTORE'
)
SELECT t1.itemnum,
	t1.location,
	t1.binnum,
	t1.curbal as onhand,
	t1.orgid,
	t1.siteid,
	t1.itemsetid,
	DATEADD(HOUR, 12, t1.SnapshotDate) AS SnapshotDate
FROM Manufacturing_Maximo.invbalances AS t1
JOIN LatestSnapshot ls 
    ON t1.SnapshotDate = ls.SnapshotDate
WHERE t1.location LIKE 'MROSTORE%'
    AND t1.curbal > 0
    AND t1.siteid = 'VNM.ASPM';



	



---------------------------------------------------------------------------------
-- updated at 2025-03-26 23:13:34.000
select max(t.SnapshotDate) as SnapshotDate from Manufacturing_Maximo.invbalances as t where t.location = 'MROSTORE' 

select t.SnapshotDate from Manufacturing_Maximo.invbalances as t where t.location = 'MROSTORE' group by t.SnapshotDate ORDER BY t.SnapshotDate desc

select top 10 * from Manufacturing_Maximo.invbalances as t1 where t1.location like 'MROSTORE%'



select  * from Manufacturing_Maximo.invbalances as t1
where t1.location like 'MROSTORE%'
and t1.SnapshotDate in (select max(t.SnapshotDate) as SnapshotDate from Manufacturing_Maximo.invbalances as t where t.location = 'MROSTORE')
and t1.curbal>0
and t1.siteid = 'VNM.ASPM'








select  TOP 10 * from Manufacturing_Maximo.invcost


select  distinct t.itemsetid  from Manufacturing_Maximo.item as t
select  * from Manufacturing_Maximo.item as t  ORDER BY t.itemnum

select  DISTINCT T.itemsetid from Manufacturing_Maximo.item as t  WHERE t.itemsetid = 'VNMSET'

WHERE t.itemnum in ('1100-0067','1100-2946','1100-2817','1100-2851')

select top 10 * from Manufacturing_Maximo.inventory as t
where t.modelnum like '001-0999%'


select top 10 * from Manufacturing_Maximo.item





-- transaction:
select top 10 * from Manufacturing_Maximo.MatUseTrans as t  WHERE t.siteid = 'VNM.ASPM' order by t.transdate desc

