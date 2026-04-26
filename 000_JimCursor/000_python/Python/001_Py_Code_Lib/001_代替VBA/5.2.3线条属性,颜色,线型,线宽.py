import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddLine(20, 20, 100, 100)
lf = shp.Line
lf.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))
lf.DashStyle = 5  # 线型,点虚线
lf.Weight = 1  # 线宽

shp2 = sht.api.Shapes.AddShape(9, 200, 30, 120, 80)
lf2 = shp2.Line  # 椭圆形区域中的线形对象,即区域的边线
lf2.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))  # 红色
lf2.DashStyle = 3
lf2.Weight = 1  # 线宽
