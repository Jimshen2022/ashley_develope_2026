from comtypes.client import CreateObject
app = CreateObject('Excel.Application')
app.Visible=True
bk = app.Workbooks.Add()
sht = bk.Sheets(1)
pts = [[0,0],[72,72],[100,40],[20,50],[90,120],[60,30],[150,90]]
shp = sht.Shapes.AddCurve(pts)

vertArray = shp.Vertices    # 获取多边形的顶点， 读入到一个二维数组中
print(vertArray)

# 用原有图形，创建另外一个
shp2 = sht.Shapes.AddCurve(shp.Vertices)








