import pandas as pd
import pyodbc
from datetime import datetime, timedelta
import os

# ==========================================
# 数据库连接配置 (ASHLEY_EDW / Microsoft Entra Integrated)
# ==========================================
SERVER = 'ashley-edw.database.windows.net'
DATABASE = 'ASHLEY_EDW'

# ==========================================
# 可配置参数
# ==========================================
WAREHOUSE_ID = '335'
FORECAST_WEEKS = 8
WARNING_THRESHOLD = 85  # 仓库利用率超过 85% 时发出警告
CRITICAL_THRESHOLD = 95 # 仓库利用率超过 95% 时发出严重警告

# 注意：请根据实际情况调整容量 (单位：立方英尺或您可以统一为件数)
ZONE_CAPACITIES = {
    'CG': 500000,
    'UPH': 800000,
    'RUG': 100000,
    'BULK': 150000
}

def get_connection_string():
    """生成连接字符串 (Azure AD Integrated)"""
    driver = '{ODBC Driver 17 for SQL Server}'
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Authentication=ActiveDirectoryIntegrated;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
        f"Connection Timeout=60;"
    )

def get_capacity_forecast():
    """
    生成仓库容量预测报告并保存为 CSV
    """
    try:
        conn_str = get_connection_string()
        print(f"正在连接到 EDW 数据库 ({SERVER})...")
        
        with pyodbc.connect(conn_str) as conn:
            print("连接成功！正在执行预测模型 SQL 查询...")
            
            sql_query = f"""
            -- ===================================================================
            -- Warehouse Capacity Weekly Forecast & Warning Report
            -- ===================================================================

            -- Step 1: Define Zone Capacities (in Cubic Feet)
            WITH Zone_Capacity AS (
                SELECT 'CG' AS Zone, {ZONE_CAPACITIES['CG']} AS Capacity_cubic_ft UNION ALL
                SELECT 'UPH' AS Zone, {ZONE_CAPACITIES['UPH']} AS Capacity_cubic_ft UNION ALL
                SELECT 'RUG' AS Zone, {ZONE_CAPACITIES['RUG']} AS Capacity_cubic_ft UNION ALL
                SELECT 'BULK' AS Zone, {ZONE_CAPACITIES['BULK']} AS Capacity_cubic_ft
            ),

            -- Step 2: Categorize all items into Zones
            Item_Zones AS (
                SELECT
                    item_number,
                    wh_id,
                    unit_volume,
                    CASE
                        WHEN pick_put_id = 'UPH' THEN 'UPH'
                        WHEN pick_put_id = 'PALLT' THEN 'CG'
                        WHEN class_id = 'RUGS' THEN 'RUG'
                        WHEN class_id = 'BULK' THEN 'BULK'
                        ELSE 'UNKNOWN'
                    END AS Zone
                FROM Distribution_Warehouse_Wholesale.t_item_master WITH (NOLOCK)
                WHERE wh_id = '{WAREHOUSE_ID}'
            ),

            -- Step 3: Calculate Current On-Hand Inventory (Cubic Feet) per Zone
            Current_On_Hand AS (
                SELECT
                    iz.Zone,
                    SUM(s.actual_qty * iz.unit_volume) AS OnHand_cubic_ft
                FROM Distribution_Warehouse_Wholesale.t_stored_item s WITH (NOLOCK)
                JOIN Item_Zones iz ON s.item_number = iz.item_number AND s.wh_id = iz.wh_id
                WHERE s.wh_id = '{WAREHOUSE_ID}' AND s.status IN ('A', 'H', 'R') AND s.actual_qty > 0
                GROUP BY iz.Zone
            ),

            -- Step 4: Calculate Projected Weekly Inbound (Cubic Feet) per Zone
            -- 使用 t_asn 和 ASN_Detail 预测未来入库
            Projected_Inbound AS (
                SELECT
                    iz.Zone,
                    DATEADD(wk, DATEDIFF(wk, 0, a.expected_arrival), 6) AS WeekEndingDate,
                    SUM(ad.quantity_shipped * iz.unit_volume) AS Inbound_cubic_ft
                FROM Distribution_Warehouse_Wholesale.t_asn a WITH (NOLOCK)
                JOIN Distribution_Warehouse_Wholesale.ASN_Detail ad WITH (NOLOCK) ON a.asn_id = ad.asn_id
                JOIN Item_Zones iz ON ad.item_number = iz.item_number
                WHERE a.wh_id = '{WAREHOUSE_ID}'
                  AND a.status IN ('NEW', 'CHECKED IN')
                  AND a.expected_arrival BETWEEN GETDATE() AND DATEADD(WEEK, {FORECAST_WEEKS}, GETDATE())
                GROUP BY iz.Zone, DATEADD(wk, DATEDIFF(wk, 0, a.expected_arrival), 6)
            ),

            -- Step 5: Calculate Projected Weekly Outbound (Cubic Feet) per Zone
            -- 使用 LoadMaster 和 OrderDetail 预测未来出库
            Projected_Outbound AS (
                SELECT
                    iz.Zone,
                    DATEADD(wk, DATEDIFF(wk, 0, ldm.dispatch_date), 6) AS WeekEndingDate,
                    SUM(orb.qty * iz.unit_volume) AS Outbound_cubic_ft
                FROM Distribution_Warehouse_Wholesale.LoadMaster ldm WITH (NOLOCK)
                JOIN Distribution_Warehouse_Wholesale.Order_Detail orb WITH (NOLOCK) ON ldm.load_id = LEFT(orb.order_number, 10) AND ldm.wh_id = orb.wh_id
                JOIN Item_Zones iz ON orb.item_number = iz.item_number
                WHERE ldm.wh_id = '{WAREHOUSE_ID}'
                  AND ldm.status IN ('N', 'R', 'W', 'H')
                  AND ldm.dispatch_date BETWEEN GETDATE() AND DATEADD(WEEK, {FORECAST_WEEKS}, GETDATE())
                GROUP BY iz.Zone, DATEADD(wk, DATEDIFF(wk, 0, ldm.dispatch_date), 6)
            ),

            -- Step 6: Generate a calendar of the next X weeks
            Weeks AS (
                SELECT TOP {FORECAST_WEEKS} DATEADD(wk, DATEDIFF(wk, 0, DATEADD(wk, ROW_NUMBER() OVER (ORDER BY a.object_id) - 1, GETDATE())), 6) AS WeekEndingDate
                FROM sys.all_objects a
            )

            -- Final Step: Combine all data and calculate the rolling balance
            SELECT
                w.WeekEndingDate,
                zc.Zone,
                zc.Capacity_cubic_ft,
                ISNULL(coh.OnHand_cubic_ft, 0) AS Current_OnHand_cubic_ft,
                ISNULL(pi.Inbound_cubic_ft, 0) AS Projected_Inbound_cubic_ft,
                ISNULL(po.Outbound_cubic_ft, 0) AS Projected_Outbound_cubic_ft,
                (
                    ISNULL(coh.OnHand_cubic_ft, 0) +
                    SUM(ISNULL(pi.Inbound_cubic_ft, 0) - ISNULL(po.Outbound_cubic_ft, 0)) OVER (PARTITION BY zc.Zone ORDER BY w.WeekEndingDate)
                ) AS Projected_End_Balance_cubic_ft,
                CAST(
                    (
                        ISNULL(coh.OnHand_cubic_ft, 0) +
                        SUM(ISNULL(pi.Inbound_cubic_ft, 0) - ISNULL(po.Outbound_cubic_ft, 0)) OVER (PARTITION BY zc.Zone ORDER BY w.WeekEndingDate)
                    ) * 100.0 / zc.Capacity_cubic_ft
                AS DECIMAL(5, 2)) AS Projected_Utilization_Percent,
                CASE
                    WHEN (
                        ISNULL(coh.OnHand_cubic_ft, 0) +
                        SUM(ISNULL(pi.Inbound_cubic_ft, 0) - ISNULL(po.Outbound_cubic_ft, 0)) OVER (PARTITION BY zc.Zone ORDER BY w.WeekEndingDate)
                    ) * 100.0 / zc.Capacity_cubic_ft > {CRITICAL_THRESHOLD} THEN '🔴 CRITICAL'
                    WHEN (
                        ISNULL(coh.OnHand_cubic_ft, 0) +
                        SUM(ISNULL(pi.Inbound_cubic_ft, 0) - ISNULL(po.Outbound_cubic_ft, 0)) OVER (PARTITION BY zc.Zone ORDER BY w.WeekEndingDate)
                    ) * 100.0 / zc.Capacity_cubic_ft > {WARNING_THRESHOLD} THEN '🟡 WARNING'
                    ELSE '🟢 OK'
                END AS Warning_Level
            FROM Weeks w
            CROSS JOIN Zone_Capacity zc
            LEFT JOIN Current_On_Hand coh ON zc.Zone = coh.Zone
            LEFT JOIN Projected_Inbound pi ON zc.Zone = pi.Zone AND w.WeekEndingDate = pi.WeekEndingDate
            LEFT JOIN Projected_Outbound po ON zc.Zone = po.Zone AND w.WeekEndingDate = po.WeekEndingDate
            ORDER BY w.WeekEndingDate, zc.Zone;
            """
            
            df = pd.read_sql(sql_query, conn)
            
            if not df.empty:
                print("\n=== 仓库容量周度预测及预警报告 ===")
                df['WeekEndingDate'] = pd.to_datetime(df['WeekEndingDate']).dt.strftime('%Y-%m-%d')
                
                # Format numbers
                cols_to_format = ['Capacity_cubic_ft', 'Current_OnHand_cubic_ft', 'Projected_Inbound_cubic_ft', 'Projected_Outbound_cubic_ft', 'Projected_End_Balance_cubic_ft']
                for col in cols_to_format:
                    df[col] = df[col].apply(lambda x: f"{x:,.0f}")
                
                print(df.to_string(index=False))
                
                # Save to CSV
                downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                output_file = os.path.join(downloads_folder, f"Capacity_Forecast_Whse{WAREHOUSE_ID}_{timestamp}.csv")
                
                df.to_csv(output_file, index=False, encoding='utf-8-sig')
                print(f"\n📁 预警报告已成功导出至: {output_file}")
                
                # 检查警告并打印高亮提示
                urgent_zones = df[df['Warning_Level'].isin(['🔴 CRITICAL', '🟡 WARNING'])]
                if not urgent_zones.empty:
                    print("\n⚠️ 发现以下预警事项，请重点关注：")
                    print(urgent_zones[['WeekEndingDate', 'Zone', 'Projected_Utilization_Percent', 'Warning_Level']].to_string(index=False))
                else:
                    print("\n🟢 未来 8 周内各区域容量状态良好。")

    except pyodbc.Error as ex:
        print(f"\n[数据库连接错误]: {ex}")
    except Exception as e:
        print(f"\n发生未预期的错误: {e}")

if __name__ == "__main__":
    get_capacity_forecast()