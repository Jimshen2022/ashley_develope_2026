# -*- coding UTF-8 -*-
import pyodbc
import numpy as np
import pandas as pd

cnxn = pyodbc.connect('DSN=MILPROD3; PWD=MJ2065')
cursor = cnxn.cursor()
cursor.execute("""
        SELECT A.FITWH, A.REFNO, A.ORDNO, A.FITEM, A.FDESC, 
        A.ORQTY + A.QTDEV -A.QTYRC as MQTY,A.QTYRC, 
        Date(Substr(Char(A.ODUDT+ 19000000), 1, 4) || '-'||  Substr(Char(A.ODUDT + 19000000), 5, 2)|| '-' ||substr(Char(A.ODUDT + 19000000), 7, 2)) AS FG_DUE,
        A.OSTAT, A.JOBNO, A.ITCL 
        FROM AMFLIBL.MOMAST A 
        WHERE (A.FITWH='51') AND (substr(A.ORDNO,1,2)='MA') 
        AND (SUBSTR(A.JOBNO, 12, 1) NOT IN ('O','S','P')) 
        AND (A.OSTAT Not In ('99','45','55')) AND (A.ORQTY + A.QTDEV -A.QTYRC <>0)
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
data.to_excel(r'd:\Python_file\MIL_UNKITS_MO.xlsx', index=False)
cnxn.close()
