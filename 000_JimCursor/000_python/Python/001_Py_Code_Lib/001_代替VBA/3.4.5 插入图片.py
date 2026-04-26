from openpyxl import load_workbook
from openpyxl.drawing.image import Image
from openpyxl import Workbook

wb = Workbook()
sht = wb.active
img_file = r'd:\Users\jishen\Pictures\B6 racking\IMG_20190323_112048.jpg'
img = Image(img_file)

# 调整图片大小
img.width = 260
img.height = 260
sht.add_image(img,'a1')

# 调整A1的宽度与高度
sht['a1'].value = 'JimShen'
sht.column_dimensions['a'].width = 37
sht.row_dimensions[1].height = 201

wb.save(r'd:\python_file\B6_racking_pic_01.xlsx')


