import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets['OH']
sht.select()

# 垂直与水平对齐

sht.range('c3').api.HorizontalAlignment = xw.constants.Constants.xlCenter
sht.range('c3').api.VerticalAlignment = xw.constants.Constants.xlCenter

# 设置背景色
sht.range('a1:g1').color = (210,67,9)       # 暗红色
sht['a:a,b2,c5,d7:e9'].color = (100,200,150)   # 青色

sht.range('a9:g9').api.Interior.Color = xw.utils.rgb_to_int((0,255,0))   # 绿色
sht.range('a10:g10').api.Interior.Color = 65280                          # 绿色
sht.range('a11:g11').api.Interior.ColorIndex = 6   # 黄色
sht.range('a12:g12').api.Interior.ThemeColor = 5   # 蓝色

# 边框
sht.range('b2').api.CurrentRegion.Borders.LineStyle = xw.constants.LineStyle.xlContinuous

# 黑色边框
sht.range('b2').api.CurrentRegion.Borders.ColorIndex = 0

# xlThin细线, xlThick粗线
sht.range('b2').api.CurrentRegion.Borders.Weight = xw.constants.BorderWeight.xlThin







