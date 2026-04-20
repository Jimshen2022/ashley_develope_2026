import xlwings as xw
bk = xw.Book()
sht = bk.sheets(1)
shp = sht.api.Shapes.AddCallout(2,10,10,200,50)
shp.TextFrame.Characters.Text = 'Test Box'
