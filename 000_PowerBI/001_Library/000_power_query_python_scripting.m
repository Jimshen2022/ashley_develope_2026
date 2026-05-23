
let
    Source = Python.Execute("
import pandas as pd
import pyodbc
import warnings
warnings.filterwarnings('ignore', message='pandas only supports SQLAlchemy.*')
# Access 数据库文件路径（双反斜杠）
db_path = r'V:\\Prod & Inv Control\\Public\\00.Master Data\\UPHMaster.accdb'
# 创建连接
conn_str = (
    r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
    f'DBQ={db_path};'
)
conn = pyodbc.connect(conn_str)
# 读取 Data 表
df = pd.read_sql('SELECT Item, Kind FROM Type', conn)
# 清洗逻辑：先检查 W1337238JH 有几行
w1337238jh_count = len(df[df['Item'] == 'W1337238JH'])
print(f'W1337238JH 共有 {w1337238jh_count} 行')
# 分离数据：W1337238JH 和其他
df_w1337238jh = df[df['Item'] == 'W1337238JH'].drop_duplicates().head(1)  # 只保留一行
df_others = df[df['Item'] != 'W1337238JH']  # 其他所有行
# 重新合并
df = pd.concat([df_w1337238jh, df_others], ignore_index=True)
df['Kind'] = df['Kind'].replace({'Recliner': 'Motion', 'Ottoman': 'Stationary'})
df = df.drop_duplicates(subset='Item')
# 重命名列
df.rename(columns={'Item': 'ITNBR'}, inplace=True)
conn.close()
df
"),
    df = Source{[Name="df"]}[Value]
in
    df