import xlwings as xw
def extract_non_zero_ordpck():
    # 获取当前活动的工作簿
    wb = xw.books.active

    # 获取源工作表
    source_sheet = wb.sheets['RPOpenOrders']

    # 检查是否已存在目标工作表，如果存在则清空，不存在则创建
    if 'PICKED_PACKED' in [sheet.name for sheet in wb.sheets]:
        target_sheet = wb.sheets['PICKED_PACKED']
        target_sheet.clear()
    else:
        target_sheet = wb.sheets.add('PICKED_PACKED')

    # 获取源工作表的数据范围
    # 首先获取使用的行数和列数
    last_row = source_sheet.used_range.last_cell.row
    last_col = source_sheet.used_range.last_cell.column

    # 读取源工作表的所有数据（包括表头）
    data = source_sheet.range((1, 1), (last_row, last_col)).value

    # 如果数据为空，则退出函数
    if not data:
        return "没有数据可处理"

    # 找到ORDPCK列的索引
    headers = data[0]
    try:
        ordpck_col_index = headers.index('ORDPCK')
    except ValueError:
        return "找不到ORDPCK列"

    # 筛选ORDPCK不为0的行（包括表头）
    filtered_data = [headers]  # 首先添加表头
    for row in data[1:]:  # 从第二行开始（跳过表头）
        # 确保行有足够的列
        if len(row) > ordpck_col_index:
            # 检查ORDPCK值是否不为0
            ordpck_value = row[ordpck_col_index]
            if ordpck_value and ordpck_value != 0:
                filtered_data.append(row)

    # 将筛选后的数据写入目标工作表
    if len(filtered_data) > 1:  # 如果有数据（除了表头）
        target_sheet.range('A1').value = filtered_data
        # 自动调整列宽以适应内容
        target_sheet.autofit('columns')
        return f"已成功提取{len(filtered_data) - 1}条记录到PICKED_PACKED工作表"
    else:
        return "没有找到ORDPCK不为0的记录"


# 执行函数
result = extract_non_zero_ordpck()
print(result)