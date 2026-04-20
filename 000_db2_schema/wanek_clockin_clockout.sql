

SELECT t1.EHEMP AS EMPLOYEE_ID,
    t2.EMRNAM as EMPLOYEE_NAME,
    0 as HOURS_WORKED,
    t1.EHSHFT as shift,
    t1.EHHDPT as department,
    t1.EHSTRT as Actual_Start_Time,
    t1.EHSTOP as Actual_Stop_Time,
    t1.EHDATE as transaction_date,
    t1.EHPLNT as Employee_facility_Number,
    t1.EHGRP as Employee_Group
FROM WWDCF.HDMECH T1
JOIN WWDCF.EMMSTR T2 
  ON T1.EHEMP = T2.EMEMPL  
WHERE T1.EHDATE BETWEEN ? AND ?  
order by  t1.EHDATE desc, t1.EHGRP,  t1.EHEMP

UNION ALL

SELECT t1.LBEMP AS EMPLOYEE_ID,
    t2.EMRNAM as EMPLOYEE_NAME,
    t1.LBPHRS as HOURS_WORKED,
    t1.LBSHFT as shift,
    t1.LBDEPT as department,
    t1.LBASTR as Actual_Start_Time,
    t1.LBASTP as Actual_Stop_Time,
    t1.LBDATE as transaction_date,
    t1.LBFAC as Employee_facility_Number,
    t1.LBGRP as Employee_Group
FROM WWDCF.PYREXPH T1
JOIN WWDCF.EMMSTR T2 
  ON T1.LBEMP = T2.EMEMPL  
WHERE T1.LBDATE BETWEEN ? AND ?  
order by  t1.LBDATE desc, t1.LBGRP,  t1.LBEMP
