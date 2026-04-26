# -*- coding UTF-8 -*-
import pyodbc
import numpy as np
import pandas as pd

cnxn = pyodbc.connect('DSN=MILPROD3; PWD=MJ2065')
cursor = cnxn.cursor()
cursor.execute("""
SELECT *
FROM  AMFLIBL.ITMRVA  a
limit 10
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
# data.to_excel(r'd:\Python_file\MIL_UNKITS_MO.xlsx', index=False)
cnxn.close()
