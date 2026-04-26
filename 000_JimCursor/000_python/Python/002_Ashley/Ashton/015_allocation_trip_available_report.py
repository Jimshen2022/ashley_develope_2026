import pandas as pd

# 读取 Excel 文件
file_path = r'C:\Users\jishen\Downloads\Book1.xlsx'  # 替换为你的文件路径
df = pd.read_excel(file_path)


# 定义计算 allocated_qty 的函数
def calculate_allocated(df_group):
    # 按 Dispatch Date 和 Trip Number 排序
    df_group = df_group.sort_values(by=['Dispatch Date', 'Trip Number']).copy()

    max_available = df_group['Available Sto'].max()

    if max_available == 0:
        df_group['allocated_qty'] = 0
        return df_group

    remaining = max_available
    allocated_qty = []

    for _, row in df_group.iterrows():
        needed = row['Trip Needed'] - row['Trip Picked']
        if remaining <= 0:
            allocated_qty.append(0)
        elif remaining >= needed:
            allocated_qty.append(needed)
            remaining -= needed
        else:
            allocated_qty.append(remaining)
            remaining = 0

    df_group['allocated_qty'] = allocated_qty
    return df_group


# 应用函数
df_result = df.groupby('Item Number', group_keys=False).apply(calculate_allocated)

# 导出结果为 Excel（可选）
output_path = 'allocated_result_sorted.xlsx'
df_result.to_excel(output_path, index=False)

print(f"处理完成，结果保存为：{output_path}")
