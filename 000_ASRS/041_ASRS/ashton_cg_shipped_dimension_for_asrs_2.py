import pandas as pd

# 1. 您的本地文件路径
input_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_Unkits_Ashton_Shipped_Details_with_Tihi_20260120.xlsx"
output_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_DATA_Target_Range_with_SKU.csv"

# 2. 从 Excel 读取 DATA sheet
print("正在读取文件，请稍候...")
df = pd.read_excel(input_file, sheet_name='DATA')

# ==========================================
# 逻辑 A：计算 SKU_COUNT_2 (每日去重 SKU)
# ==========================================
# 检查 ['Shift_Date', 'item_number'] 这两列的组合是否是重复出现的
# ~df.duplicated() 会将第一次出现的行标记为 True，之后出现的标记为 False
# .astype(int) 会把 True 变成 1，False 变成 0
print("正在计算每日唯一 SKU (SKU_COUNT_2)...")
df['SKU_COUNT_2'] = (~df.duplicated(subset=['Shift_Date', 'item_number'])).astype(int)

# ==========================================
# 逻辑 B：计算货箱尺寸是否落在目标区间内
# ==========================================
print("正在分类货箱尺寸 (Carton Dimensions Range)...")
# 英寸转毫米
df['L_mm'] = df['length(inch)'] * 25.4
df['W_mm'] = df['width(inch)'] * 25.4
df['H_mm'] = df['height(inch)'] * 25.4

# 对长宽高排序，允许纸箱通过旋转来适应货位
df['Dim1'] = df[['L_mm', 'W_mm', 'H_mm']].max(axis=1)
df['Dim3'] = df[['L_mm', 'W_mm', 'H_mm']].min(axis=1)
df['Dim2'] = df[['L_mm', 'W_mm', 'H_mm']].sum(axis=1) - df['Dim1'] - df['Dim3']


# 定义新字段的划分逻辑
def classify_target(row):
    d1, d2, d3 = row['Dim1'], row['Dim2'], row['Dim3']
    if pd.isna(d1): return "Unknown"

    # 过小 (<= 610*500*80)
    if d1 <= 610 and d2 <= 500 and d3 <= 80:
        return "Carton <= 610*500*80"

    # 落在指定的区间 (Target Range)
    elif d1 <= 950 and d2 <= 900 and d3 <= 730:
        return "Dim:610*500*80 < Carton <= 950*730*900 (L*W*H, mm)"

    # 超出该上限的超大件 (> 950*730*900)
    else:
        return "Carton > 950*730*900"


# 生成尺寸范围新列
df['Carton Dimensions Range'] = df.apply(classify_target, axis=1)

# 清理不再需要的辅助列
df.drop(columns=['L_mm', 'W_mm', 'H_mm', 'Dim1', 'Dim2', 'Dim3'], inplace=True, errors='ignore')

# ==========================================
# 3. 保存并输出结果
# ==========================================
df.to_csv(output_file, index=False, encoding='utf-8-sig')
print("\n处理完成！")

# 打印一些验证数据供您参考
print("\n--- SKU_COUNT_2 每日唯一标识统计 ---")
print(df['SKU_COUNT_2'].value_counts())

print("\n--- 货箱尺寸分类统计 ---")
print(df['Carton Dimensions Range'].value_counts())

print(f"\n文件已成功保存至: {output_file}")