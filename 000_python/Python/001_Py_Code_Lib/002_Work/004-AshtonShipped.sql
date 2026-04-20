import pyodbc
import pandas as pd
from datetime import datetime
# 提供完整的连接字符串
connection_string = (
    'DRIVER={iSeries Access ODBC Driver};'
    'SYSTEM=10.18.18.104;'  # 替换为你的系统名称或IP地址
    'UID=JIMSHEN;'  # 替换为你的用户名
    'PWD=MJ2078;'  # 替换为你的密码
)

# 连接数据库 10.18.18.104
cnxn = pyodbc.connect(connection_string)

# 执行查询
query = """

SELECT *
FROM AFILELIB.CODATAN T1
LIMIT 10

"""

# 使用 pandas 读取数据
df = pd.read_sql(query, cnxn)

# 显示查询结果
print(df)

# # 获取当前日期和时间
# current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
#
# # 生成带日期时间的文件名
# filename = f'AFI_CO_{current_time}.xlsx'

# # 保存到当前目录的 Excel 文件
# df.to_excel(filename, index=False, engine='openpyxl')
# print(f"Data has been successfully saved to '{filename}'.")

# # 保存到当前目录的 Excel 文件
# df.to_excel('AFI_CO.xlsx', index=False, engine='openpyxl')

# 关闭连接
cnxn.close()
