import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)
sht.api.Range("a1").Value='苏州市昆山市'
ft = sht.api.Range("a1").Font
ft.Name = '黑体'
ft.ColorIndex=3
ft.Size=20
ft.Bold=True
ft.Strikethrough=False
ft.Underline=5
ft.Italic=True

