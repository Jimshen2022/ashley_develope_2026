import pyodbc
import pandas as pd
import os
import time
from datetime import datetime
import webbrowser

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'
connection_string = (
    f"DRIVER={{ODBC Driver 18 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"Authentication=ActiveDirectoryIntegrated;"  # 使用 Azure AD 集成验证
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=120;"
)


def create_html_view(df, html_path, csv_path):
    """创建一个美观的HTML视图，包含下载按钮"""
    # 获取CSV文件名称（不含路径）
    csv_filename = os.path.basename(csv_path)

    html_content = f"""
    <!DOCTYPE html>
    <html lang="zh">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>数据预览</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 20px; }}
            table {{ border-collapse: collapse; width: 100%; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
            th {{ background-color: #f2f2f2; position: sticky; top: 0; }}
            tr:nth-child(even) {{ background-color: #f9f9f9; }}
            tr:hover {{ background-color: #f1f1f1; }}
            .container {{ max-height: 600px; overflow: auto; }}
            h1 {{ color: #333; }}
            .stats {{ margin: 20px 0; padding: 10px; background-color: #eef; border-radius: 5px; }}
            .download-btn {{ 
                background-color: #4CAF50; 
                color: white; 
                padding: 10px 15px; 
                text-align: center; 
                text-decoration: none; 
                display: inline-block; 
                font-size: 16px; 
                margin: 4px 2px; 
                cursor: pointer; 
                border: none; 
                border-radius: 4px; 
            }}
            .excel-btn {{
                background-color: #2E8B57;
            }}
        </style>
    </head>
    <body>
        <h1>数据预览</h1>
        <div class="stats">
            <p>总行数: {len(df)}</p>
            <p>总列数: {len(df.columns)}</p>
            <p>生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            <a href='{csv_filename}' download class="download-btn">下载CSV数据</a>
            <a href='{os.path.basename(output_path)}' download class="download-btn excel-btn">下载Excel数据</a>
        </div>
        <div class="container">
    {df.to_html(index=False, classes="dataframe")}
        </div>
    </body>
    </html>
    """

    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html_content)

    return html_path


# SQL 查询语句
query = """
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335')
  AND t1.start_tran_date > '2025-07-04'
  AND t1.tran_type IN ('151');
"""

# 连接到数据库并执行查询
try:
    print("正在连接数据库...")
    with pyodbc.connect(connection_string) as conn:
        # 将查询结果加载到 pandas DataFrame
        print("正在执行查询...")
        df = pd.read_sql(query, conn)
        print(f"查询成功！获取到 {len(df)} 行数据。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 显示数据预览
print("\n数据预览（前5行）:")
print(df.head(5).to_string())

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
output_path = os.path.join(output_dir, f"query_results_{current_time}.xlsx")
csv_path = os.path.join(output_dir, f"query_results_{current_time}.csv")
html_path = os.path.join(output_dir, f"data_view_{current_time}.html")

# 导出到 Excel 文件
try:
    df.to_excel(output_path, index=False, engine='openpyxl')
    print(f"数据已成功导出到 Excel 文件：{output_path}")
except Exception as e:
    print("导出 Excel 文件失败！", e)

# 导出到 CSV 文件
try:
    df.to_csv(csv_path, index=False)
    print(f"数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)

# 创建HTML视图
try:
    html_path = create_html_view(df, html_path, csv_path)
    print(f"已创建HTML数据视图，可在浏览器中查看: {html_path}")
    # 自动打开HTML文件（可选，取消注释即可启用）
    # webbrowser.open('file://' + os.path.abspath(html_path))
except Exception as e:
    print("创建HTML视图失败！", e)

# 显示下一步操作提示
print("\n您可以:")
print(f"1. 打开Excel文件查看数据: {output_path}")
print(f"2. 打开HTML文件在浏览器中查看数据: {html_path}")

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")

