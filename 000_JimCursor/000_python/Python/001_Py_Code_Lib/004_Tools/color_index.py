import matplotlib.pyplot as plt
import csv
import os
from datetime import datetime

# 获取默认颜色列表
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']

# 生成时间戳字符串
timestamp = datetime.now().strftime('%Y%m%d_%H%M')

# 构建文件名
filename = f'color_index_{timestamp}.csv'

# 获取用户的 Downloads 文件夹路径
downloads_folder = os.path.join(os.path.expanduser("~"), "Downloads")
filepath = os.path.join(downloads_folder, filename)

# 写入 CSV 文件，颜色在第 3 列（即 Excel 中的 C列）
with open(filepath, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Index', '', 'Color'])  # 表头：A列, B列空, C列
    for idx, color in enumerate(colors):
        writer.writerow([idx, '', color])  # 中间列留空

print(f'颜色索引文件已保存到: {filepath}')
