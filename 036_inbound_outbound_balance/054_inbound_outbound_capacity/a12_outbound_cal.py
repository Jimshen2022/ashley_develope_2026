import pandas as pd
import time

def run(dfs):
    print("Executing a12_outbound_cal...")
    start_time = time.time()
    
    df_co_raw = dfs.get('CustomerOrder', pd.DataFrame())

    # --- STEP 1: Pre-aggregate CustomerOrder data ---
    dict_co = {}
    if not df_co_raw.empty:
        col_e = df_co_raw.columns[4] if len(df_co_raw.columns) > 4 else 'ITNBR'
        col_u = df_co_raw.columns[20] if len(df_co_raw.columns) > 20 else 'OPEN_CO_QTY'
        col_ap = df_co_raw.columns[41] if len(df_co_raw.columns) > 41 else 'WeekSaturday'
        
        df_co_raw[col_e] = df_co_raw[col_e].astype(str).str.strip()
        df_co_raw['DateKey'] = pd.to_datetime(df_co_raw[col_ap], errors='coerce').dt.date.astype(str)
        df_co_raw[col_u] = pd.to_numeric(df_co_raw[col_u], errors='coerce').fillna(0)
        
        grouped_co = df_co_raw.groupby([col_e, 'DateKey'])[col_u].sum().reset_index()
        for _, row in grouped_co.iterrows():
            key = f"{row[col_e]}|{row['DateKey']}"
            dict_co[key] = row[col_u]

    # --- STEP 2: Populate Target Columns in memory ---
    if 'ItemBalance_by_Pieces_Data' in dfs and 'Target_Dates' in dfs:
        df_co = dfs['ItemBalance_by_Pieces_Data']
        dates = dfs['Target_Dates']
        
        for i, date_str in enumerate(dates):
            col_name = f'Outbound_{i}'
            
            def calc_outbound(row):
                item = str(row['Item']).strip()
                if not item: return 0.0
                combo_key = f"{item}|{date_str}"
                return dict_co.get(combo_key, 0.0)
                
            df_co[col_name] = df_co.apply(calc_outbound, axis=1)
            
        dfs['ItemBalance_by_Pieces_Data'] = df_co

    elapsed_time = time.time() - start_time
    print(f"a12_outbound_cal completed in {elapsed_time:.2f} seconds.")
