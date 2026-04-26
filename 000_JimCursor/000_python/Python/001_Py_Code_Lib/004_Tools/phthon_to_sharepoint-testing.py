import requests
import json
import pandas as pd
import io
from urllib.parse import quote

# 配置参数
client_id = "ed4fb8e4-fb86-4e03-90b4-96777df975c1"
client_secret = "~wA8Q~dKw6EWRvlF3MxLhotisxgBqAHhKMWWGa~_"
tenant_id = "masterashley.onmicrosoft.com"  # 这个应该是正确的
site_url = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations"
file_path = "/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/BI_UPLOADED/ExportedData.xlsx"


def get_access_token():
    """获取 SharePoint 访问令牌"""
    print("🔍 获取访问令牌...")

    # 使用正确的 SharePoint 资源 URL
    token_url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"

    data = {
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'scope': 'https://masterashley.sharepoint.com/.default'
    }

    try:
        response = requests.post(token_url, data=data)
        if response.status_code == 200:
            token_data = response.json()
            print("✅ 令牌获取成功")
            return token_data['access_token']
        else:
            print(f"❌ 令牌获取失败: {response.status_code}")
            print(f"错误: {response.text}")
            return None
    except Exception as e:
        print(f"❌ 令牌获取异常: {e}")
        return None


def test_site_access(access_token):
    """测试站点访问"""
    print("\n🔍 测试站点访问...")

    # 正确的请求头格式
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json;odata=nometadata',
        'Content-Type': 'application/json;odata=nometadata'
    }

    # 测试站点基本信息
    api_url = f"{site_url}/_api/web"

    try:
        response = requests.get(api_url, headers=headers)
        print(f"状态码: {response.status_code}")

        if response.status_code == 200:
            site_data = response.json()
            print("✅ 站点访问成功")
            print(f"站点标题: {site_data.get('Title', 'N/A')}")
            print(f"站点URL: {site_data.get('Url', 'N/A')}")
            return True
        else:
            print(f"❌ 站点访问失败: {response.status_code}")
            print(f"响应头: {dict(response.headers)}")
            print(f"错误信息: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 站点访问异常: {e}")
        return False


def test_file_access(access_token):
    """测试文件访问"""
    print("\n🔍 测试文件访问...")

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json;odata=nometadata'
    }

    # 测试文件是否存在
    encoded_path = quote(file_path, safe='/')
    file_info_url = f"{site_url}/_api/web/getfilebyserverrelativeurl('{encoded_path}')"

    try:
        response = requests.get(file_info_url, headers=headers)
        print(f"文件信息请求状态码: {response.status_code}")

        if response.status_code == 200:
            file_data = response.json()
            print("✅ 文件访问成功")
            print(f"文件名: {file_data.get('Name', 'N/A')}")
            print(f"文件大小: {file_data.get('Length', 'N/A')} 字节")
            return True
        else:
            print(f"❌ 文件访问失败: {response.status_code}")
            print(f"错误信息: {response.text}")

            # 尝试不同的路径格式
            alternative_paths = [
                "/Shared Documents/Ashton/Four Box/BI_UPLOADED/ExportedData.xlsx",
                "Shared Documents/Ashton/Four Box/BI_UPLOADED/ExportedData.xlsx"
            ]

            for alt_path in alternative_paths:
                print(f"\n尝试路径: {alt_path}")
                encoded_alt_path = quote(alt_path, safe='/')
                alt_url = f"{site_url}/_api/web/getfilebyserverrelativeurl('{encoded_alt_path}')"

                alt_response = requests.get(alt_url, headers=headers)
                if alt_response.status_code == 200:
                    print(f"✅ 找到文件: {alt_path}")
                    return True, alt_path
                else:
                    print(f"❌ 路径无效: {alt_path}")

            return False
    except Exception as e:
        print(f"❌ 文件访问异常: {e}")
        return False


def download_file(access_token, file_path_to_use=None):
    """下载文件"""
    print("\n🔍 下载文件...")

    if file_path_to_use is None:
        file_path_to_use = file_path

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/octet-stream'
    }

    # 构建下载 URL
    encoded_path = quote(file_path_to_use, safe='/')
    download_url = f"{site_url}/_api/web/getfilebyserverrelativeurl('{encoded_path}')/$value"

    print(f"下载 URL: {download_url}")

    try:
        response = requests.get(download_url, headers=headers)
        print(f"下载状态码: {response.status_code}")

        if response.status_code == 200:
            print("✅ 文件下载成功")

            # 转换为 DataFrame
            df = pd.read_excel(io.BytesIO(response.content))
            print(f"📊 数据形状: {df.shape}")
            print(f"📋 列名: {list(df.columns)}")
            return df
        else:
            print(f"❌ 文件下载失败: {response.status_code}")
            print(f"错误信息: {response.text}")
            return None
    except Exception as e:
        print(f"❌ 文件下载异常: {e}")
        return None


def list_document_library(access_token):
    """列出文档库内容"""
    print("\n🔍 列出文档库内容...")

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json;odata=nometadata'
    }

    # 列出 Shared Documents 根目录
    lists_url = f"{site_url}/_api/web/lists/getbytitle('Documents')/items"

    try:
        response = requests.get(lists_url, headers=headers)
        if response.status_code == 200:
            items = response.json().get('value', [])
            print(f"✅ 找到 {len(items)} 个项目")
            for item in items[:5]:  # 只显示前5个
                print(f"- {item.get('FileLeafRef', 'N/A')}")
            return True
        else:
            print(f"❌ 列表获取失败: {response.status_code}")
            print(f"错误信息: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 列表获取异常: {e}")
        return False


def main():
    """主函数"""
    print("🚀 开始修复后的 SharePoint 文件下载...")

    # 步骤1: 获取访问令牌
    access_token = get_access_token()
    if not access_token:
        print("❌ 无法获取访问令牌")
        return

    # 步骤2: 测试站点访问
    if not test_site_access(access_token):
        print("❌ 站点访问失败")
        return

    # 步骤3: 列出文档库内容（可选）
    list_document_library(access_token)

    # 步骤4: 测试文件访问
    file_access_result = test_file_access(access_token)
    if isinstance(file_access_result, tuple):
        # 找到了有效路径
        success, valid_path = file_access_result
        if success:
            file_path_to_use = valid_path
        else:
            print("❌ 无法找到有效的文件路径")
            return
    elif file_access_result:
        file_path_to_use = file_path
    else:
        print("❌ 文件访问失败")
        return

    # 步骤5: 下载文件
    df = download_file(access_token, file_path_to_use)
    if df is not None:
        print("\n🎉 文件下载成功！")
        print("\n📊 数据预览:")
        print(df.head())

        # 保存到本地文件（可选）
        output_file = "downloaded_data.xlsx"
        df.to_excel(output_file, index=False)
        print(f"\n💾 数据已保存到: {output_file}")
    else:
        print("\n❌ 文件下载失败")


if __name__ == "__main__":
    main()