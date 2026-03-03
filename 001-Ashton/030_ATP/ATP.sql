select * from dw_developer.tabledictionary where tpktablename like '%ATP%'


select top 1000 * from SupplyChain_Enh.ATPSUP WHERE ASWAREHOUSE = '335' and ASITEMNUMBER = 'B783-93W9'
 


select top 10 * from  Wholesale_Purchasing_AFI.ATPSUM AS t  where t.APHOUS = '335'
select * from  Wholesale_Purchasing_AFI.ATPSUM AS t  where t.APHOUS = '335' and t.APITNB = 'B5169-196'

select top 10 * from Wholesale_Purchasing_AFI.ATPSUM 
select top 10 * from SupplyChain_Enh.ATPWeekEnding
select top 10 * from Wholesale_Purchasing_AFI.ATPEXT
select top 10 * from Wholesale_SalesHistory_AFI.AtpAdjustAudit
select top 10 * from Wholesale_SalesHistory_AFI.NegativeAtpAdjustAudit

-- ATP QTY CHECK
select * from SupplyChain_Enh.ATPSUP as t where t.ASWAREHOUSE = '335'  AND t.ASITEMNUMBER = 'B799-57' 
	AND t.SnapShotDate in ( select max(t0.SnapShotDate) as SnapShotDate 
							from SupplyChain_Enh.ATPSUP  as t0
							where t0.ASWAREHOUSE = '335' and t0.ASITEMNUMBER = 'B799-57'
							group by t0.ASITEMNUMBER) 
ORDER BY t.ASWEEKDEMDATE Desc