# 5.3.1 图形平移
import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddShape(1, 100, 50, 200, 100)
ff = shp.Fill
ff.PresetTextured(5)    # 预设纹理, 水滴
shp.IncrementLeft(70)    # 右移70个单位
shp.IncrementTop(50)     # 下移50个单位
shp.IncrementRotation(30)     # 顺时针方向旋转30度
shp.ScaleWidth(0.75,False)   # 宽度*0.75
shp.ScaleHeight(1.75,False)   # 高度*1.75
shp.Flip(0)     # 水平翻转
shp.Flip(1)     # 垂直翻转

