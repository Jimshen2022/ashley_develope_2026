
select a.itnbr, a.itcls,a.B2Z95S, b.pickput,b.ITMCLSID 
from MasterData_ItemMaster_AFI.ITMRVA as a
left join (SELECT * FROM MasterData_ItemMaster_AFI.ITBEXT  WHERE HOUSE = '335')as b on b.itnbr = a.itnbr and a.stid = b.house
where a.stid = '335' and a.itcls like 'Z%' and a.itcls not like 'Z%K'
order by a.itnbr