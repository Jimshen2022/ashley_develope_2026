# 5.5.1 创建图片
import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddPicture(r'd:\Users\jishen\Pictures\ID\NICE PIC1.jpg',True,True,100,50,100,100)  # 图片填充


# 图片的几何变换
shp.IncrementRotation(30)    # 绕顺时针方向旋转30度
shp.Flip(0)     # 水平翻转

















