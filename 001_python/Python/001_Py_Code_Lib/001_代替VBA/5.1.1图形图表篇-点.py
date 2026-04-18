import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)
sht.api.Shapes.AddShape(92, 180, 80, 10, 10)   # 括号中第一个数字是图形代码，代替VBA
sht.api.Shapes.AddShape(96, 80, 80, 3, 3)
