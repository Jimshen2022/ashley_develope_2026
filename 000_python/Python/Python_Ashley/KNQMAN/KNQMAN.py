import pyodbc

server = 'VPHUYNVPQS22367'       # ✅ 替换为你的 SQL Server 的 IP 或主机名
database = 'ECUSS_KNQ'
username = 'ADMIN'
password = ''

conn_str = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};DATABASE={database};UID={username};PWD={password};"
    "Encrypt=no;TrustServerCertificate=yes;"
)

try:
    with pyodbc.connect(conn_str, timeout=10) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT TOP 5 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES")
        for row in cursor.fetchall():
            print(row.TABLE_NAME)
except Exception as e:
    print(f"❌ 连接或查询失败: {e}")
