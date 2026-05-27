import pandas as pd
import numpy as np

# 1. 读取 Excel 文件中的两个关键 Sheet
file_path = 'Test SKU Update 50 total - 2.xlsx'
test_sku_df = pd.read_excel(file_path, sheet_name='Test SKU')
ashton_items_df = pd.read_excel(file_path, sheet_name='Ashton All Items')

# 2. 类别标准化函数 (例如将 CASEGOODS 统一为 CG)
def normalize_cat(cat):
    if pd.isna(cat): return ""
    cat = str(cat).strip().upper()
    if "CASEGOOD" in cat: return "CG"
    return cat

test_sku_df['Normalized_Cat'] = test_sku_df['Product Type'].apply(normalize_cat)
ashton_items_df['Normalized_Cat'] = ashton_items_df['PRODUCT_CATEGORY'].apply(normalize_cat)

# 3. 筛选出 Ashton 表中真正有库存的产品作为候选
ashton_with_stock = ashton_items_df[ashton_items_df['onhand_qty(May.02 08:00am)'] > 0].copy()

# 4. 循环处理 Test SKU 表中库存为 0 的项目
for idx, row in test_sku_df.iterrows():
    # 如果原表库存为 0 或空
    if row['Ashton OnHand\n(Apr.30 13:08)'] == 0:
        target_l = row['Length（inch)']
        target_w = row[' Width (inches)']
        target_h = row[' Height （inch)']
        target_cat = row['Normalized_Cat']
        
        # 仅在相同类别中寻找
        candidates = ashton_with_stock[ashton_with_stock['Normalized_Cat'] == target_cat].copy()
        
        if not candidates.empty:
            # 计算欧几里得距离 (L, W, H 的综合差异)
            dist = np.sqrt(
                (candidates['CRTLIN(inch)'] - target_l)**2 +
                (candidates['CRTWIN(inch)'] - target_w)**2 +
                (candidates['CRTHIN(inch)'] - target_h)**2
            )
            candidates['distance'] = dist
            
            # 找到距离最小值对应的产品
            best_match = candidates.sort_values('distance').iloc[0]
            
            # 将匹配结果写回原表
            test_sku_df.at[idx, 'Suggested Replacement Item'] = best_match['item_number']