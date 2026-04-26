from comtypes.client import CreateObject
app = CreateObject('Excel.Application')
app.Visible=True
bk = app.Workbooks.Add()
sht = bk.Sheets(1)
shp = sht.Shapes.AddLabel(1,100,20,60,150)    # 添加标签
shp.TextFrame.Characters.Text = 'Test Python Label'   # 标签文本, bug




