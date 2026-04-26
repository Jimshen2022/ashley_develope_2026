import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp2 = sht.api.Shapes.AddShape(9, 400, 50, 200, 100)  # 椭圆
rng = sht.api.Range('c3:e5')
shp2.Left = rng.Left + 10  # 根据图形和区域的位置与大小属性进行固定
shp2.Top = rng.Top + 10
shp2.Width = rng.Width - 2
shp2.Height = rng.Height - 2
#
# ff2 = shp2.Fill
# ff2.ForeColor.RGB = xw.utils.rgb_to_int((0, 0, 255))  # 面的填充色
# ff2.OneColorGradient(7, 1, 1)  # 单色渐变色填充, 白色到蓝色,从中心到各个角度渐变
