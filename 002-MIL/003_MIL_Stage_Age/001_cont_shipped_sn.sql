select top 10 * from  Manufacturing_ProductionPlanning_MIL.WVCNTSDA order by WCSADDEDTIMESTAMP DESC
select top 10 * from  Manufacturing_ProductionPlanning_MIL.WVCNTSD order by WCSADDEDTIMESTAMP DESC

select top 10 * from Manufacturing_ProductionPlanning_MIL.WVCNTHD
select top 10 * from Manufacturing_ProductionPlanning_MIL.WVCNTHDA

WITH ctns AS (
    SELECT DISTINCT a.WCHCONTAINERNUMBER
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD a
    WHERE a.WCHCONTAINERSTATUS IN ('P','T')
    
    UNION
    
    SELECT DISTINCT a.WCHCONTAINERNUMBER
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA a
),
shipped_sn AS (
    SELECT 
        t.WCSCONTAINERNUMBER,
        t.WCSSERIALNUMBER,
        t.WCSITEMNUMBER,
        t.WCSORDER,
        t.WCSDESTINATION
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTSDA AS t
    WHERE t.WCSADDEDTIMESTAMP >= DATEADD(DAY, -360, GETDATE())
    
    UNION ALL
    
    SELECT 
        t.WCSCONTAINERNUMBER,
        t.WCSSERIALNUMBER,
        t.WCSITEMNUMBER,
        t.WCSORDER,
        t.WCSDESTINATION
    FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD AS t
    WHERE t.WCSADDEDTIMESTAMP >= DATEADD(DAY, -360, GETDATE())
)
SELECT TOP 10 t.WCSSERIALNUMBER
FROM shipped_sn AS t
INNER JOIN ctns AS c ON c.WCHCONTAINERNUMBER = t.WCSCONTAINERNUMBER;
