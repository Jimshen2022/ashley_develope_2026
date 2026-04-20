import pandas as pd

# 创建一个简单的 DataFrame
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35],
    'City': ['New York', 'Los Angeles', 'Chicago']
}

df = pd.DataFrame(data)

# 将 DataFrame 导出到 Excel 文件
df.to_excel('output-2.xlsx', index=False)
