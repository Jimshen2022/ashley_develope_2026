
# 创建新的工作簿

import openpyxl as pyxl
wb = pyxl.Workbook()

# 也可以这样
from openpyxl import Workbook
wb2 = Workbook()
wb2.save('test.xlsx')

# getcwd 获取当前工作目录及其路径
import os
path = os.getcwd()
print(path)

wb.close()
wb2.close()


