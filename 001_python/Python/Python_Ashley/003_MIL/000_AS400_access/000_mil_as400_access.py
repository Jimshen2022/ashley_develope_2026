import pandas as pd
import re
import xlwings as xw

# ✅ Step 1: 读取 .xlsb 数据
xlsb_path = r"D:\Documents\13-SYS ACCESS\MAPICS ACCESS APPLICATION - MIL AS400 BADGE SCAN.xlsb"
df_raw = pd.read_excel(xlsb_path, sheet_name="Sheet2", usecols="A", engine="pyxlsb", header=None)
df_raw.dropna(inplace=True)
lines = df_raw[0].astype(str).tolist()

# ✅ Step 2: 提取结构化数据
records = []
record = {"Name": "", "Current Password": "", "Badge Number": ""}

for line in lines:
    line = line.strip()

    if re.match(r"^[A-Z ]+$", line) and "PASSWORD" not in line and "BADGE" not in line:
        if record["Name"]:
            records.append(record)
            record = {"Name": "", "Current Password": "", "Badge Number": ""}
        record["Name"] = line

    elif "Current Password" in line:
        m = re.search(r"Current Password:?\s*([A-Z0-9]+)", line)
        if m:
            record["Current Password"] = m.group(1)

    elif "Badge Number" in line:
        m = re.search(r"Badge Number:?\s*(\d+)", line)
        if m:
            record["Badge Number"] = m.group(1)

if record["Name"]:
    records.append(record)

df_final = pd.DataFrame(records)

# 补 0 到 5 位字符串
df_final["Badge Number"] = df_final["Badge Number"].astype(str).str.zfill(5)

# ✅ Step 3: 添加 No 列，作为编号（从1开始）
df_final.insert(0, "No", range(1, len(df_final) + 1))

# ✅ Step 4: 写入 Sheet3，并应用格式
wb_path = r"D:\Documents\13-SYS ACCESS\MAPICS ACCESS APPLICATION - MIL AS400 BADGE SCAN.xlsb"

app = xw.App(visible=False)
wb = xw.Book(wb_path)
sheet = wb.sheets["Sheet3"]

# 清空表格
sheet.clear()

badge_col_letter = 'D'
sheet.range(f"{badge_col_letter}:{badge_col_letter}").number_format = "@"

# 写入数据（不带 pandas index）
sheet.range("A1").options(index=False).value = df_final

# 获取写入区域范围
nrows, ncols = df_final.shape
header_range = sheet.range((1, 1), (1, ncols))  # A1 到 最后一列表头

# ✅ 表头加粗
header_range.api.Font.Bold = True

# ✅ 冻结首行
sheet.api.Activate()
sheet.api.Application.ActiveWindow.SplitRow = 1
sheet.api.Application.ActiveWindow.FreezePanes = True

# ✅ 自动筛选（推荐写法）
sheet.activate()
table_range = sheet.range((1, 1), (nrows + 1, ncols))
table_range.api.AutoFilter(Field=1)


# ✅ 自动列宽（对所有列进行自动调整）
sheet.range("A1").expand().columns.autofit()

# app.quit()
wb.save()
print("✅ 写入 Sheet3 成功，并完成：表头加粗、冻结首行、筛选、列宽自适应！")
