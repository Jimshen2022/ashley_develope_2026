SELECT t1.CDA3CD as WH,t1.CDCVNB as CO#,t1.CDAITX as itemNUMBER,t1.CDD0NB as ETD,t1.CDB9CD as Destination,t1.CDAGNV as Totalopenquantity,t1.CDGLCD as ItemClass,t1.CDALTX as Description,t1.CDAMDT as ChangeDate,t1.CDZ901 as TotalShippedQty,t1.CDAF78 as TotalReleasedQty,t1.CDFNST as Status,t2.SKUs

FROM AMFLIBL.MBCDRESM t1, (SELECT t1.CDCVNB, count(t1.CDAITX) as SKUs  FROM AMFLIBL.MBCDRESM t1 WHERE t1.CDAGNV >0  and t1.CDA3CD in ('51') and t1.CDB9CD  in ('C','CNW','DS00009','TI00002') group by T1.CDCVNB) as t2
WHERE t1.CDAGNV >0 and  t1.CDA3CD in ('51') and t1.CDB9CD  in ('C','CNW','DS00009','TI00002') and t1.CDCVNB = t2.CDCVNB

Order BY t1.CDD0NB,t1.CDB9CD,t1.CDCVNB