
import pandas as pd
from datetime import datetime

# 输入数据
df_trx = p_trx
df_dest = p_dest
df_src = p_src
df_onh = p_onh
df_cls = p_cls

# 当前时间
refresh_dt = datetime.now()
refresh_str = refresh_dt.strftime('%Y-%m-%d %H:%M:%S')
iso_year, iso_week, _ = refresh_dt.isocalendar()
year_week = f'{iso_year}{iso_week:02d}'

# 清洗数据：字符串标准化
df_cls['ITCLS'] = df_cls['ITCLS'].astype(str).str.strip()
df_onh['ITCLS'] = df_onh['ITCLS'].astype(str).str.strip()
df_trx['NLLOC'] = df_trx['NLLOC'].astype(str).str.strip()
df_trx['LLOCN'] = df_trx['LLOCN'].astype(str).str.strip()
df_dest_list = df_dest.iloc[:, 0].dropna().astype(str).str.strip().unique().tolist()
df_src_list = df_src.iloc[:, 0].dropna().astype(str).str.strip().unique().tolist()

# 过滤交易数据
df_trx_filtered = df_trx[df_trx['NLLOC'].isin(df_dest_list) & ~df_trx['LLOCN'].isin(df_src_list)]

# 连接 Area, Group 到库存表
df_onh = df_onh.merge(
    df_cls[['ITCLS', 'Area', 'Group']],
    how='left',
    on='ITCLS'
)
df_onh['Area'] = df_onh['Area'].fillna('Check')
df_onh['Category'] = df_onh['Group'].fillna('Check')  # 用 Group 作为 Category 字段
df_onh.drop(columns=['Group'], inplace=True)

# 汇总库存：Onhand
df_onh_summary = df_onh.groupby(['Area', 'Category'], as_index=False)['LQNTY'].sum()
df_onh_summary.rename(columns={'LQNTY': 'Onhand'}, inplace=True)

# 连接 Area, Group 到交易数据
df_trx_filtered = df_trx_filtered.merge(
    df_cls[['ITCLS', 'Area', 'Group']],
    how='left',
    on='ITCLS'
)
df_trx_filtered['Area'] = df_trx_filtered['Area'].fillna('Check')
df_trx_filtered['Category'] = df_trx_filtered['Group'].fillna('Check')  # 用 Group 作为 Category 字段
df_trx_filtered.drop(columns=['Group'], inplace=True)

# 汇总交易数据：按 Area, Category 统计平均使用
df_trx_grouped = df_trx_filtered.groupby(['Area', 'Category'], as_index=False)['TRQTY'].sum()
df_trx_grouped['Avg. usage last 4 weeks'] = (df_trx_grouped['TRQTY'] / 4).round(2)
df_trx_grouped.drop(columns=['TRQTY'], inplace=True)

# 合并库存与使用数据
result = pd.merge(df_onh_summary, df_trx_grouped, on=['Area', 'Category'], how='outer')

# 保留两位小数
result['Onhand'] = result['Onhand'].fillna(0).round(2)
result['Avg. usage last 4 weeks'] = result['Avg. usage last 4 weeks'].fillna(0).round(2)

# 计算库存周数
result['Inventory weeks'] = result.apply(
    lambda row: round(row['Onhand'] / row['Avg. usage last 4 weeks'], 2) if row['Avg. usage last 4 weeks'] != 0 else None,
    axis=1
)

# 添加 refresh 时间 与 年周字段
result['refresh_date_time'] = refresh_str
result['year_week_number'] = year_week

# 最终字段排序
result = result[['Area', 'Category', 'Onhand', 'Avg. usage last 4 weeks', 'Inventory weeks', 'refresh_date_time', 'year_week_number']]
