import xlwings as xw
bk = xw.Book()
sht = bk.sheets(1)
shp = sht.api.Shapes.AddTextEffect(9,'学习Python','Arial Black',36,False,False,10,10)   # p236
sht.api.Shapes.AddTextEffect(29,'春眠不觉晓','黑体',40,False,False,30,50)
