import pandas as pd
import random
from datetime import datetime, timedelta

# 设置样本数据基础
warehouses = ['WH01', 'WH02', 'WH03']
item_prefixes = ['R', 'C', 'IC', 'T', 'D']
locations = [f"A{row}-{col:02d}" for row in range(1, 21) for col in range(1, 21)]  # A1-01 to A20-20
descriptions = {
    'R': 'Resistor',
    'C': 'Capacitor',
    'IC': 'Integrated Circuit',
    'T': 'Transistor',
    'D': 'Diode'
}
units = ['pcs', 'box']

# 生成10万个库存记录
num_records = 100000
data = []

for i in range(num_records):
    prefix = random.choice(item_prefixes)
    item_number = f"{prefix}{random.randint(1000, 9999)}"
    record = {
        "warehouse": random.choice(warehouses),
        "item_number": item_number,
        "qty": random.randint(1, 1000),
        "location": random.choice(locations),
        "description": descriptions[prefix],
        "unit": random.choice(units),
        "last_updated": (datetime.now() - timedelta(days=random.randint(0, 365))).strftime("%Y-%m-%d")
    }
    data.append(record)

# 创建 DataFrame
df = pd.DataFrame(data)

# 保存为 Excel 文件
file_path = r"C:\Users\jishen\Downloads\electronic_parts_inventory.xlsx"
df.to_excel(file_path, index=False)

file_path
