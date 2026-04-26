import pandas as pd
import pyodbc
from datetime import datetime, timedelta
import os


# ==========================================
# 数据库连接配置 (AshtonWHJSQLprod / HJ SQL Server)
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


# 连接字符串
# conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={UID};PWD={PWD}'
conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'


def get_connection_string():
    """建立并返回数据库连接"""
    try:
        conn = pyodbc.connect(conn_str)
        return conn
    except pyodbc.Error as ex:
        sqlstate = ex.args[0]
        print(f"数据库连接失败: {sqlstate}")
        print(ex)
        return None


# --- 2. 数据获取 ---

def get_demand_data(conn):
    """获取未来10天的需求数据"""
    print("正在抓取未来10天的需求数据...")

    # 基于 Distribution_Warehouse_Wholesale.TripAvailableSTO 视图的逻辑
    # 注意：在AAD中，这个视图可能不存在，我们需要直接查询核心表来模拟
    # 这里我们直接查询 t_load_master 和 t_order_detail_breakdown

    demand_sql = """
                WITH TripDemand AS (
                    SELECT
                        DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date) AS dispatch_date,
                        orb.item_number,
                        ldm.load_id AS trip_number,
                        ldm.status AS ldm_status,
                        SUM(orb.qty) AS trip_needed,
                        ISNULL(pkd.picked_qty, 0) AS trip_picked
                    FROM t_load_master ldm WITH (NOLOCK)
                    JOIN t_order orm WITH (NOLOCK)
                        ON ldm.load_id = orm.load_id
                        AND ldm.wh_id = orm.wh_id
                    JOIN t_order_detail_breakdown orb WITH (NOLOCK)
                        ON orm.order_number = orb.order_number
                        AND orm.wh_id = orb.wh_id
                    LEFT JOIN (
                        SELECT
                            LEFT(load_id,7) as load_id,
                            item_number,
                            SUM(picked_quantity) AS picked_qty
                        FROM t_pick_detail WITH (NOLOCK)
                        WHERE picked_quantity > 0
                          AND load_id IS NOT NULL
                        GROUP BY
                            load_id,
                            item_number
                    ) pkd
                        ON ldm.load_id = pkd.load_id
                        AND orb.item_number = pkd.item_number
                    WHERE ldm.wh_id = '335'
                      AND DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date)
                            >= DATEADD(MONTH, -1, GETDATE())
                      AND DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date)
                            < DATEADD(DAY, 1, CAST(DATEADD(MONTH, 1, GETDATE()) AS DATE))
                      AND ldm.status NOT IN ('S', 'X', 'C')
                      AND ldm.load_type = 'B'
                    GROUP BY
                        DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date),
                        orb.item_number,
                        ldm.load_id,
                        ldm.status,
                        pkd.picked_qty
                )                
                SELECT
                    dispatch_date,
                    item_number,
                    trip_number,
                    ldm_status,
                    trip_needed,
                    trip_picked,
                    (trip_needed - trip_picked) AS trip_demand_qty
                FROM TripDemand
                WHERE (trip_needed - trip_picked) > 0
                ORDER BY
                    item_number,
                    dispatch_date,
                    trip_number      
                 """
    try:
        demand_df = pd.read_sql(demand_sql, conn)
        print(f"成功获取 {len(demand_df)} 条需求记录。")
        return demand_df
    except Exception as e:
        print(f"获取需求数据时出错: {e}")
        return pd.DataFrame()


def get_supply_data(conn):
    """获取Yard中的供应数据 (未接收的ASN)"""
    print("正在抓取Yard中的供应数据...")

    supply_sql = """
                    SELECT
                        trl.equipment_id AS container_number,
                        ad.item_number,
                        ad.quantity_shipped - ad.quantity_received AS unreceived_qty,
                        trl.entered_yard AS check_into_yard_time
                    FROM t_trailer trl WITH (NOLOCK)
                    JOIN t_trailer_asn tasn WITH (NOLOCK)
                        ON trl.trailer_id = tasn.trailer_id
                    JOIN t_asn a WITH (NOLOCK)
                        ON tasn.asn_id = a.asn_id
                    JOIN t_asn_detail ad WITH (NOLOCK)
                        ON a.asn_id = ad.asn_id
                    WHERE
                    --trl.status = 'IN YARD'
                       a.status IN ('CHECKED IN')
                    ORDER BY trl.entered_yard
                 """
    try:
        supply_df = pd.read_sql(supply_sql, conn)
        print(f"成功获取 {len(supply_df)} 条供应记录。")
        return supply_df
    except Exception as e:
        print(f"获取供应数据时出错: {e}")
        return pd.DataFrame()


# --- 3. 分配逻辑 ---

def run_allocation(demand_df, supply_df):
    """执行供需分配"""
    if demand_df.empty or supply_df.empty:
        print("需求或供应数据为空，无法进行分配。")
        return demand_df, supply_df

    print("开始执行分配逻辑...")

    # 初始化新列
    demand_df['allocation_demand_qty'] = 0
    demand_df['allocation_demand_details'] = ''

    # 创建一个可修改的供应副本
    supply_available = supply_df.copy()
    supply_available['allocated_qty'] = 0

    # 按物料分组供应，方便查找
    supply_grouped = supply_available.groupby('item_number')

    for index, demand_row in demand_df.iterrows():
        item = demand_row['item_number']
        needed = demand_row['trip_demand_qty']

        if needed <= 0:
            continue

        allocated_details = []

        if item in supply_grouped.groups:
            # 获取该物料的所有供应
            item_supply_indices = supply_grouped.get_group(item).index

            for supply_idx in item_supply_indices:
                available_qty = supply_available.loc[supply_idx, 'unreceived_qty'] - supply_available.loc[
                    supply_idx, 'allocated_qty']

                if available_qty > 0:
                    # 计算本次可分配数量
                    alloc_qty = min(needed, available_qty)

                    # 更新需求行
                    demand_df.loc[index, 'allocation_demand_qty'] += alloc_qty

                    # 更新供应行
                    supply_available.loc[supply_idx, 'allocated_qty'] += alloc_qty

                    # 记录分配详情
                    container = supply_available.loc[supply_idx, 'container_number']
                    allocated_details.append(f"{container}({int(alloc_qty)})")

                    # 更新剩余需求
                    needed -= alloc_qty

                    if needed == 0:
                        break  # 当前需求已满足

            if allocated_details:
                demand_df.loc[index, 'allocation_demand_details'] = '; '.join(allocated_details)

    print("分配逻辑执行完毕。")
    return demand_df, supply_available


# --- 4. 结果计算 ---

def calculate_fulfillment_status(supply_df):
    """计算每个container的满足状态"""
    if supply_df.empty:
        return supply_df

    print("正在计算Container满足状态...")

    # 按container分组
    container_groups = supply_df.groupby('container_number')

    status_list = []
    percentage_list = []

    for container, group in container_groups:
        total_unreceived = group['unreceived_qty'].sum()
        total_allocated = group['allocated_qty'].sum()

        # 计算满足状态
        if total_allocated == 0:
            status = 'no demand for trip'
        elif total_allocated >= total_unreceived:
            status = 'whole container can be put on ground'
        else:
            status = 'partial allocated'

        # 计算满足百分比
        if total_allocated > 0:
            percentage = (total_unreceived / total_allocated) * 100
        else:
            percentage = 0

        # 为该组的每一行添加相同的值
        for _ in range(len(group)):
            status_list.append(status)
            percentage_list.append(percentage)

    supply_df['yard_container_fulfill_status'] = status_list
    supply_df['yard_container_fulfill_status_percentage'] = percentage_list

    print("状态计算完毕。")
    return supply_df


# --- 5. 主函数 ---

def main():
    """主执行函数"""
    conn = get_connection_string()
    if not conn:
        return

    # 获取数据
    demand_data = get_demand_data(conn)
    supply_data = get_supply_data(conn)

    conn.close()

    # 执行分配
    demand_result, supply_result = run_allocation(demand_data, supply_data)

    # 计算最终状态
    final_supply_report = calculate_fulfillment_status(supply_result)

    # --- 输出结果 ---
    print("\n--- 需求分配结果 (Demand Report) ---")
    print(demand_result.to_string())

    print("\n--- 供应分配及状态 (Supply Report) ---")
    # 为了报告更清晰，我们可以只显示每个container一次
    supply_summary = final_supply_report.drop_duplicates(subset=['container_number']).set_index('container_number')
    print(supply_summary[['yard_container_fulfill_status', 'yard_container_fulfill_status_percentage']])

    # 如果需要详细的每个item的分配情况，可以打印完整的 supply_result
    # print("\n--- 详细供应分配情况 ---")
    # print(final_supply_report.to_string())


if __name__ == '__main__':
    main()
