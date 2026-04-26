import xlwings as xw


# bk = xw.Book()
# sht = bk.sheets(1)
# sht.api.Shapes.AddShape(1,50,50,100,200)    # 矩形区域   P227
# sht.api.Shapes.AddShape(5,100,100,100,200)    # 圆角矩形区域
# sht.api.Shapes.AddShape(9,150,150,100,200)    # 椭圆形区域
# sht.api.Shapes.AddShape(9,300,200,100,100)    # 圆形区域
#

# 没有阴影填充的   P227
bk = xw.Book()
sht = bk.sheets(1)
shp1 = sht.api.Shapes.AddShape(1,50,50,100,200)    # 矩形区域
shp1.Fill.Visible=False
shp2 = sht.api.Shapes.AddShape(5,100,100,100,200)    # 圆角矩形区域
shp2.Fill.Visible=False
shp3 = sht.api.Shapes.AddShape(9,150,150,100,200)    # 椭圆形区域
shp3.Fill.Visible=False
shp4 = sht.api.Shapes.AddShape(9,300,200,100,100)    # 圆形区域
shp4.Fill.Visible=False



