from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.sharepoint.files.file import File
import pandas as pd

# --------- 配置参数 ----------
sharepoint_url = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations"
username = "jishen@wanvogfurniture.com"
password = "abcde@234567"
target_folder = "/sites/AsiaWarehouseOperations/Shared Documents"  # 你的目标文件夹
local_file_path = "data.csv"  # 你准备上传的文件
upload_filename = "uploaded_data.csv"  # 上传到 SharePoint 上的文件名
# ----------------------------

# 1. 模拟抓取数据
df = pd.DataFrame({
    'Product': ['A', 'B', 'C'],
    'Qty': [10, 20, 30]
})
df.to_csv(local_file_path, index=False)

# 2. 登录并上传
ctx_auth = AuthenticationContext(sharepoint_url)
if ctx_auth.acquire_token_for_user(username, password):
    ctx = ClientContext(sharepoint_url, ctx_auth)
    with open(local_file_path, 'rb') as content_file:
        file_content = content_file.read()

    target_folder_obj = ctx.web.get_folder_by_server_relative_url(target_folder)
    target_file = target_folder_obj.upload_file(upload_filename, file_content).execute_query()
    print(f"✅ 文件已上传到: {target_file.serverRelativeUrl}")
else:
    print("❌ 登录失败")


from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.client_credential import ClientCredential
import pandas as pd

# 创建测试 CSV
df = pd.DataFrame({'Product': ['A', 'B', 'C'], 'Qty': [10, 20, 30]})
local_file_path = "data.csv"
df.to_csv(local_file_path, index=False)

# SharePoint配置
site_url = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations"
client_id = "ed4fb8e4-fb86-4e03-90b4-96777df975c1"
client_secret = "be4ca188-11d2-4119-a9dc-d765c81b74c8"
target_folder = "/sites/AsiaWarehouseOperations/Shared Documents"
upload_filename = "uploaded_data.csv"

# 登录 SharePoint
credentials = ClientCredential(client_id, client_secret)
ctx = ClientContext(site_url).with_credentials(credentials)

with open(local_file_path, "rb") as f:
    file_content = f.read()

target_folder_obj = ctx.web.get_folder_by_server_relative_url(target_folder)
upload_result = target_folder_obj.upload_file(upload_filename, file_content).execute_query()

print(f"✅ 文件已上传到: {upload_result.serverRelativeUrl}")
