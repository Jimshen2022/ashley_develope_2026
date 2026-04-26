# -*- coding UTF-8 -*-
import pyodbc
import numpy as np
import pandas as pd

cnxn = pyodbc.connect('DSN=MILPROD3; PWD=MJ2065')
cursor = cnxn.cursor()
cursor.execute("""
Select 
x1.WCHDOORNUMBER,x1.WCHCONTAINERNUMBER,x1.WCHORIGIN,x1.WCHDESTINATION,x1.WCHCONTAINERSTATUS,x1.WCHTOTALCARTONS,x1.WCHTOTALCUBES,x1.WCHPOSTEDTIMESTAMP,x1.WCHTOTALWEIGHT,x1.WCHCONTAINERSIZE,x1.Container#,to_char(x1.WCHPOSTEDTIMESTAMP,'yyyy-mm-dd') as Date, x1.WCHPOSTEDTIMESTAMP, x1.WCHPOSTEDUSER,
(case 
when substr(x1.WCHCONTAINERSIZE,1,1) = '4' then x1.WCHTOTALCUBES/2650
when substr(x1.WCHCONTAINERSIZE,1,1) = '2' then x1.WCHTOTALCUBES/1325
ELSE x1.WCHTOTALCUBES/2650 END) AS Utilization,
(CASE 
         WHEN CONTAINER# LIKE ('51%') THEN 'MIL'
         WHEN CONTAINER# LIKE ('33%') THEN 'WN2'
         WHEN  CONTAINER# LIKE ('35%') and TRIM(WCHDOORNUMBER) LIKE ('4%') THEN 'WN3'
         WHEN  CONTAINER# LIKE ('35%') and TRIM(WCHDOORNUMBER) LIKE ('9%') THEN 'BW'
         WHEN  CONTAINER# LIKE ('35%') and TRIM(WCHDOORNUMBER) LIKE ('8%') THEN 'DC'
         WHEN  CONTAINER# LIKE ('35%') and CONTAINER# LIKE ('%-335%') and TRIM(WCHDOORNUMBER) LIKE ('0%') THEN 'DC'
         WHEN  CONTAINER# LIKE ('35%') and CONTAINER# LIKE ('%-CNW%') and TRIM(WCHDOORNUMBER) LIKE ('0%') THEN 'DC'
         WHEN  CONTAINER# LIKE ('35%') and CONTAINER# LIKE ('%-C') and TRIM(WCHDOORNUMBER) LIKE ('0%') THEN 'DC'
         WHEN  CONTAINER# LIKE ('35%') and CONTAINER# NOT LIKE ('%-335%') and TRIM(WCHDOORNUMBER) LIKE ('0%') THEN 'WN3'
         WHEN  CONTAINER# LIKE ('35%') and CONTAINER# NOT LIKE ('%-CNW%') and TRIM(WCHDOORNUMBER) LIKE ('0%') THEN 'WN3'
         WHEN  CONTAINER# LIKE ('35%') and CONTAINER# NOT LIKE ('%-C') and TRIM(WCHDOORNUMBER) LIKE ('0%') THEN 'WN3'
 ELSE 'WN3' END) as Site

FROM

(SELECT 
a.WCHDOORNUMBER,a.WCHCONTAINERNUMBER,a.WCHORIGIN,a.WCHDESTINATION,a.WCHCONTAINERSTATUS,a.WCHTOTALCARTONS,a.WCHTOTALCUBES,a.WCHPOSTEDTIMESTAMP,a.WCHTOTALWEIGHT,a.WCHPOSTEDUSER,a.WCHCONTAINERSIZE,
trim(a.WCHORIGIN)||'-'|| trim(a.WCHCONTAINERNUMBER)||'-'||trim(a.WCHDESTINATION) as Container#
FROM  LLUSAF.WVCNTHD a
WHERE a.WCHCONTAINERSTATUS in ('P','T') AND a.WCHORIGIN IN ('51')  AND a.WCHPOSTEDTIMESTAMP BETWEEN char(current date - 14 days) and char(current DATE) 
and substr(trim(a.WCHCONTAINERNUMBER),1,4) NOT IN ('AAAR','AIIR','AAIR','AIRR','AIR_','AIR1','AAII','ARRR')

union all

SELECT  a.WCHDOORNUMBER,a.WCHCONTAINERNUMBER,a.WCHORIGIN,a.WCHDESTINATION,a.WCHCONTAINERSTATUS,a.WCHTOTALCARTONS,a.WCHTOTALCUBES,a.WCHPOSTEDTIMESTAMP,a.WCHTOTALWEIGHT,a.WCHPOSTEDUSER,a.WCHCONTAINERSIZE,
(CASE 
        When a.WCHDESTINATION in ('335','CNW') then trim(a.WCHORIGIN)||'-'|| trim(a.WCHCONTAINERNUMBER)||'-'||trim(a.WCHDESTINATION)||'-'||to_char(a.WCHPOSTEDTIMESTAMP,'yyyy-mm-dd') 
        ELSE trim(a.WCHORIGIN)||'-'|| trim(a.WCHCONTAINERNUMBER)||'-'||trim(a.WCHDESTINATION) END) as Container#
FROM  ASHLEYARCL.WVCNTHDA a
WHERE a.WCHCONTAINERSTATUS in ('P','T') AND a.WCHPOSTEDTIMESTAMP BETWEEN char(current date - 14 days) and char(current DATE)  and a.WCHORIGIN in ('51') and 
substr(trim(a.WCHCONTAINERNUMBER),1,4) NOT IN ('AAAR','AIIR','AAIR','AIRR','AIR_','AIR1','AAII','ARRR')) as x1
""")

# a = cursor.fetchmany(100)

# export columns description
c = list(cursor.description)
y = []
for i in c:
    x = list(i)
    y.append(x[0])

# export values in sql
a = cursor.fetchall()
b = np.array(a)
data = pd.DataFrame(b, columns=y)
# data['ITNBR'] = data['ITNBR'].str.strip()  # 去除ITNBR列的左右空格
# data[['MOHTQ', 'QTSYR']] = data[['MOHTQ', 'QTSYR']].apply(pd.to_numeric)  # successful 转为数字格式
data.to_excel(r'd:\Python_file\MIL_ContainerUtilization_Head.xlsx', index=False)
cnxn.close()
