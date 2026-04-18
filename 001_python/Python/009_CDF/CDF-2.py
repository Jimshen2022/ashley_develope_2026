import pandas as pd
import time
from pathlib import Path
from datetime import datetime

# ========== 自动识别 Downloads 路径 ==========
downloads_path = Path.home() / "Downloads"

# 输入文件名（保持原名）
input_filename = "Inbound and outbound CDF count - 20251106-2.xlsx"
input_path = downloads_path / input_filename

# 输出文件名自动加时间戳
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"Inbound_Outbound_Summary_{timestamp}.xlsx"
output_path = downloads_path / output_filename

# ========== 日期解析函数 ==========
def parse_date(v):
    """支持 Excel 数值日期 或 dd/mm/yyyy 格式"""
    if pd.isna(v):
        return pd.NaT
    s = str(v).strip()
    if s.isdigit():
        try:
            return pd.to_datetime(float(s), origin="1899-12-30", unit="D")
        except Exception:
            return pd.NaT
    try:
        return pd.to_datetime(s, format="%d/%m/%Y", errors="coerce")
    except Exception:
        return pd.NaT

# ========== 主程序 ==========
start = time.time()

print(f"📂 读取文件: {input_path}")

# 读取两个工作表
df_in = pd.read_excel(input_path, sheet_name="Inbound")
df_out = pd.read_excel(input_path, sheet_name="Outbound")

# ===== Inbound：按报关单号取最早 Ngày TK =====
in_min = (
    pd.DataFrame({
        "Số TK nhập": df_in["Số TK nhập"],
        "min_date": df_in["Ngày TK"].map(parse_date)
    })
    .dropna(subset=["min_date"])
    .groupby("Số TK nhập", as_index=False)["min_date"]
    .min()
)
inbound_daily = (
    in_min.groupby(in_min["min_date"].dt.date)
    .size()
    .reset_index(name="Inbound_Count")
)

# ===== Outbound：按报关单号取最早 Ngày tờ khai =====
out_min = (
    pd.DataFrame({
        "Số TK nhập": df_out["Số TK nhập"],
        "min_date": df_out["Ngày tờ khai"].map(parse_date)
    })
    .dropna(subset=["min_date"])
    .groupby("Số TK nhập", as_index=False)["min_date"]
    .min()
)
outbound_daily = (
    out_min.groupby(out_min["min_date"].dt.date)
    .size()
    .reset_index(name="Outbound_Count")
)

# ===== 合并汇总 =====
summary = pd.merge(inbound_daily, outbound_daily, on="min_date", how="outer").fillna(0)
summary = summary.rename(columns={"min_date": "Date"}).sort_values("Date")
summary["Inbound_Count"] = summary["Inbound_Count"].astype(int)
summary["Outbound_Count"] = summary["Outbound_Count"].astype(int)

# ===== 导出 Excel =====
with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
    df_in.to_excel(writer, sheet_name="Inbound", index=False)
    df_out.to_excel(writer, sheet_name="Outbound", index=False)
    summary.to_excel(writer, sheet_name="Summary", index=False)

elapsed = round(time.time() - start, 2)
print(f"✅ 汇总完成！输出文件：{output_path}")
print(f"⏱️ 用时：{elapsed} 秒")
