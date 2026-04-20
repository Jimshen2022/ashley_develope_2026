import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddLine(80, 50, 200, 300)
lf = shp.Line  # 获取线对象
lf.Weight = 2  # 线宽
lf.Pattern=16  # 给直线段设置图案填充

lf.BeginArrowheadLength = 1  # 起点处箭头的长度
lf.BeginArrowheadStyle = 6  # 起点处箭头的样式
lf.BeginArrowheadWidth = 1  # 起点处箭头的宽度
lf.EndArrowheadLength = 3  # 起点处箭头的长度
lf.EndArrowheadStyle = 2  # 起点处箭头的样式
lf.EndArrowheadWidth = 2  # 起点处箭头的宽度


sht.api.Shapes.AddShape(9,150,50,200,100)
shp2 = sht.api.Shapes.AddLine(100,75,400,75)
shp2.Line.Weight = 8  # 线宽
shp2.Line.ForeColor.RGB = xw.utils.rgb_to_int((255,0,0))   # 红色
shp3 = sht.api.Shapes.AddLine(100,125,400,125)
shp3.Line.Weight = 8  # 线宽
shp3.Line.ForeColor.RGB = xw.utils.rgb_to_int((255,0,0))   # 红色
shp3.Line.Transparency = 0.7








