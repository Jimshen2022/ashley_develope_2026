import pandas as pd
import pyodbc
import time
import warnings

warnings.filterwarnings('ignore', category=UserWarning, message='.*pandas only supports SQLAlchemy.*')

def run(dfs):
    print("Executing a08_item_master...")
    start_time = time.time()

    server_name = "ashley-edw.database.windows.net"
    database_name = "ASHLEY_EDW"
    driver = "{ODBC Driver 17 for SQL Server}"
    
    conn_str = f"DRIVER={driver};SERVER={server_name};DATABASE={database_name};Authentication=ActiveDirectoryIntegrated;TrustServerCertificate=yes;"

    query = """
    SELECT 
        TRIM(a.itnbr) AS itnbr, 
        a.itcls, 
        a.B2Z95S, 
        TRIM(b.pickput) AS pickput, 
        TRIM(b.ITMCLSID) AS ITMCLSID  
    FROM MasterData_ItemMaster_AFI.ITMRVA AS a 
    LEFT JOIN (SELECT * FROM MasterData_ItemMaster_AFI.ITBEXT WHERE HOUSE = '335') AS b 
        ON TRIM(b.itnbr) = TRIM(a.itnbr) AND a.stid = b.house 
    WHERE a.stid = '335' AND a.itcls LIKE 'Z%' AND a.itcls NOT LIKE 'Z%K' 
    ORDER BY a.itnbr
    """

    print("Connecting to SQL Server and executing Item Master query...")
    try:
        conn = pyodbc.connect(conn_str, timeout=180)
        df = pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error connecting to database or executing query: {e}")
        return
    finally:
        if 'conn' in locals() and conn:
            conn.close()

    if 'itnbr' in df.columns:
        df['itnbr'] = df['itnbr'].astype(str)

    # Store in memory dictionary
    dfs['Item_Master'] = df

    elapsed_time = time.time() - start_time
    print(f"a08_item_master completed successfully in {elapsed_time:.2f} seconds.")