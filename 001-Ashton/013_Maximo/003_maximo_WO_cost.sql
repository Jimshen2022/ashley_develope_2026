select 
	t.wonum,
	t.parent,
	t.status,
	t.worktype,
	t.description,
	t.assetnum,
	t.location,
	t.reportdate,
	t.glaccount,
	t.siteid,
	t.wogroup,
	t.actfinish,
	t.actstart,
	t.pmduedate,
	t.jpnum,
	t.changeby,
	t.pmnum,
	t.actlabhrs,
	t.actmatcost,
	t.actlabcost,
	t.acttoolcost,
	t.woeq1,
	t.reportedby,
	t.owner
from  Manufacturing_Maximo.WorkOrder as t 
where t.siteid = 'VNM.ASPM' 
	and t.woclass = 'WORKORDER'  
	and t.status = 'CLOSE'
	and t.reportdate >= '2025-01-01'
	and t.assetnum like 'V%'
order by t.reportdate desc

