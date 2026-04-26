# this file is tested and works well by Jim,Shen on Mar.08.2025
import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import time
from datetime import datetime

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'

# 创建连接URL
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

# 创建引擎
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# SQL 查询语句
query = """
        with itm AS (select t.item_number, \
                            t.description, \
                            t.inventory_type, \
                            t.commodity_code, \
                            t.wh_id, \
                            t.class_id, \
                            t.pick_put_id \
                     from Distribution_Warehouse_Wholesale.t_item_master as t \
                     where t.wh_id in ('335', '51') \
                     union all \
                     select t.item_number, \
                            t.description, \
                            t.inventory_type, \
                            t.commodity_code, \
                            t.wh_id2 as wh_id, \
                            t.class_id, \
                            t.pick_put_id \
                     from Distribution_Warehouse_Wholesale.t_item_master as t \
                     where t.wh_id2 in ('35'))
        select t.wh_id, \
               t.tran_type, \
               t.description, \
               t.start_tran_date, \
               DATEADD(DAY, 7 - DATEPART(WEEKDAY, t.start_tran_date), t.start_tran_date) as week_ending_saturday, \
               MONTH(t.start_tran_date)                                                  as month, \
               t.employee_id, \
               t.item_number, \
               t.lot_number, \
               t.tran_qty, \
               t.control_number_2                                                        as from_location, \
               t.location_id_2                                                           as to_location, \
               i.pick_put_id, \
               case when i.pick_put_id = 'PALLT' then 'CG' ELSE 'UPH' END                AS product, \
               case \
                   when t.wh_id in ('35', '33', '31') and t.location_id_2 in ('NG001DC1') then 'DC' \
                   when t.wh_id in ('35', '33', '31') and t.location_id_2 in ('NG001UP1') then 'WN3_WN2' \
                   when t.wh_id in ('335') then 'Ashton' \
                   else 'MIL' END                                                        as site, \
               case \
                   when i.wh_id in ('51', '35', '33', '31') then 'whse_damaged' \
                   when i.wh_id in ('335') and t.control_number_2 like 'RS%' then 'vendor_damaged' \
                   else 'whse_damaged' end                                               as damaged_defect_type
        from Distribution_Warehouse_Wholesale.TranLog as t
                 left join itm as i on i.wh_id = t.wh_id and i.item_number = t.item_number
        where t.wh_id in ('335', '51', '35', '33', '31')
          and t.location_id_2 in ('NG001UP1', 'NG001DC1', 'NG001CG1', 'DM001AA1')
          and start_tran_date > '2025-06-01' \
          and tran_type = '202' \
        """jim

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("查询成功！数据已加载到 DataFrame。")
    print(f"查询到 {len(df)} 条记录")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
excel_path = os.path.join(output_dir, f"damaged_items_report_{current_time}.xlsx")

# 创建汇总数据透视表
try:
    # 确保 week_ending_saturday 是日期格式
    df['week_ending_saturday'] = pd.to_datetime(df['week_ending_saturday'])

    # 创建数据透视表：行为 week_ending_saturday，列为 site 和 product，值为 tran_qty 的总和
    summary = pd.pivot_table(
        df,
        values='tran_qty',
        index='week_ending_saturday',
        columns=['site', 'product'],
        aggfunc='sum',
        fill_value=0
    )

    # 将多层级列名合并为单层级（例如：Ashton_CG, DC_UPH）
    summary.columns = [f'{site}_{product}' for site, product in summary.columns]

    # 重置索引使 week_ending_saturday 成为普通列
    summary = summary.reset_index()

    print("汇总表创建成功！")

except Exception as e:
    print("创建汇总表失败！", e)
    summary = pd.DataFrame()

# 导出到 Excel 文件（包含 Details 和 Summary 两个工作表）
try:
    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        # 写入明细表
        df.to_excel(writer, sheet_name='Details', index=False)

        # 写入汇总表
        if not summary.empty:
            summary.to_excel(writer, sheet_name='Summary', index=False)

    print(f"\n数据已成功导出到 Excel 文件：{excel_path}")
    print(f"- Details sheet: {len(df)} 条明细记录")
    print(f"- Summary sheet: 按周六日期汇总，列为 Site 和 Product 组合")

except Exception as e:
    print("导出 Excel 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")