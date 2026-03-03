SELECT top 10  T1.PTLITNBR, SUM(T1.PTLWEEK1) AS 'Safety Stock Target'
    FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1
    WHERE t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335'  AND T1.PTLWEEK1>0 and t1.PTLITNBR='B783-93W9'
    GROUP BY T1.PTLITNBR


SELECT *
    FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1
    WHERE  T1.PTLWHSE = '335' and t1.PTLITNBR='B783-93W9'
