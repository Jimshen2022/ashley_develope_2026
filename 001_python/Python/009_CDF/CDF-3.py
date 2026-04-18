import pandas as pd
import time
from pathlib import Path
from datetime import datetime

# ========== 自动识别 Downloads 路径 ==========
downloads_path = Path.home() / "Downloads"

# 输入 / 输出文件
input_filename = "Inbound and outbound CDF count - 20251106-2.xlsx"
input_path = downloads_path / input_filename

# 输出文件名加时间戳
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"Inbound_Outbound_Summary_{timestamp}.xlsx"
output_path = downloads_path / output_filename

# ========== 越南文 -> 英文列名映射 ==========
VN2EN = {
    "STT": "No",
    "Số TK nhập": "Customs Declaration No",
    "Ngày TK": "Declaration Date",
    "Số hợp đồng": "Contract No",
    "Ngày hợp đồng": "Contract Date",
    "Số phiếu": "Receipt No",
    "Ngày phiếu": "Receipt Date",
    "Chứng từ nội bộ": "Internal Doc No",
    "Tổng số kiện": "Total Packages",
    "Người nhận hàng": "Consignee",
    "Người giao hàng": "Shipper",
    "Mã hàng": "Item Code",
    "Tên hàng": "Item Name",
    "Xuất xứ": "Origin",
    "Lượng": "Quantity",
    "Đơn vị tính": "Unit",
    "Trọng lượng GW": "Gross Weight",
    "Trọng lượng NW": "Net Weight",
    "Trị Giá": "Value (USD)",
    "Ngày nhập kho": "Inbound Date",
    "Ngày xuất kho": "Outbound Date",
    "Số container": "Container No",
    "Số tờ khai/CT": "Customs Form No",
    "Ngày tờ khai": "Declaration Form Date",
}

# ========== 日期解析函数 ==========
def parse_date(v):
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

# ========== 添加英文表头行 ==========
def add_english_header_row(df):
    eng_row = {col: VN2EN.get(col, "") for col in df.columns}
    header_df = pd.DataFrame([eng_row])
    header_df = header_df[df.columns]
    return pd.concat([header_df, df], ignore_index=True)

# ========== 主程序 ==========
start = time.time()
print(f"📂 正在读取文件: {input_path}")

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

# ===== Outbound：按报关单号取最早 Ngày xuất kho =====
out_min = (
    pd.DataFrame({
        "Số TK nhập": df_out["Số TK nhập"],
        "min_date": df_out["Ngày xuất kho"].map(parse_date)
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

# ===== 在表头插入英文行 =====
df_in_with_header = add_english_header_row(df_in)
df_out_with_header = add_english_header_row(df_out)

# ===== 导出 Excel =====
with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
    df_in_with_header.to_excel(writer, sheet_name="Inbound", index=False)
    df_out_with_header.to_excel(writer, sheet_name="Outbound", index=False)
    summary.to_excel(writer, sheet_name="Summary", index=False)

elapsed = round(time.time() - start, 2)
print(f"✅ 汇总完成！输出文件：{output_path}")
print(f"⏱️ 用时：{elapsed} 秒")
