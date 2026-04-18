import xlwings as xw

app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets('OH')
sht.select()  # 一定要先选择工作簿，否则以下会报错

# # xlwings
# sht.range('a2').color = (0, 255, 0)  # 绿
# sht.range('c2').color = (0, 0, 255)  # 蓝
# sht.range('e2').color = (255, 0, 0)  # 红
# sht['3:3'].insert(shift='down', copy_origin='format_from_left_or_above')
#
# # xlwings API
# sht.api.Range('A6').Interior.Color = xw.utils.rgb_to_int((0, 255, 0))
# sht.api.Range('c6').Interior.Color = xw.utils.rgb_to_int((0, 0, 255))
# sht.api.Range('e6').Interior.Color = xw.utils.rgb_to_int((255, 0, 0))
# sht.api.Rows('7').Insert(Shift=xw.constants.InsertShiftDirection.xlShiftDown,
#                          CopyOrigin=xw.constants.InsertFormatOrigin.xlFormatFromLeftOrAbove)


# 用循环可以插入多行
# for i in range(4):
#     sht.api.Rows(10).Insert()

# for i in range(10,1,-1):
#     if sht.cells(i,1).value =='R48399':
#         sht.api.Cells(i,1).EntireRow.Insert()
#
# # 插入单列
# sht['B:B'].insert()
# sht.api.Columns(2).Insert()
#
# # 循环插入多列
# for j in range(1,3):
#     sht.cells(1,2).select()
#     wb.selection.api.EntireColumn.Insert()

# 间隔列插入列
for i in range(1,9):
    sht.cells(1,2*i).select()
    wb.selection.api.EntireColumn.Insert()
