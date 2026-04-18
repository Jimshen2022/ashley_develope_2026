import win32api
import win32com.client as win32
import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
ws = wb.sheets
sht = ws['OH']
sht.api.Range('A1').CurrentRegion.SpecialCells(xw.constants.CellType.xlCellTypeBlanks).Select()  # 选择空白的单元格











