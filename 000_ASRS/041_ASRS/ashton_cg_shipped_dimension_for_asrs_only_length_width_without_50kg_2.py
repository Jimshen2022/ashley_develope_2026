import pandas as pd
import numpy as np

# 1. 您的本地文件路径
input_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_Unkits_Ashton_Shipped_Details_with_Tihi_20260120.xlsx"
output_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_DATA_Final_Ultimate.csv"

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
df['unit_weight(kg)'] = (df['unit_weight(lbs)'] * 0.453592).round(2)

# ==========================================
# 任务 C：精准细分拒绝原因 (Detailed Check for 950x750 & 50kg)
# ==========================================
print("正在诊断 950x750 托盘的超标原因...")


def detailed_check(row):
    l = row['length(mm)']
    w = row['width(mm)']
    kg = row['unit_weight(kg)']
    if pd.isna(l) or pd.isna(w) or pd.isna(kg): return "Unknown"

    reasons = []
    if l > 950: reasons.append("Length")
    if w > 750: reasons.append("Width")
    if kg > 50: reasons.append("Weight")

    if not reasons:
        return "Yes (Fits All)"
    else:
        return "No (Exceeds " + " & ".join(reasons) + ")"


df['Fits_950x750_Detailed'] = df.apply(detailed_check, axis=1)

# ==========================================
# 任务 D：基于 length(mm) 的 80/20 区间分类
# ==========================================
print("正在进行基于长度的 80/20 货位尺寸划分...")


def classify_length(length):
    if pd.isna(length): return "Unknown"

    if length <= 1950:
        return "Standard (80%) <= 1950 mm"
    elif length <= 2350:
        return "Large (18%) 1950 - 2350 mm"
    else:
        return "Oversized (2%) > 2350 mm"


df['Length_Range_80_20'] = df['length(mm)'].apply(classify_length)

# ==========================================
# 保存结果
# ==========================================
df.to_csv(output_file, index=False, encoding='utf-8-sig')
print("\n处理完成！")

# 打印最终分类统计结果给您审阅
print("\n--- Length(mm) 80/20 占比统计 ---")
print(df['Length_Range_80_20'].value_counts())
print("\n占比(%)：")
print((df['Length_Range_80_20'].value_counts(normalize=True).round(4) * 100))

print(f"\n文件已成功保存至: {output_file}")