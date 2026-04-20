import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddShape(1, 100, 50, 200, 100)
# shp1 = sht.api.Shapes.AddShape(2,100,50,200,100)
# shp2 = sht.api.Shapes.AddShape(3,100,50,200,100)
# shp3 = sht.api.Shapes.AddShape(4,100,50,200,100)
# shp4 = sht.api.Shapes.AddShape(5,100,50,200,100)
ff = shp.Fill
ff.ForeColor.RGB = xw.utils.rgb_to_int((0, 255, 0))  # 面的填充色
ff.Transparency = 0.7  # 透明度为0.7


ff.Solid