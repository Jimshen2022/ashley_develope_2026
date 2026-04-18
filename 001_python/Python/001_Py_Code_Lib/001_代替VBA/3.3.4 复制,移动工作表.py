from openpyxl import Workbook

wb = Workbook()
ws = wb.active
copy_sheet1 = wb.copy_worksheet(ws)
copy_sheet2 = wb.copy_worksheet(ws)
wb.save('test.xlsx')
