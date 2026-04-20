import numpy as np
from openpyxl import Workbook
from pathlib import Path
import os

# 自动获取当前用户 Downloads 文件夹路径
downloads_path = str(Path.home() / "Downloads")
final_file_path = os.path.join(downloads_path, "EOQ_Calculation_Template_English_With_Instructions.xlsx")

# 创建一个新的工作簿
wb = Workbook()

# 数据页（Sheet1）
ws_data = wb.active
ws_data.title = "EOQ Calculation"

# 数据表头
data_headers = [
    "Item Code",
    "Annual Demand (D)",
    "Order Cost per Order (S)",
    "Unit Price",
    "Holding Cost per Unit per Year (H)",
    "EOQ"
]

# 数据内容及计算
data_rows = [
    ["ITEM001", 10000, 100, 10, 10 * 0.2, round(np.sqrt(2 * 10000 * 100 / (10 * 0.2)), 2)],
    ["ITEM002", 5000, 80, 15, 15 * 0.2, round(np.sqrt(2 * 5000 * 80 / (15 * 0.2)), 2)],
    ["ITEM003", 8000, 120, 8, 8 * 0.2, round(np.sqrt(2 * 8000 * 120 / (8 * 0.2)), 2)]
]

# 写入数据页
ws_data.append(data_headers)
for row in data_rows:
    ws_data.append(row)

# 创建说明页（Sheet2）
ws_instructions = wb.create_sheet("Instructions")

description_data = [
    ["Field Name", "Description", "Sample Data", "Formula (if applicable)"],
    ["Item Code", "Optional, used to identify the item", "ITEM-001", "—"],
    ["Annual Demand (D)", "Estimated total usage for the year", "10,000", "—"],
    ["Order Cost (S)", "Fixed cost incurred each time an order is placed", "100", "—"],
    ["Holding Cost (H)", "Annual cost of holding one unit in inventory", "2", "—"],
    ["EOQ", "Economic Order Quantity (calculated result)", "=SQRT(2*B2*C2/D2)", "√(2 × D × S ÷ H)"],
]

# 写入说明页
for row in description_data:
    ws_instructions.append(row)

# 保存文件到用户 Downloads 文件夹
wb.save(final_file_path)

print(f"Excel file saved to: {final_file_path}")
