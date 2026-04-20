import  xlwings as xw
bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddLine(10,10,50,50)
lf = shp.Line

shp2 = sht.api.Shapes.AddShape(9,50,50,200,100)
lf2 = shp2.Line

