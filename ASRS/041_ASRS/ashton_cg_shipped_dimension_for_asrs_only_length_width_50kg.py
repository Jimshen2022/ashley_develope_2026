import pandas as pd
import numpy as np

# 1. 您的本地文件路径
input_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_Unkits_Ashton_Shipped_Details_with_Tihi_20260120.xlsx"
output_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_DATA_Final_Dimensions_Weight.csv"

# 2. 从 Excel 读取 DATA sheet
print("正在读取 Excel 文件，请稍候...")
df = pd.read_excel(input_file, sheet_name='DATA')

# ==========================================
# 任务 A：计算每日去重 SKU_COUNT_2
# ==========================================
print("正在计算 SKU_COUNT_2...")
df['SKU_COUNT_2'] = (~df.duplicated(subset=['Shift_Date', 'item_number'])).astype(int)

# ==========================================
# 任务 B：长宽高换算为毫米，重量换算为千克
# ==========================================
print("正在进行单位换算与尺寸排序...")
# 先算出所有边长的毫米值
L_mm_raw = df['length(inch)'] * 25.4
W_mm_raw = df['width(inch)'] * 25.4
H_mm_raw = df['height(inch)'] * 25.4

# 新增您要求的列：长(最大值)、高(最小值)、宽(中间值)，并保留 2 位小数
df['length(mm)'] = np.maximum.reduce([L_mm_raw, W_mm_raw, H_mm_raw]).round(2)
df['height(mm)'] = np.minimum.reduce([L_mm_raw, W_mm_raw, H_mm_raw]).round(2)
df['width(mm)'] = (L_mm_raw + W_mm_raw + H_mm_raw - df['length(mm)'] - df['height(mm)']).round(2)

# 新增重量列：磅(lbs) -> 千克(kg) (1 lbs = 0.453592 kg)
df['unit_weight(kg)'] = (df['unit_weight(lbs)'] * 0.453592).round(2)

# ==========================================
# 任务 C：判断是否落入 950*750 & 50kg 区间
# ==========================================
print("正在判断 950x750 & 50kg 限制条件...")


def check_new_standard(row):
    l = row['length(mm)']
    w = row['width(mm)']
    kg = row['unit_weight(kg)']

    # 排除空数据
    if pd.isna(l) or pd.isna(w) or pd.isna(kg):
        return "Unknown"

    # 判断条件：长不超过950，宽不超过750，且单重不超过50kg
    if l <= 950 and w <= 750 and kg <= 50:
        return "Yes (Fits 950*750 & <= 50kg)"
    else:
        return "No (Exceeds Dimensions or Weight)"


# 新增判断列
df['Fits_950x750_50kg'] = df.apply(check_new_standard, axis=1)

# ==========================================
# 保存结果
# ==========================================
df.to_csv(output_file, index=False, encoding='utf-8-sig')
print("\n处理完成！")

# 打印最终统计给您复核
print("\n--- [统计结果] 是否能放入 950*750 (50kg) 托盘 ---")
print(df['Fits_950x750_50kg'].value_counts())

print(f"\n文件已成功保存至: {output_file}")