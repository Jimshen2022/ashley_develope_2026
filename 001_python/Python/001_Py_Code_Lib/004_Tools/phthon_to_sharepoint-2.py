import msal
import requests

client_id = "ed4fb8e4-fb86-4e03-90b4-96777df975c1"
tenant_id = "5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d"
authority_url = f"https://login.microsoftonline.com/{tenant_id}"

# ✅ 不要加 'offline_access'，否则会报错
scopes = ["Files.ReadWrite.All", "Sites.ReadWrite.All"]

app = msal.PublicClientApplication(client_id=client_id, authority=authority_url)
result = app.acquire_token_interactive(scopes=scopes)

if "access_token" in result:
    print("✅ 登录成功")

    # 文件上传部分（用你自己的 SharePoint 文档库路径）
    upload_url = "https://graph.microsoft.com/v1.0/sites/root:/sites/AsiaWarehouseOperations/Shared Documents/test.txt:/content"
    headers = {
        "Authorization": f"Bearer {result['access_token']}",
        "Content-Type": "text/plain"
    }
    data = "This is a test file from Python."
    response = requests.put(upload_url, headers=headers, data=data.encode("utf-8"))

    if response.status_code in [200, 201]:
        print("✅ 文件上传成功")
    else:
        print("❌ 上传失败:", response.status_code, response.text)

else:
    print("❌ 登录失败:", result.get("error_description"))
