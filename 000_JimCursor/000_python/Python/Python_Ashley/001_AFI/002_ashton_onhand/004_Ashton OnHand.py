# -*- coding UTF-8 -*-
import pyodbc as po
import numpy as np
import pandas as pd
import os
import time
from datetime import datetime

# 记录开始时间
start_time = time.time()

# 使用上下文管理器来确保连接和游标在使用后关闭
with po.connect('DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2083') as cnxn:
    cursor = cnxn.cursor()
    query = """
        SELECT T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T1.WHSLC, T1.QTSYR, T2.ITDSC 
        FROM AMFLIBA.ITEMBL T1
        JOIN AMFLIBA.ITMRVA T2 ON T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR
        JOIN AMFLIBA.WHSMST T3 ON T2.STID = T3.STID AND T1.HOUSE = T3.WHID 
        WHERE T1.HOUSE='335' AND T1.MOHTQ>0
    """
    cursor.execute(query)

    # 获取列名
    columns = [desc[0] for desc in cursor.description]

    # 从数据库中获取数据并转换为DataFrame
    data = pd.DataFrame.from_records(cursor.fetchall(), columns=columns)

# 去除ITNBR列的左右空格
data['ITNBR'] = data['ITNBR'].str.strip()

# 转为数字格式
data[['MOHTQ', 'QTSYR']] = data[['MOHTQ', 'QTSYR']].apply(pd.to_numeric)

# 获取当前日期时间并格式化为所需的文件名
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
file_name = f'ahston_onhand_{current_time}.xlsx'
file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

# 保存到Excel
data.to_excel(file_path, index=False)

# 打印Excel文件的保存路径
print(f"Excel文件已保存到路径: {file_path}")

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")