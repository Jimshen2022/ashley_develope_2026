import matplotlib.pyplot as plt

# 数据提取
pallet_qty = [126, 134, 101, 156, 101, 85, 122, 111, 143, 167, 235, 155,
              73, 37, 24, 55, 144, 73, 114, 122, 127, 94, 83, 146, 135, 100, 186, 113]

# 绘制分布图（直方图）
plt.figure(figsize=(8, 5))
plt.hist(pallet_qty, bins=10, color='skyblue', edgecolor='black', alpha=0.7)
plt.title('Distribution of Pallet_Qty', fontsize=14)
plt.xlabel('Pallet_Qty', fontsize=12)
plt.ylabel('Frequency', fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.show()
