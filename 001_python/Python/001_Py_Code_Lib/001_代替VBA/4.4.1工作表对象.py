import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
ws = wb.sheets

# 遍历工作表,根据现有工作表新增工作表
# for i in range(len(ws)):
#     print(ws[i].name)
#     if ws[i].name == '20220729':
#         wb.sheets.add(after=ws.count)

# 插入工作表
wb.sheets.add(before=wb.sheets(5))
# wb.api.Worksheets.Add(Before=wb.api.Worksheets(2),Count=3)     # Count=3 表示一次插入3张工作表

# 插入一个图表工作表
wb.api.Sheets.Add(Type=xw.constants.SheetType.xlChart)     # 插入chart图工作表, sheet包含所有类型工作表， worksheet只包含一般工作表


# 引用工作表
sht = wb.sheets[0]
sht1 = wb.sheets[1]
sht3 = wb.sheets['OH']
sht4 = wb.sheets['Sheet3']
a0 = sht.name

# 改工作表名
# sht.name = 'data2'





