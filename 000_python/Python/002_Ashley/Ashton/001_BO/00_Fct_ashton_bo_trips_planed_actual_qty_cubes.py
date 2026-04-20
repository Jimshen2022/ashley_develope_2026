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


# def create_html_view(df, html_path, csv_path):
#     """创建一个美观的HTML视图，包含下载按钮"""
#     # 获取CSV文件名称（不含路径）
#     csv_filename = os.path.basename(csv_path)
#
#     html_content = f"""
#     <!DOCTYPE html>
#     <html lang="zh">
#     <head>
#         <meta charset="UTF-8">
#         <meta name="viewport" content="width=device-width, initial-scale=1.0">
#         <title>数据预览</title>
#         <style>
#             body {{ font-family: Arial, sans-serif; margin: 20px; }}
#             table {{ border-collapse: collapse; width: 100%; }}
#             th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
#             th {{ background-color: #f2f2f2; position: sticky; top: 0; }}
#             tr:nth-child(even) {{ background-color: #f9f9f9; }}
#             tr:hover {{ background-color: #f1f1f1; }}
#             .container {{ max-height: 600px; overflow: auto; }}
#             h1 {{ color: #333; }}
#             .stats {{ margin: 20px 0; padding: 10px; background-color: #eef; border-radius: 5px; }}
#             .download-btn {{
#                 background-color: #4CAF50;
#                 color: white;
#                 padding: 10px 15px;
#                 text-align: center;
#                 text-decoration: none;
#                 display: inline-block;
#                 font-size: 16px;
#                 margin: 4px 2px;
#                 cursor: pointer;
#                 border: none;
#                 border-radius: 4px;
#             }}
#             .excel-btn {{
#                 background-color: #2E8B57;
#             }}
#         </style>
#     </head>
#     <body>
#         <h1>数据预览</h1>
#         <div class="stats">
#             <p>总行数: {len(df)}</p>
#             <p>总列数: {len(df.columns)}</p>
#             <p>生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
#             <a href='{csv_filename}' download class="download-btn">下载CSV数据</a>
#             <a href='{os.path.basename(output_path)}' download class="download-btn excel-btn">下载Excel数据</a>
#         </div>
#         <div class="container">
#     {df.to_html(index=False, classes="dataframe")}
#         </div>
#     </body>
#     </html>
#     """
#
#     with open(html_path, 'w', encoding='utf-8') as f:
#         f.write(html_content)
#
#     return html_path


# SQL 查询语句
query = """
WITH im AS (
    SELECT DISTINCT
        m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id
    FROM Distribution_Warehouse_Wholesale.t_item_master AS m
    WHERE m.wh_id = '335'
),
i AS (
    SELECT
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC,
        im.pick_put_id,
        im.commodity_code,
        im.class_id
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    LEFT JOIN im ON im.item_number = t0.ITNBR
    WHERE t0.STID = '335'
),
bo AS (
    SELECT
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        SUM(t3.tran_qty) AS bo_tran_qty,
        SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '340'
        AND t3.start_tran_date > DATEADD(DAY, -60, GETDATE())
    GROUP BY
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
        t3.item_number
),
trip_info AS (
    SELECT
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        CASE WHEN COUNT(DISTINCT i.pick_put_id) = 1 THEN
            CASE WHEN MAX(i.pick_put_id) = 'UPH' THEN 'UPH' ELSE 'CG' END
        ELSE 'Mixed' END AS container_type
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
    --INNER JOIN bo ON bo.trip_nbr = CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '347'
        AND t3.start_tran_date > DATEADD(DAY, -80, GETDATE())
		and CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT bo.trip_nbr from bo)
    GROUP BY CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
),
main_data AS (
    SELECT
        t3.start_tran_date,
        t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        t3.routing_code,
        t3.tran_qty,
        t3.tran_qty * i.B2Z95S AS tran_cube,
        i.pick_put_id
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
--     INNER JOIN bo ON bo.trip_nbr = CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT)
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '347'
        AND t3.start_tran_date > DATEADD(DAY, -80, GETDATE())
        and CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) IN (SELECT bo.trip_nbr from bo)
),
trx as (
SELECT
    m.start_tran_date,
    m.tran_type,
    m.trip_nbr,
    m.item_number,
    m.pick_put_id,
    CASE WHEN m.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END AS product,
    m.routing_code AS container_nbr,
    SUM(m.tran_qty) AS tran_qty,
    SUM(m.tran_cube) AS tran_cube,
    trip_info.container_type
FROM main_data m
left JOIN trip_info ON m.trip_nbr = trip_info.trip_nbr
GROUP BY
    m.start_tran_date,
    m.tran_type,
    m.trip_nbr,
    m.item_number,
    m.pick_put_id,
    CASE WHEN m.pick_put_id = 'UPH' THEN 'UPH' ELSE 'CG' END,
    m.routing_code,
    trip_info.container_type
),
all_items AS (
    -- 确保所有 item_number 都被包含
    SELECT trip_nbr, item_number FROM bo
    UNION
    SELECT trip_nbr, item_number FROM trx
),
filled_data AS (
    SELECT
        ai.trip_nbr,
        ai.item_number,
        -- 处理 start_tran_date
        COALESCE(t.start_tran_date, MAX(t.start_tran_date) OVER (PARTITION BY ai.trip_nbr)) AS start_tran_date,
        -- 处理 tran_type
        COALESCE(t.tran_type, MAX(t.tran_type) OVER (PARTITION BY ai.trip_nbr)) AS tran_type,
        -- 处理 container_nbr
        COALESCE(t.container_nbr, MAX(t.container_nbr) OVER (PARTITION BY ai.trip_nbr)) AS container_nbr,
		COALESCE(t.container_type, MAX(t.container_type) OVER (PARTITION BY ai.trip_nbr)) as container_type,
        -- 计算数量和体积
        ISNULL(t.tran_qty, 0) + ISNULL(b.bo_tran_qty, 0) AS Trip_Planned_Qty,
        ISNULL(t.tran_cube, 0) + ISNULL(b.bo_tran_cube, 0) AS Trip_Planned_Cube,
        ISNULL(t.tran_qty, 0) AS Shipped_Qty,
        ISNULL(t.tran_cube, 0) AS Shipped_Cube,
        ISNULL(b.bo_tran_qty, 0) AS bo_tran_qty,
        ISNULL(b.bo_tran_cube, 0) AS bo_tran_cube
    FROM all_items ai
    LEFT JOIN trx t ON ai.trip_nbr = t.trip_nbr AND ai.item_number = t.item_number
    LEFT JOIN bo b ON ai.trip_nbr = b.trip_nbr AND ai.item_number = b.item_number
)
SELECT * FROM filled_data
ORDER BY trip_nbr, item_number;
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

# # 创建HTML视图
# try:
#     html_path = create_html_view(df, html_path, csv_path)
#     print(f"已创建HTML数据视图，可在浏览器中查看: {html_path}")
#     # 自动打开HTML文件（可选，取消注释即可启用）
#     # webbrowser.open('file://' + os.path.abspath(html_path))
# except Exception as e:
#     print("创建HTML视图失败！", e)

# 显示下一步操作提示
print("\n您可以:")
print(f"1. 打开Excel文件查看数据: {output_path}")
print(f"2. 打开HTML文件在浏览器中查看数据: {html_path}")

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")

