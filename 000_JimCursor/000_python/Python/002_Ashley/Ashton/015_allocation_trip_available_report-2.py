import pandas as pd

# 读取 Excel 文件
file_path = r'C:\Users\jishen\Downloads\Book1.xlsx'  # 替换为你的文件路径
df = pd.read_excel(file_path)


def allocate_fixed_stock(df_group):
    df_group = df_group.sort_values(by=['Dispatch Date', 'Trip Number']).copy()

    # 使用第一行的 Available Sto 作为总库存
    total_available = df_group.iloc[0]['Available Sto']

    # 逐行计算已使用的 Trip Needed - Trip Picked
    used_qty = 0
    allocated_qty = []

    for _, row in df_group.iterrows():
        allocated = max(total_available - used_qty, 0)
        allocated_qty.append(allocated)
        used_qty += (row['Trip Needed'] - row['Trip Picked'])

    df_group['allocated_qty'] = allocated_qty
    return df_group


# 应用逻辑
df_result = df.groupby('Item Number', group_keys=False).apply(allocate_fixed_stock)

# 导出结果
output_path = r'C:\Users\jishen\Downloads\final_allocated_result_fixed_logic.xlsx'
df_result.to_excel(output_path, index=False)

print(f"✅ 分配完成（基于首行库存逻辑），结果保存在：{output_path}")
