import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import time
from datetime import datetime

# Database Connection Parameters
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'

# SQL Query
SQL_QUERY = """
select
    t.asn_number,
    t.asn_id,
    t.status,    
    t.equipment_id, 
    t.trailer_type_name,
    t.expected_arrival,
    t.vendor_id,
    t.total_quantity,
    t.total_volume,
    t1.item_number,
    t1.uom,
    t1.customer_po_number,
    t1.serial_number_start,
    t1.serial_number_end,
    t1.quantity_shipped - t1.quantity_received as qty_remaining,
    t1.sn_coo,
    t3.status as trailer_status,
    t3.entered_yard,
    t4.location_name
from t_asn as t
left join t_asn_detail as t1 on t.asn_id = t1.asn_id
left join t_trailer_asn as t2 on t.asn_id = t2.asn_id
left join t_trailer as t3 on t2.trailer_id = t3.trailer_id
left join t_ya_location as t4 on t3.location_id = t4.location_id
where 1=1
    and t.[status] in ('CHECKED IN')
"""

# Output File Configuration
OUTPUT_DIR = os.path.expanduser("~/Downloads")

# Main Program
start_time = time.time()

# Create connection URL
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

# Create engine
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# Execute query
try:
    print("Executing query...")
    df = pd.read_sql(SQL_QUERY, engine)
    print("Query successful! Data loaded into DataFrame.")
    print(f"Total rows retrieved: {len(df)}")
except Exception as e:
    print("Database connection or query failed!", e)
    exit()

# Generate filename and path with timestamp
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
filename = f"ashton_received_sn_vs_asn_{current_time}.csv"
csv_path = os.path.join(OUTPUT_DIR, filename)

# Export to CSV
try:
    df.to_csv(csv_path, index=False)
    print(f"\nData successfully exported to CSV file: {csv_path}")
except Exception as e:
    print("Failed to export CSV file!", e)

# Calculate and print total runtime
end_time = time.time()
execution_time = end_time - start_time
print(f"\nTotal execution time: {execution_time:.2f} seconds")
