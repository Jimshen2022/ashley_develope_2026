from pathlib import Path
from fast_excel_loader import fast_load

downloads = Path.home() / "Downloads"
file_path = downloads / "HJ_4W_SHIPPED.xlsx"

# 首次会构建缓存（可能花一点时间）；后续基本“秒开”
df = fast_load(file_path, prefer="parquet", sheet_name=0)  # or prefer="csv"
print(df.shape)


                
                
                
                