from comtypes.client import CreateObject

app = CreateObject('Excel.Application')
app.Visible = True
bk = app.Workbooks.Add()
sht = bk.Sheets(1)
pts = [[0, 0], [72, 72], [100, 40], [20, 50], [90, 120], [60, 30], [150, 90]]  # 顶点
sht.Shapes.AddCurve(pts)
