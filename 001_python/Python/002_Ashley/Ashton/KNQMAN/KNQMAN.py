import pyodbc

# 替换为你自己的账号和密码
conn = pyodbc.connect(
    r'DRIVER={SQL Server};'
    r'SERVER=VPHUVNVPSQ23267;'
    r'DATABASE=ECU55_KNQ;'
    r'UID=admin;'
    r'PWD=123456'
)

cursor = conn.cursor()

# 查询所有 schema
cursor.execute("SELECT name FROM sys.schemas")
print("Schemas:")
for row in cursor.fetchall():
    print(row.name)

# 查询所有表
cursor.execute("""
    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'
""")
print("\nTables:")
for row in cursor.fetchall():
    print(f"{row.TABLE_SCHEMA}.{row.TABLE_NAME}")

conn.close()
