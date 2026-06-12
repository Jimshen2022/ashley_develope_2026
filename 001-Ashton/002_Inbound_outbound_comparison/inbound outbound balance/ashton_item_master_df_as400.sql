select trim(a.itnbr) as itnbr, a.itcls, b.pickput, b.ITMCLSID 
from AMFLIBA.ITMRVA as a
left join (SELECT * FROM AFILELIB.ITBEXT  WHERE HOUSE = '335')as b on b.itnbr = a.itnbr and a.stid = b.house
where a.stid = '335' and a.itcls like 'Z%' and a.itcls not like 'Z%K'
order by a.itnbr