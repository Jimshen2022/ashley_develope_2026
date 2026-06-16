import pandas as pd
import time
from datetime import datetime, timedelta

def run(dfs):
    print("Executing a11_inbound_cal...")
    start_time = time.time()
    
    df_po = dfs.get('OpenPO', pd.DataFrame())
    df_fp = dfs.get('Firmed_Planned_PO', pd.DataFrame())
    
    # Calculate target Saturday dates
    today = datetime.now()
    days_to_sat = (5 - today.weekday()) % 7
    sat_date = (today + timedelta(days=days_to_sat)).replace(hour=0, minute=0, second=0, microsecond=0)
    dates = [(sat_date + timedelta(days=i*7)).strftime('%Y-%m-%d') for i in range(7)]

    # --- STEP 1: Pre-aggregate OpenPO data ---
    dict_po = {}
    if not df_po.empty:
        col_b = df_po.columns[1] if len(df_po.columns) > 1 else 'ITNBR'
        col_n = df_po.columns[13] if len(df_po.columns) > 13 else 'Open_PO'
        col_q = df_po.columns[16] if len(df_po.columns) > 16 else 'New_Status'
        col_r = df_po.columns[17] if len(df_po.columns) > 17 else 'WeekSaturday'
        
        df_po_filtered = df_po[df_po[col_q].astype(str).str.strip().str.upper() != 'IN_YARD'].copy()
        
        df_po_filtered[col_b] = df_po_filtered[col_b].astype(str).str.strip()
        df_po_filtered['DateKey'] = pd.to_datetime(df_po_filtered[col_r], errors='coerce').dt.date.astype(str)
        df_po_filtered[col_n] = pd.to_numeric(df_po_filtered[col_n], errors='coerce').fillna(0)
        
        grouped_po = df_po_filtered.groupby([col_b, 'DateKey'])[col_n].sum().reset_index()
        for _, row in grouped_po.iterrows():
            key = f"{row[col_b]}|{row['DateKey']}"
            dict_po[key] = row[col_n]

    # --- STEP 2: Pre-aggregate Firmed_Planned_PO data ---
    dict_fp = {}
    if not df_fp.empty:
        col_a = df_fp.columns[0]
        col_c = df_fp.columns[2]
        col_e = df_fp.columns[4]
        
        df_fp[col_a] = df_fp[col_a].astype(str).str.strip()
        df_fp['DateKey'] = pd.to_datetime(df_fp[col_c], errors='coerce').dt.date.astype(str)
        df_fp[col_e] = pd.to_numeric(df_fp[col_e], errors='coerce').fillna(0)
        
        grouped_fp = df_fp.groupby([col_a, 'DateKey'])[col_e].sum().reset_index()
        for _, row in grouped_fp.iterrows():
            key = f"{row[col_a]}|{row['DateKey']}"
            dict_fp[key] = row[col_e]

    # --- STEP 3: Populate Target Columns in memory ---
    if 'ItemBalance_by_Pieces_Data' in dfs:
        df_co = dfs['ItemBalance_by_Pieces_Data']
        
        for i, date_str in enumerate(dates):
            col_name = f'Inbound_{i}'
            
            def calc_inbound(row):
                item = str(row['Item']).strip()
                if not item: return 0.0
                combo_key = f"{item}|{date_str}"
                return dict_po.get(combo_key, 0.0) + dict_fp.get(combo_key, 0.0)
                
            df_co[col_name] = df_co.apply(calc_inbound, axis=1)
            
        dfs['ItemBalance_by_Pieces_Data'] = df_co
        dfs['Target_Dates'] = dates

    elapsed_time = time.time() - start_time
    print(f"a11_inbound_cal completed in {elapsed_time:.2f} seconds.")
