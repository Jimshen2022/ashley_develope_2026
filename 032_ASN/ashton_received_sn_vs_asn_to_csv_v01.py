import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import time
from datetime import datetime

# Database Connection Parameters
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'

def get_connection_string():
    """生成连接字符串 (Windows Authentication)"""
    driver = '{ODBC Driver 17 for SQL Server}' 
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"  
        f"Encrypt=yes;"             
        f"TrustServerCertificate=yes;" 
    )

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

def expand_serial_numbers(df):
    """
    Expands rows containing serial_number_start and serial_number_end into 
    multiple rows, one for each serial number in the range.
    """
    print("Expanding serial numbers into individual rows...")
    # Filter out rows where serial numbers are missing or not strings
    df_valid = df.dropna(subset=['serial_number_start', 'serial_number_end']).copy()
    df_invalid = df[df['serial_number_start'].isna() | df['serial_number_end'].isna()].copy()
    
    expanded_rows = []
    
    for _, row in df_valid.iterrows():
        try:
            # Assuming serial numbers are numeric or have a numeric suffix.
            start_sn = int(row['serial_number_start'])
            end_sn = int(row['serial_number_end'])
            
            # Generate range (inclusive)
            sn_range = range(start_sn, end_sn + 1)
            
            # Create a dictionary for the base row, KEEPING the start/end columns this time
            base_row = row.to_dict()
            
            for sn in sn_range:
                new_row = base_row.copy()
                # Format back to the original string format if it had leading zeros
                orig_len = len(str(row['serial_number_start']))
                
                # Add a tab character at the end so Excel treats it as text and doesn't use scientific notation
                # Another common trick is using ="123", but pandas handles '\t' cleanly for CSVs
                formatted_sn = str(sn).zfill(orig_len)
                new_row['serial_number'] = f"{formatted_sn}\t"
                expanded_rows.append(new_row)
                
        except ValueError:
            # Handle cases where serial numbers aren't simple integers
            print(f"Warning: Could not parse serial numbers for ASN {row['asn_number']}: {row['serial_number_start']} to {row['serial_number_end']}. Keeping original row.")
            base_row = row.to_dict()
            base_row['serial_number'] = f"{row['serial_number_start']} - {row['serial_number_end']}\t"
            expanded_rows.append(base_row)
            
    # Process invalid rows (those without start/end)
    for _, row in df_invalid.iterrows():
        base_row = row.to_dict()
        base_row['serial_number'] = None
        expanded_rows.append(base_row)

    if expanded_rows:
        return pd.DataFrame(expanded_rows)
    else:
        # Return empty DF with correct columns if no data
        cols = list(df.columns)
        cols.append('serial_number')
        return pd.DataFrame(columns=cols)

# Main Program
start_time = time.time()

# Create connection URL
conn_str = get_connection_string()
params = urllib.parse.quote_plus(conn_str)

# Create engine
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# Execute query
try:
    print("Executing query...")
    df = pd.read_sql(SQL_QUERY, engine)
    print("Query successful! Data loaded into DataFrame.")
    print(f"Total rows retrieved from DB: {len(df)}")
except Exception as e:
    print("Database connection or query failed!", e)
    exit()

# Expand the DataFrame
try:
    expanded_df = expand_serial_numbers(df)
    print(f"Expansion complete. Total rows after expanding: {len(expanded_df)}")
except Exception as e:
    print(f"Failed to expand serial numbers: {e}")
    expanded_df = df # Fallback to original if expansion fails

# Generate filename and path with timestamp
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
filename = f"ashton_received_sn_vs_asn_{current_time}.csv"
csv_path = os.path.join(OUTPUT_DIR, filename)

# Export to CSV
try:
    # Explicitly quote all non-numeric fields if needed, but the tab trick usually suffices
    expanded_df.to_csv(csv_path, index=False)
    print(f"\nData successfully exported to CSV file: {csv_path}")
    print("Note: 'serial_number' column has a trailing tab (\\t) to force Excel to treat it as text.")
except Exception as e:
    print("Failed to export CSV file!", e)

# Calculate and print total runtime
end_time = time.time()
execution_time = end_time - start_time
print(f"\nTotal execution time: {execution_time:.2f} seconds")
