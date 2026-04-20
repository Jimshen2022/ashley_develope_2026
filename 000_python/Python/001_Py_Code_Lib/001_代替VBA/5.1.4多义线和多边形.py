from comtypes.client import CreateObject

# app2 = CreateObject('Excel.Application')
# app2.Visible = True
# bk2 = app2.Workbooks.Add()
# sht2 = bk2.Sheets(1)
# pts = [[10, 10], [50, 150], [90, 80], [70, 30], [10, 10]]
# shp = sht2.Shapes.AddPolyline(pts)    # 添加多边形区域
# shp.Fill.Visible = False    # 多边形不填充

app2 = CreateObject('Excel.Application')
app2.Visible = True
bk2 = app2.Workbooks.Add()
sht2 = bk2.Sheets(1)
pts = [[10, 10], [50, 150], [90, 80], [70, 30], [10, 10]]
shp = sht2.Shapes.AddPolyline(pts)
shp.Fill.Visible = True    # 多边形填充
