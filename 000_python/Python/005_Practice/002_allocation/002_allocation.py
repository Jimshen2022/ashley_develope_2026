import pandas as pd
from collections import defaultdict
from datetime import datetime

# === Step 1: 读取库存表和需求表 ===
inventory_file = "C:/Users/jishen/Downloads/electronic_parts_inventory.xlsx"
demand_file = "C:/Users/jishen/Downloads/electronic_parts_demand.xlsx"

df = pd.read_excel(inventory_file)
demand_df = pd.read_excel(demand_file)

# === Step 2: 构建库存字典 item_number -> list of stock records ===
inventory_dict = defaultdict(list)
remain_inventory_dict = defaultdict(int)

for _, row in df.iterrows():
    inventory_dict[row['item_number']].append({
        'warehouse': row['warehouse'],
        'location': row['location'],
        'qty': row['qty']
    })
    remain_inventory_dict[row['item_number']] += row['qty']

# === Step 3: 分配库存 ===
allocated_qty_list = []
allocated_details_list = []

for _, row in demand_df.iterrows():
    item = row['item_number']
    requested_qty = row['requested_qty']
    allocated_qty = 0
    allocation_details = []

    if item in inventory_dict:
        for stock in inventory_dict[item]:
            if requested_qty <= 0:
                break
            available_qty = stock['qty']
            if available_qty > 0:
                alloc = min(available_qty, requested_qty)
                stock['qty'] -= alloc
                requested_qty -= alloc
                allocated_qty += alloc
                allocation_details.append(f"{stock['warehouse']}_{stock['location']}_{alloc}")

        remain_inventory_dict[item] = sum(s['qty'] for s in inventory_dict[item])

    allocated_qty_list.append(allocated_qty)
    allocated_details_list.append(", ".join(allocation_details) if allocation_details else "")

# === Step 4: 更新需求表并保存 ===
demand_df['allocated_qty'] = allocated_qty_list
demand_df['allocated_details'] = allocated_details_list
demand_df['remain_inventory_qty'] = demand_df['item_number'].apply(lambda x: remain_inventory_dict[x])

# === Step 5: 保存结果 ===
output_file = "C:/Users/jishen/Downloads/electronic_parts_demand_allocated.xlsx"
demand_df.to_excel(output_file, index=False)

print(f"分配完成，文件已保存至: {output_file}")
