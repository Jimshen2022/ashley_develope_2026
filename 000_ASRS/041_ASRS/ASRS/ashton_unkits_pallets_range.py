import pandas as pd
import os
from pathlib import Path

# 获取Downloads文件夹路径
downloads_path = Path.home() / "Downloads"
file_path = downloads_path / "MIL Unkits Loading Audit - 20250924-4.xlsb"

# 读取Excel文件
# 读取Pallet Count Range sheet
df_range = pd.read_excel(file_path, sheet_name='Pallet Count Range', engine='pyxlsb')

# 读取Unkits Cnt Loading Sequence sheet
df_data = pd.read_excel(file_path, sheet_name='Unkits Cnt Loading Sequence', engine='pyxlsb')

# 获取YearWeek范围
week_start = df_range.iloc[0, 1]  # B1
week_end = df_range.iloc[0, 2]  # C1

print(f"YearWeek Range: {week_start} to {week_end}")

# 筛选在YearWeek范围内的数据
df_filtered = df_data[(df_data['YearWeek'] >= week_start) & (df_data['YearWeek'] <= week_end)]

print(f"筛选后的数据行数: {len(df_filtered)}")

# 定义Pallet Count区间
ranges = [
    (0, 1, "0 ~ 1 pallet"),
    (1, 2, "1 ~ 2 pallets"),
    (2, 3, "2 ~ 3 pallets"),
    (3, 4, "3 ~ 4 pallets"),
    (4, 5, "4 ~ 5 pallets"),
    (5, 6, "5 ~ 6 pallets"),
    (6, 7, "6 ~ 7 pallets"),
    (7, 8, "7 ~ 8 pallets"),
    (8, 9, "8 ~ 9 pallets"),
    (9, 10, "9 ~ 10 pallets"),
    (10, 20, "10 ~ 20 pallets"),
    (20, 30, "20 ~ 30 pallets"),
    (30, 40, "30 ~ 40 pallets"),
    (40, 50, "40 ~ 50 pallets"),
    (50, float('inf'), "Over 50 pallets")
]

# 结果列表
results = []

for min_val, max_val, label in ranges:
    # 按ITEM_NUMBER分组，先加总Pallet Qty
    item_totals = df_filtered.groupby('ITEM_NUMBER')['Pallet Qty'].sum()

    # 去掉小数，如果有小数部分则向上取整
    import math

    item_totals_int = item_totals.apply(lambda x: math.ceil(x) if x > 0 else 0)

    # 筛选在当前区间内的ITEM_NUMBER
    if max_val == float('inf'):
        items_in_range = item_totals_int[item_totals_int >= min_val]
    else:
        items_in_range = item_totals_int[(item_totals_int >= min_val) & (item_totals_int < max_val)]

    # SKUs数量（唯一ITEM_NUMBER计数）
    skus_count = len(items_in_range)

    # Pallet Counted（该区间内所有pallet的总和）
    pallet_counted = items_in_range.sum()

    results.append({
        'Range': label,
        'SKUs': skus_count,
        'Pallet Counted': pallet_counted
    })

    print(f"{label}: SKUs={skus_count}, Pallet Counted={pallet_counted}")

# 创建结果DataFrame
df_results = pd.DataFrame(results)

# 写回Excel
with pd.ExcelWriter(file_path, engine='pyxlsb', mode='a', if_sheet_exists='overlay') as writer:
    # 写入SKUs到B5:B19
    df_results['SKUs'].to_excel(writer, sheet_name='Pallet Count Range',
                                startrow=4, startcol=1, header=False, index=False)

    # 写入Pallet Counted到C5:C19
    df_results['Pallet Counted'].to_excel(writer, sheet_name='Pallet Count Range',
                                          startrow=4, startcol=2, header=False, index=False)

print("\n结果已写入Excel文件！")
print(df_results)