import pandas as pd
import pyodbc
import time
import warnings

warnings.filterwarnings('ignore', category=UserWarning, message='.*pandas only supports SQLAlchemy.*')

def run(dfs):
    print("Executing a021_Pull_Firmed_Planned_PO...")
    start_time = time.time()

    server_name = "ashley-edw.database.windows.net"
    database_name = "ASHLEY_EDW"
    driver = "{ODBC Driver 17 for SQL Server}"
    
    conn_str = f"DRIVER={driver};SERVER={server_name};DATABASE={database_name};Authentication=ActiveDirectoryIntegrated;"

    query = """
    WITH itm AS (
        SELECT TRIM(a.itnbr) AS item_number, a.B2Z95S AS unit_cube
        FROM MasterData_ItemMaster_AFI.ITMRVA AS a
        LEFT JOIN MasterData_ItemMaster_AFI.ITBEXT AS b
            ON b.itnbr = a.itnbr AND a.stid = b.house
        WHERE a.stid = '335' AND a.itcls LIKE 'Z%' AND a.itcls NOT LIKE 'Z%K'
    ),
    sp AS (
        SELECT * FROM Wholesale_DemandPlanning_AFI.SupplyPlanDetail AS T1
        WHERE t1.spdWarehouse = '335' AND (t1.spdFirmPurchaseOrders + t1.spdPlannedPurchaseOrders) > 0
        AND dtec = (SELECT MAX(dtec) FROM Wholesale_DemandPlanning_AFI.SupplyPlanDetail)
    )
    SELECT
        sp.spdItem,
        sp.spdWarehouse,
        sp.spdWeekEnding,
        sp.spdFirmPurchaseOrders,
        sp.spdPlannedPurchaseOrders,
        (sp.spdFirmPurchaseOrders * ISNULL(itm.unit_cube, 0)) AS cube_FirmPurchaseOrders,
        (sp.spdPlannedPurchaseOrders * ISNULL(itm.unit_cube, 0)) AS cube_PlannedPurchaseOrders
    FROM sp
    LEFT JOIN itm ON sp.spdItem = itm.item_number
    ORDER BY sp.spdWeekEnding;
    """

    print("Connecting to SQL Server and executing query...")
    try:
        conn = pyodbc.connect(conn_str)
        df = pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error connecting or executing query: {e}")
        return
    finally:
        if 'conn' in locals() and conn:
            conn.close()

    if 'spdItem' in df.columns:
        df['spdItem'] = df['spdItem'].astype(str)
        
    if 'spdWeekEnding' in df.columns:
        # 强制格式化为 YYYY-MM-DD 字符串，以便 summary.py 精确匹配
        df['spdWeekEnding'] = pd.to_datetime(df['spdWeekEnding']).dt.strftime('%Y-%m-%d')

    # Store in memory dictionary instead of saving to disk
    dfs['Firmed_Planned_PO'] = df

    elapsed_time = time.time() - start_time
    print(f"a021_Pull_Firmed_Planned_PO completed successfully in {elapsed_time:.2f} seconds.")