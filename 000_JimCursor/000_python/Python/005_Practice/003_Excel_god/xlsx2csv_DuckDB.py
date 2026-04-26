from pathlib import Path
from fast_excel_duckdb import fast_load_duckdb

downloads = Path.home() / "Downloads"
xlsx = downloads / "HJ_4W_SHIPPED.xlsx"

# 只读第一个 sheet；下次基本“秒开”
df = fast_load_duckdb(xlsx, sheet_name=0)
print(df.shape)

# 如果只要部分列（更快）
# df = fast_load_duckdb(xlsx, sheet_name=0, columns=["ColA","ColB"])
