import pandas as pd
import pyodbc
import time
import warnings

warnings.filterwarnings('ignore', category=UserWarning, message='.*pandas only supports SQLAlchemy.*')

def run(dfs):
    print("Executing a03_Pull_HJ_STO...")
    start_time = time.time()

    server_name = "AshtonWHJSQLprod"
    database_name = "AAD"
    driver = "{ODBC Driver 17 for SQL Server}"
    
    conn_str = f"DRIVER={driver};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes;"

    query = """
    SELECT 
        sto.item_number, 
        sto.actual_qty, 
        sto.status, 
        sto.wh_id, 
        sto.location_id, 
        loc.type AS location_type,
        sto.type AS sto_type
    FROM t_stored_item sto
    JOIN t_location loc ON sto.location_id = loc.location_id AND sto.wh_id = loc.wh_id
    JOIN t_item_master itm ON sto.item_number = itm.item_number AND sto.wh_id = itm.wh_id
    WHERE sto.wh_id = '335'
    AND loc.type IN ('I', 'M', 'P', 'X', 'S', 'D', 'V', 'F')
    AND sto.status = 'A'
    AND sto.location_id NOT IN ('RP998XL1', 'SH001AA1', 'NG001VD3', 'NG001OP3', 'RP998XL3')
    AND sto.item_number <> 'RP ORDER'
    ORDER BY sto.item_number, sto.location_id;
    """

    print("Connecting to SQL Server and executing query...")
    try:
        conn = pyodbc.connect(conn_str)
        df = pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error connecting to database or executing query: {e}")
        return
    finally:
        if 'conn' in locals() and conn:
            conn.close()

    if 'item_number' in df.columns:
        df['item_number'] = df['item_number'].astype(str)

    # Store in memory dictionary
    dfs['OnHand'] = df

    elapsed_time = time.time() - start_time
    print(f"a03_Pull_HJ_STO completed successfully in {elapsed_time:.2f} seconds.")
