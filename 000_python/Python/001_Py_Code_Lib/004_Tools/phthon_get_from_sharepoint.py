from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.user_credential import UserCredential
import io
import pandas as pd

# -------- 配置参数 --------
site_url = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations"
username = "jishen@wanvogfurniture.com"
password = "abcde@234567"  # ✅ 明文密码仅用于测试
file_url = "/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/BI_UPLOADED/ExportedData.xlsx"
# -------------------------

# 登录并创建上下文
ctx = ClientContext(site_url).with_credentials(UserCredential(username, password))

# 创建内存缓冲区（准备接收下载内容）
download_stream = io.BytesIO()

# 下载文件到内存
file = ctx.web.get_file_by_server_relative_url(file_url)
file.download(download_stream)
ctx.execute_query()

# 读取 Excel 内容
download_stream.seek(0)  # 重置指针到流的开始位置
df = pd.read_excel(download_stream)

# 显示数据
print(df)
