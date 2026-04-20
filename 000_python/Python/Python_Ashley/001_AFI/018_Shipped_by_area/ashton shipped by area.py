import pandas as pd
import os
from datetime import datetime

# 设置文件路径
file_path = r"C:\Users\jishen\Downloads\data.csv"

# 检查文件是否存在
if not os.path.exists(file_path):
    raise FileNotFoundError(f"文件未找到: {file_path}")

# 读取 CSV，避免 DtypeWarning
df = pd.read_csv(file_path, low_memory=False)

# 转换 INIVDT 为数值型，并筛选 >= 20250501
df["INIVDT"] = pd.to_numeric(df["INIVDT"], errors="coerce")
df = df[df["INIVDT"] >= 20250501]

# 自动生成带时间戳的文件名
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = fr"C:\Users\jishen\Downloads\trip_summary_df_{timestamp}.csv"

# 保存结果
df.to_csv(output_file, index=False)
print(f"\n结果已保存为：{output_file}")


# 转换 ITSHQT 为数值型
df["ITSHQT"] = pd.to_numeric(df["ITSHQT"], errors="coerce")
df = df.dropna(subset=["ITSHQT"])

# 分组统计
result = (
    df.groupby("Trip_Type_2")
    .agg(
        unique_trip_count=("XNTRPN", pd.Series.nunique),
        total_shipped_qty=("ITSHQT", "sum"),
    )
    .assign(avg_pieces_per_trip=lambda x: x["total_shipped_qty"] / x["unique_trip_count"])
    .reset_index()
)

# 打印结果
print(result)

# 自动生成带时间戳的文件名
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = fr"C:\Users\jishen\Downloads\trip_summary_{timestamp}.csv"

# 保存结果
result.to_csv(output_file, index=False)
print(f"\n结果已保存为：{output_file}")
