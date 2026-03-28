import pandas as pd
import time
import re

def categorize_product(row):
    col1 = str(row.iloc[0]).strip() if pd.notnull(row.iloc[0]) else ""
    col4 = str(row.iloc[3]).strip().upper() if len(row) > 3 and pd.notnull(row.iloc[3]) else ""
    col5 = str(row.iloc[4]).strip().upper() if len(row) > 4 and pd.notnull(row.iloc[4]) else ""

    if col4 == "UPH":
        return "UPH"
    elif col5 == "FLOOR":
        return "BULK"
    elif col5 == "RAILS":
        return "CG"
    elif col5 == "RUGS":
        return "RUGS"
    elif (col4 == "" or col4 == "NONE" or col4 == "NAN") and len(col1) > 0 and re.match(r'^[1-9U]', col1[0]):
        return "UPH"
    else:
        return "CG"

def run(dfs):
    print("Executing a09_Products...")
    start_time = time.time()
    
    target_sheet = 'Item_Master'
    
    if target_sheet not in dfs or dfs[target_sheet].empty:
        print(f"No data found in {target_sheet}. Exiting.")
        return

    print("Categorizing products...")
    df = dfs[target_sheet]

    while len(df.columns) < 6:
        df[f'Empty_Col_{len(df.columns)}'] = None

    product_series = df.apply(categorize_product, axis=1)
    
    if 'Product' in df.columns:
        df['Product'] = product_series
    else:
        df.insert(5, 'Product', product_series)

    elapsed_time = time.time() - start_time
    print(f"a09_Products completed in {elapsed_time:.2f} seconds.")