# -*- coding UTF-8 -*-
import pyodbc
import pandas as pd
import os
import time

# 记录开始时间
start_time = time.time()

# 建立数据库连接
cnxn = pyodbc.connect('DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2079')
cursor = cnxn.cursor()

# 执行SQL查询
query = """
Select SYSTEM_TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, varchar(COLUMN_TEXT, 50) As COLUMN_DESC 
From QSYS2.SYSCOLUMNS
--Where SYSTEM_TABLE_SCHEMA in ('AMFLIBL','AFILELIBL','LLUSAF','DISTLIBL','LLUSAF','ASHLEYARCL','RGNFILL') 

"""
cursor.execute(query)

# 获取列名
columns = [column[0] for column in cursor.description]

# 将SQL结果直接加载到DataFrame中
data = pd.DataFrame.from_records(cursor.fetchall(), columns=columns)

# 关闭数据库连接
cnxn.close()

# 将数据导出到当前目录下的CSV文件
data.to_csv(r'C:\Users\jishen\Downloads\MIL_SCHEMA.csv', index=False, encoding='utf-8-sig')

# 打印结果到窗口
print(data)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")