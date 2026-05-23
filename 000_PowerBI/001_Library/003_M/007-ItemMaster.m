let
    Source = Odbc.Query("dsn=AFIPROD", 
    " SELECT Distinct t1.ITNBR, t1.ITCLS
    FROM AMFLIBA.ITMRVA AS t1 WHERE t1.STID IN ('335') LIMIT 5")
in
    Source