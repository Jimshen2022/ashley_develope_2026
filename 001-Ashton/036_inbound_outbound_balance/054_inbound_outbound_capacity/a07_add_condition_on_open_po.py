import pandas as pd
import time

def run(dfs):
    print("Executing a07_add_condition_on_open_po...")
    start_time = time.time()
    
    if 'OpenPO' not in dfs or 'Yard' not in dfs:
        print("Required sheets not found in memory.")
        return

    df_open = dfs['OpenPO']
    df_yard = dfs['Yard']

    if df_open.empty:
        print("OpenPO sheet is empty. Exiting.")
        return

    # Use explicit names from SQL if available, otherwise fallback
    cols_open_upper = [str(c).upper() for c in df_open.columns]
    cols_yard_upper = [str(c).upper() for c in df_yard.columns]

    po_col = df_yard.columns[cols_yard_upper.index('PO#')] if 'PO#' in cols_yard_upper else df_yard.columns[5]
    loc_col = df_yard.columns[cols_yard_upper.index('LOCATION')] if 'LOCATION' in cols_yard_upper else df_yard.columns[2]
    
    yard_dict = df_yard.drop_duplicates(subset=[po_col]).set_index(po_col)[loc_col].to_dict()

    ordno_col = df_open.columns[cols_open_upper.index('ORDNO')] if 'ORDNO' in cols_open_upper else df_open.columns[0]
    pstts_col = df_open.columns[cols_open_upper.index('PSTTS')] if 'PSTTS' in cols_open_upper else df_open.columns[6]
    duedt_col = df_open.columns[cols_open_upper.index('DUEDT')] if 'DUEDT' in cols_open_upper else df_open.columns[4]

    df_open['Yard_Check'] = df_open[ordno_col].map(yard_dict).fillna('NOT IN YARD')

    def get_new_status(row):
        yard_check = str(row['Yard_Check']).strip()
        # Fix Pandas converting numeric strings to floats (e.g. "20.0" instead of "20")
        pst = str(row[pstts_col]).strip().split('.')[0]
        
        if yard_check == 'NOT IN YARD':
            if pst == '20':
                return 'OPEN_PO'
            elif pst == '30':
                return 'IN_TRANSIT'
            else:
                return 'CHECK'
        else:
            return 'IN_YARD'

    df_open['New_Status'] = df_open.apply(get_new_status, axis=1)

    # Use DUEDT for WeekSaturday calculation
    dt_series = pd.to_datetime(df_open[duedt_col], errors='coerce')
    days_to_add = (5 - dt_series.dt.weekday) % 7
    
    # Store strictly as string YYYY-MM-DD
    df_open['WeekSaturday'] = (dt_series + pd.to_timedelta(days_to_add, unit='D')).dt.strftime('%Y-%m-%d')

    elapsed_time = time.time() - start_time
    print(f"a07_add_condition_on_open_po completed in {elapsed_time:.2f} seconds.")