import pandas as pd

# 读取 Excel 文件（请替换为你的实际文件路径）
file_path = "Item avg. cubic feet.xlsx"
df = pd.read_excel(file_path, sheet_name='Sheet1')

# 计算每个物料的总立方英尺（数量 × 单位立方英尺）
df['total_volume_cuft'] = df['Onhand'] * df['UnitCubic feet']

# 求加权平均体积（立方英尺）
total_volume = df['total_volume_cuft'].sum()
total_onhand = df['Onhand'].sum()
weighted_avg_cuft = total_volume / total_onhand

# 换算为 CBM（立方米）
weighted_avg_cbm = weighted_avg_cuft * 0.0283168

# 输出结果
print(f"加权平均体积（cubic feet）: {weighted_avg_cuft:.3f}")
print(f"加权平均体积（CBM）: {weighted_avg_cbm:.5f}")
