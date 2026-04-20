from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.client_credential import ClientCredential
import pandas as pd
import os
from datetime import datetime

# --------- 配置参数 ----------
site_url = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations"
client_id = "ed4fb8e4-fb86-4e03-90b4-96777df975c1"
client_secret = "~wA8Q~dKw6EWRvlF3MxLhotisxgBqAHhKMWWGa~_"  # 请替换为从 Azure Portal 复制的实际 client_secret VALUE
target_folder = "/sites/AsiaWarehouseOperations/Shared Documents"
local_file_path = "data.csv"
upload_filename = "uploaded_data.csv"


# ----------------------------

def create_test_data():
    """创建测试数据"""
    df = pd.DataFrame({
        'Product': ['Product_A', 'Product_B', 'Product_C', 'Product_D'],
        'Qty': [10, 20, 30, 40],
        'Price': [100.5, 200.0, 150.75, 300.25],
        'Date': [datetime.now().strftime('%Y-%m-%d %H:%M:%S')] * 4
    })
    df.to_csv(local_file_path, index=False, encoding='utf-8')
    print(f"✅ 测试数据已创建: {local_file_path}")
    return df


def upload_to_sharepoint():
    """上传文件到 SharePoint"""
    try:
        # 1. 创建身份验证凭据
        credentials = ClientCredential(client_id, client_secret)

        # 2. 创建 SharePoint 上下文
        ctx = ClientContext(site_url).with_credentials(credentials)

        # 3. 验证连接
        web = ctx.web
        ctx.load(web)
        ctx.execute_query()
        print(f"✅ 成功连接到 SharePoint 站点: {web.title}")

        # 4. 读取本地文件
        if not os.path.exists(local_file_path):
            print(f"❌ 本地文件不存在: {local_file_path}")
            return False

        with open(local_file_path, "rb") as file:
            file_content = file.read()

        # 5. 获取目标文件夹
        target_folder_obj = ctx.web.get_folder_by_server_relative_url(target_folder)

        # 6. 上传文件
        upload_result = target_folder_obj.upload_file(upload_filename, file_content)
        ctx.execute_query()

        print(f"✅ 文件上传成功!")
        print(f"   - 文件路径: {upload_result.serverRelativeUrl}")
        print(f"   - 文件大小: {len(file_content)} bytes")

        return True

    except Exception as e:
        print(f"❌ 上传失败: {str(e)}")
        return False


def main():
    """主函数"""
    print("=" * 50)
    print("SharePoint 文件上传工具")
    print("=" * 50)

    # 创建测试数据
    df = create_test_data()
    print(f"数据预览:\n{df.head()}")

    # 上传到 SharePoint
    success = upload_to_sharepoint()

    if success:
        print("\n🎉 任务完成!")
    else:
        print("\n❌ 任务失败，请检查配置和权限")

    # 清理临时文件
    if os.path.exists(local_file_path):
        os.remove(local_file_path)
        print(f"🧹 临时文件已清理: {local_file_path}")


if __name__ == "__main__":
    main()