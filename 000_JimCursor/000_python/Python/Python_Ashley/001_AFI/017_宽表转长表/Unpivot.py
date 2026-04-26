import os
import pandas as pd
from datetime import datetime, timedelta

# 自动获取 Downloads 路径
downloads_folder = os.path.expanduser("~/Downloads")

# 输入输出文件名
input_file = "MIL RM_WH_INVENTORY_WEEKS_REPORT_V01(Email).csv"
output_file = "MIL_RM_WH_INVENTORY_WEEKS_REPORT_TRANSFORMED.csv"

# 构建完整路径
file_path = os.path.join(downloads_folder, input_file)
output_path = os.path.join(downloads_folder, output_file)

# 读取 CSV
df = pd.read_csv(file_path)

# 宽表转长表
df_long = df.melt(id_vars=["Area", "Category"], var_name="week_code", value_name="inventory_weeks")

# 函数：将 WW01 转为 yyyyww 格式
def week_code_to_yyyyww(week_code, year=2025):
    try:
        week_num = int(week_code.replace("WW", ""))
        return f"{year}{str(week_num).zfill(2)}"
    except:
        return None

# 函数：将 WW01 转为该周周六的日期
def week_code_to_saturday(week_code, year=2025):
    try:
        week_num = int(week_code.replace("WW", ""))
        first_day = datetime(year, 1, 1)
        first_monday = first_day + timedelta(days=(7 - first_day.weekday()) % 7)
        saturday = first_monday + timedelta(weeks=week_num - 1, days=5)
        return saturday.strftime("%Y-%m-%d")
    except:
        return None

# 应用函数
df_long["refresh_date"] = df_long["week_code"].apply(week_code_to_saturday)
df_long["year_week_number"] = df_long["week_code"].apply(week_code_to_yyyyww)

# 整理列顺序
df_final = df_long[["Area", "Category", "refresh_date", "year_week_number", "inventory_weeks"]]

# 输出 CSV
df_final.to_csv(output_path, index=False)
print("✅ 转换完成，文件已保存到：", output_path)
