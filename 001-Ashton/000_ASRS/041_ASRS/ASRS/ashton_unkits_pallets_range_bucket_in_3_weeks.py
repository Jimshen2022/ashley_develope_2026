import pandas as pd
import os
from pathlib import Path
import math

# 获取Downloads文件夹路径
downloads_path = Path.home() / "Downloads"
file_path = downloads_path / "MIL Unkits Loading Audit - 20250924-4.xlsb"

# 先列出所有sheet名称
with pd.ExcelFile(file_path, engine='pyxlsb') as xls:
    all_sheets = xls.sheet_names
    print("Excel文件中的所有Sheet名称:")
    for i, sheet in enumerate(all_sheets, 1):
        print(f"  {i}. {sheet}")

# 读取Excel文件 - 请根据实际sheet名称修改
# 如果sheet名称不对，请修改下面两行的sheet_name参数
try:
    df_range = pd.read_excel(file_path, sheet_name='Pallet Count in Range', engine='pyxlsb')
except:
    print("\n尝试使用 'Pallet Count in Range' 失败，请从上面的列表中选择正确的sheet名称")
    raise

try:
    df_data = pd.read_excel(file_path, sheet_name='Unkits Cnt Loading Sequence', engine='pyxlsb')
except:
    print("\n尝试使用 'Unkits Cnt Loading Sequence' 失败，请从上面的列表中选择正确的sheet名称")
    raise

# 先查看df_range的内容
print("\n'Pallet Count in Range' sheet的前5行内容:")
print(df_range.head())
print(f"\nShape: {df_range.shape}")
print(f"\nColumns: {df_range.columns.tolist()}")

# 获取YearWeek范围 - YearWeek在列名中
week_start = df_range.columns[1]  # 第二列的列名：202519
week_end = df_range.columns[2]  # 第三列的列名：202539

print(f"\nYearWeek Range: {week_start} to {week_end}")

# 筛选在YearWeek范围内的数据
df_filtered = df_data[(df_data['YearWeek'] >= week_start) & (df_data['YearWeek'] <= week_end)]

print(f"筛选后的数据行数: {len(df_filtered)}")

# 获取所有唯一的YearWeek并排序
all_weeks = sorted(df_filtered['YearWeek'].unique())
print(f"周次列表: {all_weeks}")

# 按每3周分组创建buckets
buckets = []
for i in range(0, len(all_weeks), 3):
    bucket_weeks = all_weeks[i:i + 3]
    bucket_name = f"{bucket_weeks[0]}-{bucket_weeks[-1]}"
    buckets.append({
        'bucket_name': bucket_name,
        'weeks': bucket_weeks
    })

print(f"\n共创建 {len(buckets)} 个bucket:")
for b in buckets:
    print(f"  {b['bucket_name']}: {b['weeks']}")

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

# 创建结果DataFrame
all_results = []

# 对每个bucket进行统计
for bucket in buckets:
    bucket_name = bucket['bucket_name']
    bucket_weeks = bucket['weeks']

    # 筛选该bucket的数据
    df_bucket = df_filtered[df_filtered['YearWeek'].isin(bucket_weeks)]

    print(f"\n处理 Bucket: {bucket_name}, 数据行数: {len(df_bucket)}")

    # 对每个区间进行统计
    for min_val, max_val, label in ranges:
        # 按ITEM_NUMBER分组，先加总Pallet Qty
        item_totals = df_bucket.groupby('ITEM_NUMBER')['Pallet Qty'].sum()

        # 去掉小数，如果有小数部分则向上取整
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

        all_results.append({
            'Bucket': bucket_name,
            'Pallet Count Range': label,
            'SKUs': skus_count,
            'Pallet Counted': pallet_counted
        })

# 创建结果DataFrame
df_results = pd.DataFrame(all_results)

# 透视表格式，便于查看
df_pivot_skus = df_results.pivot(index='Pallet Count Range', columns='Bucket', values='SKUs')
df_pivot_pallets = df_results.pivot(index='Pallet Count Range', columns='Bucket', values='Pallet Counted')

print("\n=== SKUs统计 ===")
print(df_pivot_skus)
print("\n=== Pallet Counted统计 ===")
print(df_pivot_pallets)

# 写入新的Excel sheet
try:
    with pd.ExcelFile(file_path, engine='pyxlsb') as xls:
        existing_sheets = xls.sheet_names

    # 使用openpyxl引擎写入（因为pyxlsb不支持写入）
    # 先读取所有现有sheets
    sheets_dict = {}
    for sheet in existing_sheets:
        sheets_dict[sheet] = pd.read_excel(file_path, sheet_name=sheet, engine='pyxlsb')

    # 创建新的sheet名称
    new_sheet_name = 'Pallet Analysis by 3-Week Bucket'

    # 写入所有sheets（包括新的）
    with pd.ExcelWriter(file_path.with_suffix('.xlsx'), engine='openpyxl') as writer:
        # 写入原有sheets
        for sheet_name, sheet_df in sheets_dict.items():
            sheet_df.to_excel(writer, sheet_name=sheet_name, index=False)

        # 创建汇总sheet
        row = 0
        df_results.to_excel(writer, sheet_name=new_sheet_name, startrow=row, index=False)

        row += len(df_results) + 3

        # 写入SKUs透视表
        pd.DataFrame({'': ['=== SKUs by Bucket ===']}).to_excel(writer, sheet_name=new_sheet_name,
                                                                startrow=row, index=False, header=False)
        row += 1
        df_pivot_skus.to_excel(writer, sheet_name=new_sheet_name, startrow=row)

        row += len(df_pivot_skus) + 3

        # 写入Pallet Counted透视表
        pd.DataFrame({'': ['=== Pallet Counted by Bucket ===']}).to_excel(writer, sheet_name=new_sheet_name,
                                                                          startrow=row, index=False, header=False)
        row += 1
        df_pivot_pallets.to_excel(writer, sheet_name=new_sheet_name, startrow=row)

    print(f"\n结果已写入新文件: {file_path.with_suffix('.xlsx')}")
    print(f"新增Sheet: '{new_sheet_name}'")

except Exception as e:
    print(f"\n写入Excel时出错: {e}")
    print("\n结果数据（可手动复制）:")
    print("\n原始数据:")
    print(df_results.to_string())
    print("\n\nSKUs透视表:")
    print(df_pivot_skus.to_string())
    print("\n\nPallet Counted透视表:")
    print(df_pivot_pallets.to_string())