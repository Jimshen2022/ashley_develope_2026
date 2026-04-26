# -*- coding UTF-8 -*-
import pyodbc
import numpy as np
import pandas as pd

cnxn = pyodbc.connect('DSN=MILPROD; PWD=MJ2080', autocommit=True)
cursor = cnxn.cursor()
cursor.execute("""
SELECT t1.HOUSE,t1.TCODE,t1.ORDNO,TRIM(t1.ITNBR) ITNBR,t2.ITCLS, t1.UPDDT,t1.UPDTM,t1.TRQTY,t1.ENTUM,t1.VNDNR,t1.REFNO,t1.LLOCN,t1.BATCH,t1.TRMID,
CHAR(t1.UPDDT||' '||right('000000'||ltrim(t1.UPDTM),6)) AS "TrxTime"
FROM AMFLIBL.IMHIST  t1, AMFLIBL.ITMRVA t2, AMFLIBL.WHSMST t3
WHERE t1.ITNBR=t2.ITNBR  AND t2.STID = t3.STID AND t1.HOUSE = t3.WHID AND t1.TRQTY > 0 AND t1.TCODE IN ('RP','RM','PQ') AND 
CHAR(t1.UPDDT||' '||right('000000'||ltrim(t1.UPDTM),6)) BETWEEN CHAR('1'||VARCHAR_FORMAT(current date - 2 days,'yymmdd hh24:mi:ss'))  AND CHAR('1'||VARCHAR_FORMAT(current timestamp, 'yymmdd hh24:mi:ss'))
AND t2.ITCLS NOT LIKE 'Z%'
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
data.to_excel(r'd:\Python_file\MIL_RM_Received.xlsx', index=False)
cnxn.close()
