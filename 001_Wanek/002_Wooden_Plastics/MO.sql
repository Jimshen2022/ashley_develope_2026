SELECT 
    t1.FITWH, 
    t1.ORDNO, 
    t1.CRDT, 
    t1.FITEM, 
    t1.JOBNO 
FROM 
    AMFLIBW.ITMRVAL0 t
    INNER JOIN AMFLIBW.MOMAST t1 
        ON t.ITNOAD = t1.FITEM 
        AND t1.FITWH = t.STIDAD
WHERE 
    t1.OSTAT NOT IN ('99')
    AND SUBSTR(t1.ORDNO, 1, 2) IN ('MX', 'MY', 'MU', 'MM')
    AND SUBSTR(t1.JOBNO, 12, 1) NOT IN ('O', 'R')
    --AND (t1.ORQTY + t1.QTDEV - t1.QTYRC) <> 0
    AND t.ITCLAD <> 'PHA'
    AND t.ITYPAD IN ('1')


union all

SELECT 
    t1.FITWH, 
    t1.ORDNO, 
    t1.CRDT, 
    t1.FITEM, 
    t1.JOBNO 
FROM AMFLIBW.MOHMST t1 
WHERE DATE('20' || SUBSTR(CHAR(t1.CRDT), 2, 2) || '-' || 
           SUBSTR(CHAR(t1.CRDT), 4, 2) || '-' || 
           SUBSTR(CHAR(t1.CRDT), 6, 2)) 
      >= CURRENT DATE - 90 DAYS 

    