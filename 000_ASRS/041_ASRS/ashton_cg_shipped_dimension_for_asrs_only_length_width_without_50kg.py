import pandas as pd
import numpy as np

# 1. 您的本地文件路径
input_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_Unkits_Ashton_Shipped_Details_with_Tihi_20260120.xlsx"
output_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_DATA_Detailed_Reasons.csv"

# 2. 读取数据
print("正在读取 Excel 文件，请稍候...")
df = pd.read_excel(input_file, sheet_name='DATA')

# ==========================================
# 任务 A：计算每日去重 SKU_COUNT_2
# ==========================================
print("正在计算 SKU_COUNT_2...")
df['SKU_COUNT_2'] = (~df.duplicated(subset=['Shift_Date', 'item_number'])).astype(int)

# ==========================================
# 任务 B：尺寸(mm)与重量(kg)转换
# ==========================================
print("正在转换单位...")
L_mm_raw = df['length(inch)'] * 25.4
W_mm_raw = df['width(inch)'] * 25.4
H_mm_raw = df['height(inch)'] * 25.4

# 长=最大值, 高=最小值, 宽=中间值
df['length(mm)'] = np.maximum.reduce([L_mm_raw, W_mm_raw, H_mm_raw]).round(2)
df['height(mm)'] = np.minimum.reduce([L_mm_raw, W_mm_raw, H_mm_raw]).round(2)
df['width(mm)'] = (L_mm_raw + W_mm_raw + H_mm_raw - df['length(mm)'] - df['height(mm)']).round(2)
# 重量换算
df['unit_weight(kg)'] = (df['unit_weight(lbs)'] * 0.453592).round(2)

# ==========================================
# 任务 C：精准细分拒绝原因 (Detailed Check)
# ==========================================
print("正在对不符合 950*750*50kg 标准的货物进行死因诊断...")


def detailed_check(row):
    l = row['length(mm)']
    w = row['width(mm)']
    kg = row['unit_weight(kg)']

    # 防错处理
    if pd.isna(l) or pd.isna(w) or pd.isna(kg):
        return "Unknown"

    reasons = []  # 用一个空列表来收集所有的“罪状”

    # 判断各项是否超标
    if l > 950:
        reasons.append("Length")
    if w > 750:
        reasons.append("Width")
    if kg > 50:
        reasons.append("Weight")

    # 如果列表是空的，说明全过关了
    if not reasons:
        return "Yes (Fits All)"
    else:
        # 如果有超标，用 '&' 把原因串联起来
        return "No (Exceeds " + " & ".join(reasons) + ")"


# 生成诊断细分列
df['Fits_950x750_Detailed'] = df.apply(detailed_check, axis=1)

# ==========================================
# 3. 结果保存
# ==========================================
df.to_csv(output_file, index=False, encoding='utf-8-sig')
print("\n处理完成！")

# 打印分布结果供您参考
print("\n--- 超标原因细分统计 (Rejection Reasons) ---")
print(df['Fits_950x750_Detailed'].value_counts())

print(f"\n文件已成功保存至: {output_file}")