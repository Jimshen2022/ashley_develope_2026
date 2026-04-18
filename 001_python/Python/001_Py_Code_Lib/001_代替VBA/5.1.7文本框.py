import xlwings as xw
bk = xw.Book()
sht = bk.sheets(1)
shp = sht.api.Shapes.AddTextbox(1,10,10,100,100)
shp.TextFrame.Characters.Text = 'Test Box'

