import numpy as np
import pandas as pd
df = dataset

def allocate_fixed_stock(df_group):
    df_group = df_group.sort_values(by=['dispatch_date', 'trip_number']).copy()
    
    # 初始库存为首行 Available Sto
    total_available = df_group.iloc[0]['available_sto']
    used_qty = 0
    allocated_qty = []

    for _, row in df_group.iterrows():
        allocated = max(total_available - used_qty, 0)
        allocated_qty.append(allocated)
        used_qty += (row['trip_needed'] - row['trip_picked'])

    df_group['allocated_qty'] = allocated_qty

    # 增加 Negative_Qty 列
    df_group['Negative_Qty'] = df_group.apply(
        lambda row: 0 if (row['allocated_qty'] - row['trip_needed'] + row['trip_picked']) >= 0 
        else (row['allocated_qty'] - row['trip_needed'] + row['trip_picked']),
        axis=1
    )

    # 增加 Negative_Total 列（累计求和）
    df_group['Negative_Total'] = df_group['Negative_Qty'].cumsum()

    return df_group

# 应用分组处理
df_result = df.groupby('item_number', group_keys=False).apply(allocate_fixed_stock)
