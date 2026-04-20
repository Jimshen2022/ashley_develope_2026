# -*- coding UTF-8 -*-
import pyodbc
import pandas as pd

# 使用 pyodbc 的 with 语句来自动管理连接
with pyodbc.connect('DSN=MILPROD; PWD=MJ2077', autocommit=True) as cnxn:
    cursor = cnxn.cursor()

    # 执行 SQL 查询
    query = """
    Select SYSTEM_TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, varchar(COLUMN_TEXT, 50) As COLUMN_DESC 
    From QSYS2.SYSCOLUMNS
    Where SYSTEM_TABLE_SCHEMA in ('AMFLIBL','AFILELIBL','LLUSAF','DISTLIBL','LLUSAF','ASHLEYARCL','RGNFILL')
    """

    # 分页批量读取数据，减少内存压力
    batch_size = 10000
    cursor.execute(query)

    # 获取列名
    columns = [column[0] for column in cursor.description]

    # 初始化输出文件
    output_file = 'MIL_SCHEMA_V02.csv'

    # 分批写入CSV文件，避免内存占用过多
    with open(output_file, 'w', encoding='utf-8-sig') as f:
        is_first_chunk = True
        while True:
            batch = cursor.fetchmany(batch_size)
            if not batch:
                break
            # 使用 pandas 将批次数据转换为 DataFrame 并写入 CSV 文件
            df = pd.DataFrame.from_records(batch, columns=columns)
            df.to_csv(f, header=is_first_chunk, index=False, mode='a', encoding='utf-8-sig')
            is_first_chunk = False

# 打印提示信息，表示数据已经成功导出
print(f"Data successfully exported to {output_file}")
