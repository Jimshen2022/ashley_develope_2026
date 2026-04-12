import os
import pandas as pd
import pyodbc
from datetime import datetime

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


def get_db_connection():
    """建立并返回数据库连接"""
    try:
        conn_str = get_connection_string()
        conn = pyodbc.connect(conn_str)
        return conn
    except pyodbc.Error as ex:
        sqlstate = ex.args[0]
        print(f"数据库连接失败: {sqlstate}")
        print(ex)
        return None


# ==========================================
# 数据获取
# ==========================================
def get_demand_data(conn):
    """获取未来10天的需求数据"""
    print("正在抓取未来10天的需求数据...")
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
                                              LEFT JOIN (SELECT load_id, \
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
                          trip_number; \
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
                 SELECT trl.equipment_id                           AS container_number, \
                        ad.item_number, \
                        SUM(ad.quantity_shipped - ad.quantity_received) AS unreceived_qty, \
                        trl.entered_yard                           AS check_into_yard_time
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
                 GROUP BY trl.equipment_id, ad.item_number, trl.entered_yard  
                 ORDER BY trl.entered_yard; \
                 """
    try:
        supply_df = pd.read_sql(supply_sql, conn)
        print(f"成功获取 {len(supply_df)} 条供应记录。")
        return supply_df
    except Exception as e:
        print(f"获取供应数据时出错: {e}")
        return pd.DataFrame()


# ==========================================
# 分配与计算逻辑
# ==========================================
def run_allocation(demand_df, supply_df):
    """执行供需分配，返回一个包含所有分配记录的列表"""
    if demand_df.empty or supply_df.empty:
        print("需求或供应数据为空，无法进行分配。")
        return []

    print("开始执行分配逻辑...")
    allocations = []
    supply_available = supply_df.copy()
    supply_available['allocated_qty'] = 0

    # 为了提高查找效率，将供应数据按item_number分组
    supply_grouped = supply_available.groupby('item_number')

    for dem_idx, demand_row in demand_df.iterrows():
        item_needed = demand_row['item_number']
        demand_qty = demand_row['trip_demand_qty']

        if demand_qty <= 0:
            continue

        # 查找匹配物料的供应
        if item_needed in supply_grouped.groups:
            # 获取该物料的所有供应行的索引
            supply_indices = supply_grouped.get_group(item_needed).index

            for sup_idx in supply_indices:
                # 计算该供应行还剩多少可用数量
                available_qty = supply_available.loc[sup_idx, 'unreceived_qty'] - supply_available.loc[
                    sup_idx, 'allocated_qty']

                if available_qty > 0:
                    # 确定本次可以分配的数量
                    qty_to_allocate = min(demand_qty, available_qty)

                    # 记录本次分配
                    allocations.append({
                        'trip_number': demand_row['trip_number'],
                        'dispatch_date': demand_row['dispatch_date'],
                        'item_number': item_needed,
                        'container_number': supply_available.loc[sup_idx, 'container_number'],
                        'allocated_qty': qty_to_allocate
                    })

                    # 更新供应表中的已分配数量
                    supply_available.loc[sup_idx, 'allocated_qty'] += qty_to_allocate
                    # 更新当前需求的剩余待分配数量
                    demand_qty -= qty_to_allocate

                    if demand_qty == 0:
                        break  # 当前需求已满足，跳出供应循环

    print(f"分配逻辑执行完毕，共产生 {len(allocations)} 条分配记录。")
    return allocations


def process_demand_sheet(demand_df, allocations_df):
    """处理Demand Sheet的计算"""
    if allocations_df.empty:
        demand_df['Allocated_Supply_Qty'] = 0
        demand_df['Allocated_Supply_Details'] = ''
        demand_df['Allocated_Status'] = 'trip no item in yard'
        demand_df['Fulfill_Rate'] = 0
        demand_df['Allocated_Container_Count'] = 0
        demand_df['SKUs'] = 0
        return demand_df

    # 1. 计算每个 (trip, item) 的分配数量和详情
    alloc_summary = allocations_df.groupby(['trip_number', 'item_number']).agg(
        Allocated_Supply_Qty=('allocated_qty', 'sum'),
        Allocated_Supply_Details=('container_number', lambda x: '; '.join(
            f"{row['container_number']} * {int(row['allocated_qty'])}" for _, row in
            allocations_df[allocations_df['container_number'].isin(x)].iterrows()))
    ).reset_index()

    # 修正Details的生成方式，使其更准确
    alloc_details = allocations_df.copy()
    alloc_details['detail_str'] = alloc_details.apply(
        lambda row: f"{row['container_number']} * {int(row['allocated_qty'])}", axis=1)
    details_summary = alloc_details.groupby(['trip_number', 'item_number'])['detail_str'].apply(
        lambda x: '; '.join(x)).reset_index(name='Allocated_Supply_Details')

    alloc_summary = pd.merge(alloc_summary.drop(columns=['Allocated_Supply_Details']), details_summary,
                             on=['trip_number', 'item_number'], how='left')

    # 2. 将分配结果合并回原始需求表
    demand_result = pd.merge(demand_df, alloc_summary, on=['trip_number', 'item_number'], how='left')
    demand_result['Allocated_Supply_Qty'] = demand_result['Allocated_Supply_Qty'].fillna(0).astype(int)
    demand_result['Allocated_Supply_Details'] = demand_result['Allocated_Supply_Details'].fillna('')

    # 3. 计算每个trip的整体状态和满足率以及container数量
    trip_summary = demand_result.groupby('trip_number').agg(
        total_demand=('trip_demand_qty', 'sum'),
        total_allocated=('Allocated_Supply_Qty', 'sum')
    ).reset_index()

    trip_summary['Fulfill_Rate'] = (trip_summary['total_allocated'] / trip_summary['total_demand']).fillna(0)

    # 计算每个trip分配到的distinct container number的个数
    trip_container_count = allocations_df.groupby('trip_number')['container_number'].nunique().reset_index(name='Allocated_Container_Count')
    trip_summary = pd.merge(trip_summary, trip_container_count, on='trip_number', how='left')
    trip_summary['Allocated_Container_Count'] = trip_summary['Allocated_Container_Count'].fillna(0).astype(int)

    # 计算SKUs (每个trip number有多少个unique item numbers)
    trip_skus = demand_df.groupby('trip_number')['item_number'].nunique().reset_index(name='SKUs')
    trip_summary = pd.merge(trip_summary, trip_skus, on='trip_number', how='left')


    def get_trip_status(row):
        if row['total_allocated'] == 0:
            return 'trip no item in yard'
        elif row['total_allocated'] >= row['total_demand']:
            return 'Trip is ready by yard container'
        else:
            return 'trip cannot fulfill by yard container'

    trip_summary['Allocated_Status'] = trip_summary.apply(get_trip_status, axis=1)

    # 4. 将trip级别的状态和满足率合并回结果表
    demand_final = pd.merge(demand_result, trip_summary[['trip_number', 'Allocated_Status', 'Fulfill_Rate', 'Allocated_Container_Count', 'SKUs']],
                            on='trip_number', how='left')
    demand_final['Allocated_Container_Count'] = demand_final['Allocated_Container_Count'].fillna(0).astype(int)
    demand_final['SKUs'] = demand_final['SKUs'].fillna(0).astype(int)

    return demand_final


def process_supply_sheet(supply_df, allocations_df):
    """处理Supply Sheet的计算"""
    if allocations_df.empty:
        supply_df['Allocated_Demand_Qty'] = 0
        supply_df['Allocated_Demand_Details'] = ''
        supply_df['Allocated_Status'] = 'yard container items no demand'
        supply_df['Fulfill_Rate'] = 0
        supply_df['Trip_Counted'] = 0
        supply_df['max_trip_dispatch_date'] = pd.NaT # Add column here to handle empty case
        supply_df['SKUs'] = 0
        return supply_df

    # 1. 计算每个 (container, item) 的分配数量和详情
    alloc_details = allocations_df.copy()
    alloc_details['dispatch_date_str'] = alloc_details['dispatch_date'].dt.strftime('%Y-%m-%d')
    alloc_details['detail_str'] = alloc_details.apply(
        lambda row: f"{row['trip_number']} * {int(row['allocated_qty'])} * {row['dispatch_date_str']}", axis=1)

    details_summary = alloc_details.groupby(['container_number', 'item_number'])['detail_str'].apply(
        lambda x: '; '.join(x)).reset_index(name='Allocated_Demand_Details')
    qty_summary = alloc_details.groupby(['container_number', 'item_number'])['allocated_qty'].sum().reset_index(
        name='Allocated_Demand_Qty')

    alloc_summary = pd.merge(qty_summary, details_summary, on=['container_number', 'item_number'], how='left')

    # 2. 将分配结果合并回原始供应表
    supply_result = pd.merge(supply_df, alloc_summary, on=['container_number', 'item_number'], how='left')
    supply_result['Allocated_Demand_Qty'] = supply_result['Allocated_Demand_Qty'].fillna(0).astype(int)
    supply_result['Allocated_Demand_Details'] = supply_result['Allocated_Demand_Details'].fillna('')

    # 3. 计算每个container的整体状态
    container_summary = supply_result.groupby('container_number').agg(
        total_unreceived=('unreceived_qty', 'sum'),
        total_allocated=('Allocated_Demand_Qty', 'sum')
    ).reset_index()
    
    # Calculate Fulfill_Rate for Supply Sheet
    container_summary['Fulfill_Rate'] = (container_summary['total_allocated'] / container_summary['total_unreceived']).fillna(0)

    # Calculate trip_counted
    container_trip_count = allocations_df.groupby('container_number')['trip_number'].nunique().reset_index(name='Trip_Counted')
    container_summary = pd.merge(container_summary, container_trip_count, on='container_number', how='left')
    container_summary['Trip_Counted'] = container_summary['Trip_Counted'].fillna(0).astype(int)
    
    # Calculate max_trip_dispatch_date
    container_max_date = allocations_df.groupby('container_number')['dispatch_date'].max().reset_index(name='max_trip_dispatch_date')
    container_summary = pd.merge(container_summary, container_max_date, on='container_number', how='left')

    # Calculate SKUs (每个container number有多少个unique item numbers)
    container_skus = supply_df.groupby('container_number')['item_number'].nunique().reset_index(name='SKUs')
    container_summary = pd.merge(container_summary, container_skus, on='container_number', how='left')

    def get_container_status(row):
        if row['total_allocated'] == 0:
            return 'yard container items no demand'
        elif row['total_allocated'] >= row['total_unreceived']:
            return 'whole container ready for trips'
        else:
            return 'Partial container ready for trips'

    container_summary['Allocated_Status'] = container_summary.apply(get_container_status, axis=1)

    # 4. 将container级别的状态合并回结果表
    supply_final = pd.merge(supply_result, container_summary[['container_number', 'Allocated_Status', 'Fulfill_Rate', 'Trip_Counted', 'max_trip_dispatch_date', 'SKUs']],
                            on='container_number', how='left')
    supply_final['Trip_Counted'] = supply_final['Trip_Counted'].fillna(0).astype(int)
    supply_final['max_trip_dispatch_date'] = pd.to_datetime(supply_final['max_trip_dispatch_date']).dt.strftime('%Y-%m-%d %H:%M:%S')
    supply_final['max_trip_dispatch_date'] = supply_final['max_trip_dispatch_date'].fillna('') # Fill NaN with empty string
    supply_final['SKUs'] = supply_final['SKUs'].fillna(0).astype(int)
    return supply_final


# ==========================================
# 主函数
# ==========================================
def main():
    """主执行函数"""
    conn = get_db_connection()
    if not conn:
        return

    # 1. 获取数据
    demand_data = get_demand_data(conn)
    supply_data = get_supply_data(conn)
    conn.close()

    # 2. 执行核心分配逻辑
    allocations = run_allocation(demand_data, supply_data)
    allocations_df = pd.DataFrame(allocations)

    # 3. 分别处理Demand和Supply两个sheet的数据
    demand_sheet_data = process_demand_sheet(demand_data, allocations_df)
    supply_sheet_data = process_supply_sheet(supply_data, allocations_df)

    # 4. 输出到Excel (保存到Downloads文件夹并加入时间戳)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # 动态获取当前用户的 Downloads 文件夹路径
    downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads')

    # 组合完整的文件路径
    output_filename = os.path.join(downloads_path, f"Allocation_Result_{timestamp}.xlsx")

    with pd.ExcelWriter(output_filename, engine='xlsxwriter') as writer:
        demand_sheet_data.to_excel(writer, sheet_name='Demand', index=False)
        supply_sheet_data.to_excel(writer, sheet_name='Supply', index=False)

        # 自动调整列宽
        for sheet_name in writer.sheets:
            worksheet = writer.sheets[sheet_name]
            for idx, col in enumerate(demand_sheet_data if sheet_name == 'Demand' else supply_sheet_data):
                series = (demand_sheet_data if sheet_name == 'Demand' else supply_sheet_data)[col]
                max_len = max((
                    series.astype(str).map(len).max(),
                    len(str(series.name))
                )) + 2
                worksheet.set_column(idx, idx, max_len)

    print(f"\n处理完成！结果已保存到文件: {output_filename}")


if __name__ == '__main__':
    main()