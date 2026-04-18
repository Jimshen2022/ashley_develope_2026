import pandas as pd

df = pd.read_excel(r'd:\python_file\OH.xlsx')

# 插入列
df.insert(3, 'locations', '99')

# 插入行
# 将文件分成上下两部分，再用append
df1 = df.loc[:5]
df2 = df.loc[6:]

# 用append连接
s = pd.DataFrame([['7599999', '335', 'zusu', 99, 999, 'fa00', '99-9', 'CHAIR-TEST']], columns=df.columns)
df3 = df1.append(s, ignore_index=True)
df4 = df3.append(df2, ignore_index=True)
print(df4)

# 9.4.3 更改数据
df4.loc[1, 'HOUSE'] = 336    # 更改第2行house的数据
df5 = df4.head(5)  # 取前5行

# 复制
df6 = df5.copy()

print(df6.info())

