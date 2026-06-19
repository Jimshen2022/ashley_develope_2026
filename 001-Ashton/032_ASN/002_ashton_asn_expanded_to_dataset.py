import pandas as pd
import pyodbc

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


def fetch_and_expand_asn():
    """
    连接数据库获取近 7 天 ASN 数据，并使用 Pandas 在内存中展开 Serial Number
    """
    # 初始化一个空的 DataFrame 以防止后续合并报错
    df_final = pd.DataFrame()

    try:
        conn_str = get_connection_string()

        # 使用 with 语句，确保查询完毕后自动关闭连接
        with pyodbc.connect(conn_str) as conn:

            # ---------------------------------------------------------
            # 1. 读取基础 ASN 数据
            # ---------------------------------------------------------
            sql_asn = """
                      SELECT * \
                      FROM t_asn WITH (NOLOCK)
                     -- WHERE expected_arrival >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
                        where status IN ('NEW', 'CHECKED IN', 'CLOSED') \
                      """
            df_asn = pd.read_sql(sql_asn, conn)

            if df_asn.empty:
                return df_final

            # ---------------------------------------------------------
            # 2. 提取 asn_id 列表并查询 detail 表
            # ---------------------------------------------------------
            asn_ids = tuple(df_asn['asn_id'].tolist())

            # 处理单元素 Tuple 的格式化问题
            if len(asn_ids) == 1:
                asn_ids_str = f"({asn_ids[0]})"
            else:
                asn_ids_str = str(asn_ids)

            sql_detail = f"SELECT * FROM t_asn_detail WITH (NOLOCK) WHERE asn_id IN {asn_ids_str}"
            df_detail = pd.read_sql(sql_detail, conn)

            if df_detail.empty:
                return df_asn

                # ---------------------------------------------------------
            # 3. 核心魔法：Pandas 内存展开 Serial Number
            # ---------------------------------------------------------
            df_detail['serial_number_start'] = df_detail['serial_number_start'].astype(int)
            df_detail['serial_number_end'] = df_detail['serial_number_end'].astype(int)

            # 生成区间列表
            df_detail['sn_list'] = df_detail.apply(
                lambda row: list(range(row['serial_number_start'], row['serial_number_end'] + 1)),
                axis=1
            )

            # Explode: 将列表炸开成多行
            df_expanded_sn = df_detail.explode('sn_list').rename(columns={'sn_list': 'serial_number'})
            df_expanded_sn = df_expanded_sn.drop(columns=['serial_number_start', 'serial_number_end'])

            # ---------------------------------------------------------
            # 4. 数据合并 (Merge)
            # ---------------------------------------------------------
            df_final = pd.merge(df_asn, df_expanded_sn, on='asn_id', how='inner')

    except pyodbc.Error as ex:
        # 在 Power BI 中使用 raise 抛出错误，以便在刷新失败时能在面板上看到具体的 SQL 报错信息
        raise Exception(f"[数据库连接/查询错误]: {ex}")
    except Exception as e:
        raise Exception(f"发生未预期的错误: {e}")

    return df_final


# ==========================================
# 触发执行与 Power BI 数据源暴露
# 注意：Power BI 只会读取全局环境下的 DataFrame 对象
# ==========================================
df_asn_expanded = fetch_and_expand_asn()