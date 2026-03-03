-- get vendor shipped by Koha
select  *
from [SupplyChain_Enh].[PSWWeeklyExtractSnapshot] as t1
WHERE t1.whse = '335'
  --and t1.Sqty > 0
  and t1.Item = '1700338'
  and t1.SPRunDate = (select max(SPRunDate) from [SupplyChain_Enh].[PSWWeeklyExtractSnapshot])