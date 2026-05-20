import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import time
from datetime import datetime
import sys

# --- Configuration ---
# Database Connection Parameters
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'

# Output File Configuration
OUTPUT_DIR = os.path.expanduser("~/Downloads")

# --- SQL Queries ---
ASN_QUERY = """
SELECT
    t.asn_number, t.asn_id, t.status, t.equipment_id, t.trailer_type_name,
    t.expected_arrival, t.vendor_id, t.total_quantity, t.total_volume,
    t1.item_number, t1.uom, t1.customer_po_number, t1.serial_number_start,
    t1.serial_number_end, (t1.quantity_shipped - t1.quantity_received) AS qty_remaining,
    t1.sn_coo, t3.status AS trailer_status, t3.entered_yard, t3.exited_yard, t4.location_name
FROM t_asn AS t
LEFT JOIN t_asn_detail AS t1 ON t.asn_id = t1.asn_id
LEFT JOIN t_trailer_asn AS t2 ON t.asn_id = t2.asn_id
LEFT JOIN t_trailer AS t3 ON t2.trailer_id = t3.trailer_id
LEFT JOIN t_ya_location AS t4 ON t3.location_id = t4.location_id
WHERE t.[status] IN ('CHECKED IN', 'CLOSED')
  AND t3.entered_yard >= CAST(DATEADD(day, -7, GETDATE()) AS DATE)
"""

TRAN_LOG_QUERY = """
SELECT
    item_number,
    control_number_2 AS po_number,
    lot_number,
    control_number AS receiving_equipment,
    employee_id AS receiving_employee,
    (start_tran_date + start_tran_time) AS receiving_time,
    tran_type
FROM t_tran_log
WHERE tran_type IN (151, 951) AND lot_number IS NOT NULL AND lot_number != ''
"""

# --- Helper Functions ---

def get_connection_string():
    """Generates the connection string for Windows Authentication."""
    driver = '{ODBC Driver 17 for SQL Server}'
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
    )

def expand_serial_numbers(df):
    """
    Expands ASN data rows with serial number ranges into individual rows for each serial number.
    Keeps original start/end columns.
    """
    print("Expanding ASN serial number ranges...")
    # Ensure start/end columns are treated as strings to avoid conversion errors
    df['serial_number_start'] = df['serial_number_start'].astype(str).str.strip()
    df['serial_number_end'] = df['serial_number_end'].astype(str).str.strip()
    
    # Filter out rows where serial numbers are missing, None, or 'nan'
    df_valid = df.dropna(subset=['serial_number_start', 'serial_number_end'])
    df_valid = df_valid[df_valid['serial_number_start'].str.lower() != 'nan']
    
    df_invalid = df[~df.index.isin(df_valid.index)]

    expanded_rows = []
    for _, row in df_valid.iterrows():
        try:
            start_sn_str = row['serial_number_start']
            end_sn_str = row['serial_number_end']
            
            # Extract numeric parts for range generation
            start_sn = int(start_sn_str)
            end_sn = int(end_sn_str)

            base_row = row.to_dict()
            
            if start_sn > end_sn:
                raise ValueError("Start SN is greater than End SN")

            for sn in range(start_sn, end_sn + 1):
                new_row = base_row.copy()
                # Use the length of the original string to maintain leading zeros
                orig_len = len(start_sn_str)
                new_row['serial_number'] = str(sn).zfill(orig_len)
                expanded_rows.append(new_row)
                
        except (ValueError, TypeError):
            # If conversion fails, keep the original row and mark the serial number
            base_row = row.to_dict()
            base_row['serial_number'] = row['serial_number_start'] # Keep at least one SN
            expanded_rows.append(base_row)
            
    # Add back rows that had no valid SN range to begin with
    expanded_df = pd.DataFrame(expanded_rows)
    final_df = pd.concat([expanded_df, df_invalid], ignore_index=True)
    
    print(f"Expansion complete. Total rows after expanding: {len(final_df)}")
    return final_df

def process_transaction_logs(df):
    """
    Filters transaction logs to get the last valid receiving scan (151) for each lot number.
    A scan is invalid if it was later undone by a 951 scan.
    """
    print("Processing transaction logs to find last valid receiving scans...")
    if df.empty:
        print("Transaction log data is empty.")
        return pd.DataFrame()
        
    # Sort by lot number and time to process chronologically
    df_sorted = df.sort_values(by=['lot_number', 'receiving_time'])
    
    # Get the last transaction for each lot number
    last_scans = df_sorted.groupby('lot_number').last().reset_index()
    
    # Keep only the lots where the very last scan was a receiving scan (151)
    valid_scans = last_scans[last_scans['tran_type'] == 151].copy()
    
    # Drop the tran_type column as it's no longer needed
    valid_scans = valid_scans.drop(columns=['tran_type'])
    
    print(f"Found {len(valid_scans)} validly received lots from transaction logs.")
    return valid_scans

# --- Main Program ---
if __name__ == "__main__":
    start_time = time.time()

    # Create DB engine
    try:
        conn_str = get_connection_string()
        params = urllib.parse.quote_plus(conn_str)
        engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")
        print("Database engine created successfully.")
    except Exception as e:
        print(f"Error creating database engine: {e}")
        sys.exit()

    # --- Data Fetching ---
    try:
        print("Fetching ASN data...")
        df_asn = pd.read_sql(ASN_QUERY, engine)
        print(f"Successfully fetched {len(df_asn)} ASN detail rows.")
        
        print("Fetching transaction log data...")
        df_tran_log = pd.read_sql(TRAN_LOG_QUERY, engine)
        print(f"Successfully fetched {len(df_tran_log)} transaction log rows (type 151/951).")
    except Exception as e:
        print(f"Database connection or query failed! {e}")
        sys.exit()

    # --- Data Processing ---
    # 1. Expand ASN serial numbers
    expanded_asn_df = expand_serial_numbers(df_asn)

    # 2. Process transaction logs
    valid_scans_df = process_transaction_logs(df_tran_log)

    # --- Merging Data ---
    if not expanded_asn_df.empty and not valid_scans_df.empty:
        print("Merging ASN data with valid receiving scans...")
        # Ensure merge keys are the same type (string)
        # customer_po_number from ASN maps to po_number from tran_log
        expanded_asn_df['customer_po_number'] = expanded_asn_df['customer_po_number'].astype(str).str.strip()
        expanded_asn_df['item_number'] = expanded_asn_df['item_number'].astype(str).str.strip()
        expanded_asn_df['serial_number'] = expanded_asn_df['serial_number'].astype(str).str.strip()

        valid_scans_df['po_number'] = valid_scans_df['po_number'].astype(str).str.strip()
        valid_scans_df['item_number'] = valid_scans_df['item_number'].astype(str).str.strip()
        valid_scans_df['lot_number'] = valid_scans_df['lot_number'].astype(str).str.strip()

        # Perform an outer merge to keep all records from both ASN and Tran Log
        # Merge on PO, Item, and Serial/Lot
        merged_df = pd.merge(
            expanded_asn_df,
            valid_scans_df,
            left_on=['customer_po_number', 'item_number', 'serial_number'],
            right_on=['po_number', 'item_number', 'lot_number'],
            how='outer',
            indicator=True # Adds a column _merge to show where the row came from
        )
        print("Merge complete.")
    else:
        print("Skipping merge due to empty dataframes. Using outer join logic on empty.")
        # If one is empty, we just fallback to outer behavior manually, or use merge anyway
        # For simplicity, if one is empty, merge handles it fine as long as cols exist
        if expanded_asn_df.empty:
            merged_df = valid_scans_df
            merged_df['_merge'] = 'right_only'
        else:
            merged_df = expanded_asn_df
            merged_df['_merge'] = 'left_only'

    # --- Final Formatting and Export ---
    # Format serial number fields for Excel to treat as text
    
    # helper function to append tab to strings to force Excel to treat them as text in CSV
    def format_as_excel_text(val):
        if pd.isna(val) or str(val).lower() == 'nan' or val == '':
            return val
        return f'{val}\t'
    
    if 'serial_number' in merged_df.columns:
        merged_df['serial_number'] = merged_df['serial_number'].apply(format_as_excel_text)
    
    if 'serial_number_start' in merged_df.columns:
        merged_df['serial_number_start'] = merged_df['serial_number_start'].apply(format_as_excel_text)

    if 'serial_number_end' in merged_df.columns:
        merged_df['serial_number_end'] = merged_df['serial_number_end'].apply(format_as_excel_text)
        
    if 'lot_number' in merged_df.columns:
        merged_df['lot_number'] = merged_df['lot_number'].apply(format_as_excel_text)

    # Rename _merge for clarity
    if '_merge' in merged_df.columns:
        merged_df = merged_df.rename(columns={'_merge': 'Match_Status'})
        # Map pandas indicator values to more readable ones
        merged_df['Match_Status'] = merged_df['Match_Status'].map({
            'left_only': 'ASN Only',
            'right_only': 'TranLog Only',
            'both': 'Matched'
        })

    # Generate filename and path
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"ashton_received_sn_vs_asn_v2_{current_time}.csv"
    csv_path = os.path.join(OUTPUT_DIR, filename)

    # Export to CSV
    try:
        merged_df.to_csv(csv_path, index=False, encoding='utf-8-sig')
        print(f"\nData successfully exported to CSV file: {csv_path}")
        print("Note: 'serial_number', 'serial_number_start', 'serial_number_end', and 'lot_number' columns are formatted to be treated as text in Excel.")
    except Exception as e:
        print(f"Failed to export CSV file! {e}")

    # --- Final Timings ---
    end_time = time.time()
    execution_time = end_time - start_time
    print(f"\nTotal execution time: {execution_time:.2f} seconds")