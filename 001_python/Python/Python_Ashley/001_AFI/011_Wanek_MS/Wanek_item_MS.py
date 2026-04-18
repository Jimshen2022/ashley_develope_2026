let
    Source = Python.Execute("
import pandas as pd
import pyodbc
import warnings
warnings.filterwarnings('ignore', message='pandas only supports SQLAlchemy.*')

# Access 数据库文件路径
db_path = r'V:\\Prod & Inv Control\\Public\\00.Master Data\\UPHMaster.accdb'

# 创建连接字符串
conn_str = (
    r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
    f'DBQ={db_path};'
)
conn = pyodbc.connect(conn_str)

# 读取 Type 表
df = pd.read_sql('SELECT Item, Kind FROM Type', conn)

# 去除空格，防止 Item 中有隐藏字符
df['Item'] = df['Item'].str.strip()

# 替换 Kind 字段中的分类
df['Kind'] = df['Kind'].replace({'Recliner': 'Motion', 'Ottoman': 'Stationary'})

# 保留 W1337238JH 的第一行（确保唯一）
df_w1337238jh = df[df['Item'] == 'W1337238JH'].head(1)

# 过滤掉所有其他 W1337238JH 行
df_others = df[df['Item'] != 'W1337238JH']

# 合并
df = pd.concat([df_w1337238jh, df_others], ignore_index=True)

# 根据 Item 去重
df = df.drop_duplicates(subset='Item')

# 重命名列
df.rename(columns={'Item': 'ITNBR'}, inplace=True)

# 关闭数据库连接
conn.close()
df
"),
    df = Source{[Name="df"]}[Value]
in
    df