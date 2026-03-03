select *
from [SupplyChain_Enh].[PSWWeeklyExtractSnapshot] as t1
WHERE t1.whse = '335'
  and t1.Sqty > 0
  and t1.SPRunDate = (select max(SPRunDate) from [SupplyChain_Enh].[PSWWeeklyExtractSnapshot])


select  *
from  SupplyChain_Enh.PurchaseOrderSnapshot AS T1
WHERE t1.posWhse = '335' and t1.posPstts IN ('20','30','35')

select *
from  SupplyChain_Enh.POItemInquiryDataSourcing as t1
where t1.podwarehouse = '335' AND t1.phsStatusDescription not in ('Canceled','Receiver','Closed')



select TOP 10 *
from  SupplyChain_Enh.SummaryPOReportSnapshot

select TOP 10 *
from SupplyChain_Enh.PlannedRequirementsLogility