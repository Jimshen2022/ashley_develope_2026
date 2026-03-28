select  *
from Manufacturing_Maximo.PoLine as p
WHERE p.siteid = 'VNM.ASPM'
    and p.itemnum in ('112-6139','1002-2011','202-0719','999-1003','1000-3029','1000-3032')