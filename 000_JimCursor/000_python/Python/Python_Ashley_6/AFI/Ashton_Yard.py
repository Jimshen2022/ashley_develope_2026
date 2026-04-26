# this file is tested and works well by Jim,Shen on Mar.08.2025
import os
import time
from datetime import datetime

import pandas as pd
from sqlalchemy import create_engine, text
import urllib

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'AshtonWHJSQLprod'
database = 'AAD'

# 创建连接URL（Windows 身份验证）
# 内网可用 Encrypt=no；若公司要求 TLS，可改为 Encrypt=yes;TrustServerCertificate=yes
odbc_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Trusted_Connection=yes;"
    "Encrypt=no;"
)
params = urllib.parse.quote_plus(odbc_str)

# 创建引擎（SQLAlchemy 2.x）
engine = create_engine(
    f"mssql+pyodbc:///?odbc_connect={params}",
    pool_pre_ping=True,
    pool_recycle=1800
)

# SQL 查询语句（保持你的原查询）
query = """
WITH
tmp_RP_item_order AS (
    SELECT DISTINCT d.item_number, 'RP' AS item_type
    FROM dbo.t_order o WITH (NOLOCK)
    JOIN dbo.t_order_detail d WITH (NOLOCK)
      ON o.order_number = d.order_number
     AND o.wh_id        = d.wh_id
    WHERE o.type_id = '1159'
),
main_query AS (
    SELECT DISTINCT
        t.equipment_id,
        t.state,
        l.location_name,
        t_ya_work_q.zone,
        asn.disposition,
        d.customer_po_number,
        p.vendor_code,
        t.entered_yard,
        CASE WHEN l.[type] = 'DRAYAGE' THEN NULL ELSE 'Go To' END AS disposition_unit,
        asn.asn_number,
        d.item_number,

        SUM(d.quantity_shipped)  AS Qty_shipped,
        SUM(d.quantity_received) AS Qty_received,
        SUM(d.quantity_shipped) - SUM(d.quantity_received) AS Qty_remaining,

        -- 为保持与原导出一致
        SUM(d.quantity_received)                         AS Qty_rec,
        SUM(d.quantity_shipped) - SUM(d.quantity_received) AS Qty_rem,

        asn.trailer_type_name,
        tc.comments,

        CASE
            WHEN ((ita.inventory_type IN ('FG','RM') AND ita.commodity_code IN ('LA','TA'))
                  OR rpi.item_type = 'RP')
            THEN 'RP' ELSE 'OTHERS'
        END AS Item_Type
    FROM dbo.t_trailer t WITH (NOLOCK)
    LEFT JOIN dbo.t_trailer_asn trl WITH (NOLOCK)
           ON t.trailer_id = trl.trailer_id
    LEFT JOIN dbo.t_asn asn WITH (NOLOCK)
           ON trl.asn_id = asn.asn_id
          AND asn.equipment_id = t.equipment_id
    LEFT JOIN dbo.t_ya_work_q WITH (NOLOCK)
           ON t.trailer_id = t_ya_work_q.trailer_id
          AND t_ya_work_q.status = 'UNASSIGNED'
          AND t_ya_work_q.type   = '52'
    LEFT JOIN (
        SELECT t2.trailer_id, tc1.comments
        FROM dbo.t_trailer_comments tc1 WITH (NOLOCK)
        INNER JOIN (
            SELECT trailer_id, MAX(sequence) AS maxsequence
            FROM dbo.t_trailer_comments WITH (NOLOCK)
            GROUP BY trailer_id
        ) t2
          ON tc1.trailer_id = t2.trailer_id
         AND tc1.sequence   = t2.maxsequence
    ) tc
      ON t.trailer_id = tc.trailer_id
    JOIN dbo.t_asn_detail d WITH (NOLOCK)
      ON asn.asn_id = d.asn_id
    JOIN dbo.t_ya_location l WITH (NOLOCK)
      ON t.location_id = l.location_id
    JOIN dbo.t_area a WITH (NOLOCK)
      ON t.area_id = a.area_id
    JOIN dbo.t_po_master p WITH (NOLOCK)
      ON d.customer_po_number = p.po_number
    LEFT JOIN dbo.t_item_uom uom WITH (NOLOCK)
      ON uom.item_number = d.item_number
     AND uom.default_receipt_uom = 'YES'
    LEFT JOIN dbo.t_item_master itm WITH (NOLOCK)
      ON d.item_number = itm.item_number
    LEFT JOIN dbo.t_item_attributes ita WITH (NOLOCK)
      ON d.item_number = ita.item_number
    LEFT JOIN tmp_RP_item_order rpi
      ON d.item_number = rpi.item_number
    WHERE t.status NOT IN ('HISTORY','LOST')
    GROUP BY
        t.equipment_id, t.state, l.location_name, t_ya_work_q.zone, asn.disposition,
        d.customer_po_number, p.vendor_code, t.entered_yard, asn.asn_number, d.item_number,
        asn.trailer_type_name, tc.comments, l.[type],
        ita.inventory_type, ita.commodity_code, rpi.item_type
)
SELECT
    m.equipment_id        AS [Equipment Id],
    m.state               AS [State],
    m.location_name       AS [Location],
    m.zone                AS [Zone],
    m.disposition         AS [Disposition],
    m.customer_po_number  AS [PO#],
    m.vendor_code         AS [Vendor#],
    m.entered_yard        AS [Entered Yard],
    m.disposition_unit    AS [Schedule to Door],
    m.asn_number          AS [ASN Number],
    m.item_number         AS [Item Number],
    m.Qty_shipped         AS [Qty Shipped],
    m.Qty_received        AS [Qty Received],
    m.Qty_remaining       AS [Qty Remaining],
    m.Qty_rec             AS [Qty Rec],
    m.Qty_rem             AS [Qty Rem],
    m.trailer_type_name   AS [Trailer Type],
    m.comments            AS [Comments]
FROM main_query AS m
--WHERE m.Item_Type = 'RP'          -- 只要 RP
ORDER BY m.entered_yard;
"""

# 执行查询（SQLAlchemy 2.x：read_sql 需配合 text()）
try:
    with engine.connect() as conn:
        df = pd.read_sql(text(query), conn)
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    raise

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
csv_path = os.path.join(output_dir, f"ashton_yard_results_{current_time}.csv")

# 导出到 CSV（给 Excel 友好：UTF-8 BOM）
try:
    df.to_csv(csv_path, index=False, encoding="utf-8-sig")
    print(f"数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)
    raise

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")
