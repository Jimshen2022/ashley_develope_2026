import xlwings as xw
from xlwings.utils import rgb_to_int

wb = xw.Book(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets['OH']
sht.select()
cl = sht.cells(3, 3)
cl.name = 'test'
sht.range('test').color = (0, 255, 0)  # 单元格背景色

ck = sht.range('a2:g8')
ck.name = 'test2'
sht.range('test2').color = (176, 196, 222)

# 插入批注
sht.api.Range('A3').AddComment(Text='单元格批注')

# 判断是否有批注
if sht.api.Range('a3').Comment is None:
    print('no comment in A3')
else:
    print('Has Comment in A3')

# hide the comment
sht.api.Range('a3').Comment.Visible = False

# delete comment
sht.api.Range('a3').Comment.Delete()

# Font属性
sht.api.Range('a2:g100').Font.Name = 'Calibri'

# 同下列，改单元格字体颜色 三种方式
sht.range('c4').api.Font.ColorIndex = 3
sht.api.Range('a2:g100').Font.ColorIndex = 12
sht.api.Range('a1:g1').Font.Color = xw.utils.rgb_to_int((0,0,0))

# 将单元格中部分字符改字体颜色
start_index = 3  # 下标从1开始
length_string = 1  # 修改长度
sht.range('A1').api.GetCharacters(start_index, length_string).Font.Color = rgb_to_int((255, 0, 0))  # 设为红色

# 单元格区域颜色
sht.range('a5:g5').api.Font.ThemeColor = 5
sht.range('a6:g6').api.Font.ColorIndex = 3

# 字体大小形状
sht.api.Range('a1:g100').Font.Size = 12
sht.api.Range('a1:g100').Font.Bold = True    # 加粗
sht.api.Range('a1:g100').Font.Italic = True     # 斜体

# 下划线 4普通 5双下划线 -4119粗双下划线
sht.range('C1').api.Font.Underline = True
sht.range('C2').api.Font.Underline = 5
sht.range('C3').api.Font.Underline = -4119


















# coding: utf-8

# import xlwings as xw
#
# app=xw.App(visible=False,add_book=False)
# filepath = '../data/test.xlsx'
# wb=app.books.open(filepath)
# sht = wb.sheets('Sheet1')
# font_name = sht.range('A1').api.Font.Name	# 获取字体名称
# font_size = sht.range('A1').api.Font.Size	# 获取字号
# bold = sht.range('A1').api.Font.Bold		# 获取是否加粗，True--加粗，False--未加粗
# color = sht.range('A1').api.Font.Color		# 获取字体颜色
# print(font_name)
# print(font_size)
# print(bold)
# print(color)
# print('-----设置-----')
# sht.range('A1').api.Font.Name = 'Times New Roman'	# 设置字体为Times New Roman
# sht.range('A1').api.Font.Size = 15			# 设置字号为15
# sht.range('A1').api.Font.Bold = True		# 加粗
# sht.range('A1').api.Font.Color = 0x0000ff	# 设置为红色RGB(255,0,0)
# font_name = sht.range('A1').api.Font.Name	# 获取字体名称
# font_size = sht.range('A1').api.Font.Size	# 获取字体大小
# bold = sht.range('A1').api.Font.Bold		# 获取是否加粗，True--加粗，False--未加粗
# color = sht.range('A1').api.Font.Color		# 获取字体颜色
# print(font_name)
# print(font_size)
# print(bold)
# print(color)
# wb.save()
# wb.close()
# app.quit()
