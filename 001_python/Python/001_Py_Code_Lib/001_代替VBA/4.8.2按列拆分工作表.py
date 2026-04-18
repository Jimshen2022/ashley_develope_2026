import win32com.client as win32
from win32com.client import Dispatch, constants
import os

app = win32.gencache.EnsureDispatch('excel.application')
app.Visible = True
# root = os.getcwd()
bk = app.Workbooks.Open(r'd:\python_file\AshtonOH8.xlsx')
app.ScreenUpdating = False
app.DisplayAlerts = False
sht = bk.Worksheets('TRX')
irow = sht.Range('a' + str(sht.Rows.Count)).End(constants.xlUp).Row
strs = []  # 创建空列表，用于创建新表

# 遍历数据表每一行
for i in range(2, irow + 1):
    sht2 = bk.Worksheets('TRX')
    strt = sht2.Range('p' + str(i)).Text  # 获取该行Transaction Code
    if (strt not in strs):
        # 如果是新trx code,则将名称添加到strs列表中,复制表头与数据
        strs.append(strt)
        bk.Worksheets.Add(After=bk.Worksheets(bk.Worksheets.Count))
        bk.ActiveSheet.Name = strt
        bk.Worksheets('TRX').Rows(1).Copy(bk.ActiveSheet.Rows(1))
        bk.Worksheets('TRX').Rows(i).Copy(bk.ActiveSheet.Rows(2))
    else:
        # 如果是已存在的部门工作表的名称, 则直接追加数据行
        bk.Worksheets(strt).Select()  # 激活strt的工作表
        r = bk.ActiveSheet.Range('a' + str(bk.ActiveSheet.Rows.Count)).End(constants.xlUp).Row + 1  # 取得strx的最后一行
        bk.Worksheets('TRX').Rows(i).Copy(bk.ActiveSheet.Rows(r))  # 从TRX sheet复制行到 strx Sheet
bk.SaveAs(r'd:\python_file\AshtonOH88.xlsx')
bk.Close()
app.ScreenUpdating = True
app.DisplayAlerts = True

print("finished")








