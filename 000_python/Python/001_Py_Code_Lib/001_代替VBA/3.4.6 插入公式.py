from openpyxl import Workbook
wb = Workbook()
sht = wb.active
sht['c1'] = 10
sht['c2'] = 20
sht['c3'] = '=SUM(C1:C2)'
wb.save(r'D:\python_file\InsertFormulas.xlsx')

