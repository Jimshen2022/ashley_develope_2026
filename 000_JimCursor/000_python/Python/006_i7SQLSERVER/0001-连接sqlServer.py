# this file is tested and works well by Jim,Shen on Mar.08.2025
import pyodbc

conn = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=JIM_SHEN;'
    'DATABASE=JIMSHEN666;'
    'Trusted_Connection=yes;'
)

cursor = conn.cursor()
cursor.execute("SELECT * FROM item_master")
for row in cursor.fetchall():
    print(row)

conn.close()




