import pyodbc
import pandas as pd

# 连接数据库
cnxn = pyodbc.connect('DSN=AFIPROD; PWD=MJ2079')

# 执行查询
query = """
    SELECT T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T1.WHSLC, T1.QTSYR, T2.ITDSC 
    FROM AMFLIBA.ITEMBL T1, AMFLIBA.ITMRVA T2, AMFLIBA.WHSMST T3 
    WHERE T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR AND T2.STID = T3.STID 
      AND T1.HOUSE = T3.WHID AND T1.HOUSE='335' AND T1.MOHTQ<>0
    """

# 使用 pandas 读取数据
df = pd.read_sql(query, cnxn)

# 显示查询结果
print(df)

# 保存到当前目录的 Excel 文件
df.to_excel('whse335onhand.xlsx', index=False, engine='openpyxl')

# 关闭连接
cnxn.close()
