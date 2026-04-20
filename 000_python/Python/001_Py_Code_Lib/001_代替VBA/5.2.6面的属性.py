import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddShape(1, 100, 50, 200, 100)   # 矩形
ff = shp.Fill
ff.Solid    # 单色填充
ff.TwoColorGradient(3,1)    # 双色渐变填充
ff.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))  # 面的填充色   # 起始颜色
ff.BackColor.RGB = xw.utils.rgb_to_int((0,255, 0))  # 面的填充色   # 终止颜色

# ff.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))  # 面的填充色
# ff.OneColorGradient(3,1,1)  # 单色渐变色填充, 白色到红色,从右下角到左上角渐变
# # 在渐变序列中插入颜色节点
# ff.GradientStops.Insert(xw.utils.rgb_to_int((255,0,0)),0.25)
# ff.GradientStops.Insert(xw.utils.rgb_to_int((0,255,0)),0.5)
# ff.GradientStops.Insert(xw.utils.rgb_to_int((0,0,255)),0.75)




# shp2 = sht.api.Shapes.AddShape(9,400, 50, 200, 100)     # 椭圆
# ff2 = shp2.Fill
# ff2.ForeColor.RGB = xw.utils.rgb_to_int((0, 0, 255))  # 面的填充色
# ff2.OneColorGradient(7,1,1)  # 单色渐变色填充, 白色到蓝色,从中心到各个角度渐变
#
#
