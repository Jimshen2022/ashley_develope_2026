import pandas as pd
import pyodbc
from datetime import datetime
import os

# ==========================================
# 数据库连接配置 (保持不变)
# ==========================================
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'


def get_connection_string():
    """生成连接字符串 (Windows Authentication)"""
    driver = '{ODBC Driver 17 for SQL Server}'
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
    )


conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'


def get_connection():
    try:
        conn = pyodbc.connect(conn_str)
        return conn
    except pyodbc.Error as ex:
        print(f"数据库连接失败: {ex}")
        return None


# --- 数据获取 (SQL逻辑完全保留) ---

def get_demand_data(conn):
    demand_sql = """
                 WITH TripDemand AS (SELECT DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), \
                                                    ldm.dispatch_date) AS dispatch_date, \
                                            orb.item_number, \
                                            ldm.load_id                AS trip_number, \
                                            ldm.status                 AS ldm_status, \
                                            SUM(orb.qty)               AS trip_needed, \
                                            ISNULL(pkd.picked_qty, 0)  AS trip_picked \
                                     FROM t_load_master ldm WITH (NOLOCK) \
                                              JOIN t_order orm WITH (NOLOCK) \
                                                   ON ldm.load_id = orm.load_id \
                                                       AND ldm.wh_id = orm.wh_id \
                                              JOIN t_order_detail_breakdown orb WITH (NOLOCK) \
                                                   ON orm.order_number = orb.order_number \
                                                       AND orm.wh_id = orb.wh_id \
                                              LEFT JOIN (SELECT LEFT(load_id, 7)     as load_id, \
                                                                item_number, \
                                                                SUM(picked_quantity) AS picked_qty \
                                                         FROM t_pick_detail WITH (NOLOCK) \
                                                         WHERE picked_quantity > 0 \
                                                           AND load_id IS NOT NULL \
                                                         GROUP BY load_id, \
                                                                  item_number) pkd \
                                                        ON ldm.load_id = pkd.load_id \
                                                            AND orb.item_number = pkd.item_number \
                                     WHERE ldm.wh_id = '335' \
                                       AND DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date) \
                                         >= DATEADD(MONTH, -1, GETDATE()) \
                                       AND DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date) \
                                         < DATEADD(DAY, 1, CAST(DATEADD(MONTH, 1, GETDATE()) AS DATE)) \
                                       AND ldm.status NOT IN ('S', 'X', 'C') \
                                       AND ldm.load_type = 'B' \
                                     GROUP BY DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), \
                                                      ldm.dispatch_date), \
                                              orb.item_number, \
                                              ldm.load_id, \
                                              ldm.status, \
                                              pkd.picked_qty)
                 SELECT dispatch_date, \
                        item_number, \
                        trip_number, \
                        ldm_status, \
                        trip_needed, \
                        trip_picked, \
                        (trip_needed - trip_picked) AS trip_demand_qty
                 FROM TripDemand
                 WHERE (trip_needed - trip_picked) > 0
                 ORDER BY item_number, \
                          dispatch_date, \
                          trip_number \
                 """
    return pd.read_sql(demand_sql, conn)


def get_supply_data(conn):
    supply_sql = """
                 SELECT trl.equipment_id                           AS container_number, \
                        ad.item_number, \
                        ad.quantity_shipped - ad.quantity_received AS unreceived_qty, \
                        trl.entered_yard                           AS check_into_yard_time
                 FROM t_trailer trl WITH (NOLOCK)
                          JOIN t_trailer_asn tasn WITH (NOLOCK)
                               ON trl.trailer_id = tasn.trailer_id
                          JOIN t_asn a WITH (NOLOCK)
                               ON tasn.asn_id = a.asn_id
                          JOIN t_asn_detail ad WITH (NOLOCK)
                               ON a.asn_id = ad.asn_id
                 WHERE a.status IN ('CHECKED IN')
                 ORDER BY trl.entered_yard
                 """
    return pd.read_sql(supply_sql, conn)


# --- 分配逻辑 (保持不变) ---
def run_allocation(demand_df, supply_df):
    if demand_df.empty or supply_df.empty: return demand_df, supply_df
    demand_df['allocation_demand_qty'] = 0
    demand_df['allocation_demand_details'] = ''
    supply_available = supply_df.copy()
    supply_available['allocated_qty'] = 0
    supply_grouped = supply_available.groupby('item_number')
    for index, demand_row in demand_df.iterrows():
        item = demand_row['item_number']
        needed = demand_row['trip_demand_qty']
        if needed <= 0: continue
        allocated_details = []
        if item in supply_grouped.groups:
            item_supply_indices = supply_grouped.get_group(item).index
            for supply_idx in item_supply_indices:
                available_qty = supply_available.loc[supply_idx, 'unreceived_qty'] - supply_available.loc[
                    supply_idx, 'allocated_qty']
                if available_qty > 0:
                    alloc_qty = min(needed, available_qty)
                    demand_df.loc[index, 'allocation_demand_qty'] += alloc_qty
                    supply_available.loc[supply_idx, 'allocated_qty'] += alloc_qty
                    container = supply_available.loc[supply_idx, 'container_number']
                    allocated_details.append(f"{container}({int(alloc_qty)})")
                    needed -= alloc_qty
                    if needed == 0: break
            if allocated_details:
                demand_df.loc[index, 'allocation_demand_details'] = '; '.join(allocated_details)
    return demand_df, supply_available


def calculate_fulfillment_status(supply_df):
    if supply_df.empty: return supply_df
    container_groups = supply_df.groupby('container_number')
    status_list, percentage_list = [], []
    for container, group in container_groups:
        total_unreceived = group['unreceived_qty'].sum()
        total_allocated = group['allocated_qty'].sum()
        status = 'no demand' if total_allocated == 0 else (
            'whole container' if total_allocated >= total_unreceived else 'partial')
        percentage = (total_allocated / total_unreceived * 100) if total_unreceived > 0 else 0
        for _ in range(len(group)):
            status_list.append(status)
            percentage_list.append(percentage)
    supply_df['yard_status'] = status_list
    supply_df['fulfill_percentage'] = percentage_list
    return supply_df


# --- 修改后的主函数 (满足路径、分表、格式、时间戳要求) ---

def main():
    conn = get_connection()
    if not conn: return

    # 1. 抓取数据
    df_raw_demand = get_demand_data(conn)
    df_raw_supply = get_supply_data(conn)
    conn.close()

    # 2. 计算分配
    df_demand_allocated, df_supply_temp = run_allocation(df_raw_demand.copy(), df_raw_supply.copy())
    df_supply_final = calculate_fulfillment_status(df_supply_temp)

    # 3. 动态获取当前电脑的 Downloads 文件夹路径
    downloads_path = os.path.join(os.path.expanduser("~"), "Downloads")
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"Allocation_Result_{timestamp}.xlsx"
    full_save_path = os.path.join(downloads_path, file_name)

    # 4. 导出三个工作表并强制文本格式
    with pd.ExcelWriter(full_save_path, engine='xlsxwriter') as writer:
        workbook = writer.book
        # 设置文本格式专用
        txt_fmt = workbook.add_format({'num_format': '@'})

        # 定义工作表映射
        sheet_map = {
            "Demand": df_raw_demand,  # 原始需求表
            "Supply": df_supply_final,  # 供应及状态表
            "Allocation": df_demand_allocated  # 分配结果表
        }

        for sheet_name, df in sheet_map.items():
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            worksheet = writer.sheets[sheet_name]

            # 自动将 trip_number 和 item_number 所在列设为文本格式
            for i, col_name in enumerate(df.columns):
                if col_name.lower() in ['trip_number', 'item_number', 'container_number']:
                    worksheet.set_column(i, i, 18, txt_fmt)

    print(f"完成！文件已存至: {full_save_path}")


if __name__ == '__main__':
    main()