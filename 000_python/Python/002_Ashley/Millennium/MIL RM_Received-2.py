# -*- coding: UTF-8 -*-
import pandas as pd
import pyodbc

# 配置连接字符串（保留现有 DSN 和密码）
conn = pyodbc.connect('DSN=MILPROD;PWD=MJ2080', autocommit=True)

# 构造 SQL 查询
sql = """
SELECT t1.HOUSE,t1.TCODE,t1.ORDNO,TRIM(t1.ITNBR) ITNBR,t2.ITCLS, t1.UPDDT,t1.UPDTM,t1.TRQTY,t1.ENTUM,t1.VNDNR,t1.REFNO,t1.LLOCN,t1.BATCH,t1.TRMID,
CHAR(t1.UPDDT||' '||right('000000'||ltrim(t1.UPDTM),6)) AS "TrxTime"
FROM AMFLIBL.IMHIST  t1, AMFLIBL.ITMRVA t2, AMFLIBL.WHSMST t3
WHERE t1.ITNBR=t2.ITNBR  AND t2.STID = t3.STID AND t1.HOUSE = t3.WHID AND t1.TRQTY > 0 AND t1.TCODE IN ('RP','RM','PQ') AND 
CHAR(t1.UPDDT||' '||right('000000'||ltrim(t1.UPDTM),6)) BETWEEN CHAR('1'||VARCHAR_FORMAT(current date - 2 days,'yymmdd hh24:mi:ss'))  AND CHAR('1'||VARCHAR_FORMAT(current timestamp, 'yymmdd hh24:mi:ss'))
AND t2.ITCLS NOT LIKE 'Z%'
"""

# 使用 pandas 读取 SQL 查询结果为 DataFrame
df = pd.read_sql(sql, conn)

# 推荐写入 CSV 文件（更快）
df.to_csv(r'd:\Python_file\MIL_RM_Received.csv', index=False, encoding='utf-8-sig')

# 如果必须写入 Excel，可以使用这一行（速度略慢）
# df.to_excel(r'd:\Python_file\MIL_RM_Received.xlsx', index=False)

# 关闭数据库连接
conn.close()

print("导出成功！")
