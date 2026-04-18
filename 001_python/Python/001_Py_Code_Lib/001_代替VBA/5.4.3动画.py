import xlwings as xw
import time

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddShape(1, 100, 100, 200, 20)   # 矩形
ff = shp.Fill.PresetTextured(5)    # 预设纹理
for i in range(36):      # 循环，动画次数
    shp.IncrementRotation(10)     # 每次动画顺时针方向旋转10度
    time.sleep(1)