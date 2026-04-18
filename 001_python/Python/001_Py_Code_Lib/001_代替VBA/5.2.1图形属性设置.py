# 5.2.1 颜色设置
import xlwings as xw
bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddShape(9,50,50,100,100)
# shp.Fill.ForeColor.RGB = xw.utils.rgb_to_int((0,255,0))
# shp.Line.ForeColor.RGB = xw.utils.rgb_to_int((0,0,255))
#
# shp.Fill.ForeColor.RGB = 65280
# shp.Line.ForeColor.RGB = 16711680
# shp.Fill.ForeColor.RGB = 0xFF0000

# 主题颜色着色
# shp.Fill.ForeColor.ObjectThemeColor = 10
# shp.Line.ForeColor.ObjectThemeColor = 3

# 配色方案着色
# shp.Fill.ForeColor.SchemeColor = 3
# shp.Line.ForeColor.SchemeColor = 4

# 索引着色
sht.api.Range('c3').Font.ColorIndex=3
sht.api.Range('c3').Value="hello"







