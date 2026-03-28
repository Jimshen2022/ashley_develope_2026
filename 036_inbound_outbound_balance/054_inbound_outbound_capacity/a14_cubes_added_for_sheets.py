import pandas as pd
import time

def process_sheet_fixed(dfs, item_dict, sh_name, i_col_name, q_col_name, t_col_name):
    if sh_name not in dfs or dfs[sh_name].empty:
        return

    df = dfs[sh_name]

    col_mapping = {
        'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5, 'G': 6, 'H': 7, 'I': 8, 'J': 9,
        'K': 10, 'L': 11, 'M': 12, 'N': 13, 'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18,
        'T': 19, 'U': 20, 'V': 21, 'W': 22, 'X': 23, 'Y': 24, 'Z': 25, 'AA': 26, 'AB': 27,
        'AC': 28, 'AD': 29, 'AE': 30, 'AF': 31, 'AG': 32, 'AH': 33, 'AI': 34, 'AJ': 35,
        'AK': 36, 'AL': 37, 'AM': 38, 'AN': 39, 'AO': 40, 'AP': 41, 'AQ': 42, 'AR': 43
    }
    
    i_idx = col_mapping.get(i_col_name.upper())
    q_idx = col_mapping.get(q_col_name.upper())
    t_idx = col_mapping.get(t_col_name.upper())

    while len(df.columns) <= t_idx:
        df[f'Empty_Col_{len(df.columns)}'] = None

    i_col = df.columns[i_idx]
    q_col = df.columns[q_idx]
    t_col = df.columns[t_idx]

    df.rename(columns={t_col: 'Cubes'}, inplace=True)
    t_col = 'Cubes'

    def calc_cubes(row):
        item = str(row[i_col]).strip() if pd.notnull(row[i_col]) else ""
        qty = float(row[q_col]) if pd.notnull(row[q_col]) else 0.0
        
        if item in item_dict:
            return qty * item_dict[item]
        return 0.0

    df[t_col] = df.apply(calc_cubes, axis=1)

def run(dfs):
    print("Executing a14_cubes_added_for_sheets...")
    start_time = time.time()
    
    if 'Item_Master' not in dfs or dfs['Item_Master'].empty:
        print("Item_Master not in memory.")
        return
        
    df_master = dfs['Item_Master']
    col_a = df_master.columns[0]
    col_c = df_master.columns[2]
    
    df_master[col_a] = df_master[col_a].astype(str).str.strip()
    df_master[col_c] = pd.to_numeric(df_master[col_c], errors='coerce').fillna(0.0)
    
    item_dict = df_master.drop_duplicates(subset=[col_a]).set_index(col_a)[col_c].to_dict()

    process_sheet_fixed(dfs, item_dict, "OnHand", "A", "B", "H")
    process_sheet_fixed(dfs, item_dict, "Yard", "K", "N", "T")
    process_sheet_fixed(dfs, item_dict, "OpenPO", "B", "N", "S")
    process_sheet_fixed(dfs, item_dict, "Firmed_Planned_PO", "A", "E", "H")
    process_sheet_fixed(dfs, item_dict, "CustomerOrder", "E", "U", "AQ")

    elapsed_time = time.time() - start_time
    print(f"a14_cubes_added_for_sheets completed in {elapsed_time:.2f} seconds.")
