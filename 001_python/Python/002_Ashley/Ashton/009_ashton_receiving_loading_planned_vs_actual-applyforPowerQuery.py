import pyodbc as po
import pandas as pd

# 连接数据库并查询数据
connection_string = 'DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2080'
query = """
SELECT T1.*, VARCHAR(T1.AASER#) AS SN 
FROM (
    SELECT * FROM DISTLIB.ACTAUDT
    WHERE AAADAT BETWEEN 20250101 AND 20250426 
      AND AAFWHS = '335'
      AND AACOD1 = 'BT'
    ORDER BY AAITM#, AAADAT, AAATIM 
    FETCH FIRST 1000 ROWS ONLY
) T1
"""

# 执行查询
cnxn = po.connect(connection_string)
df = pd.read_sql(query, cnxn)
cnxn.close()

# 清洗特定列：AASER#、AAITM#、SN
for col in ['AASER#', 'AAITM#', 'SN']:
    if col in df.columns:
        df[col] = df[col].astype(str).str.replace(r'\..*', '', regex=True).str.strip()

# 返回数据给 Power BI
dataset = df
print(df)
