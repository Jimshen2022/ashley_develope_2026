import xlwings as xw
from xlwings.constants import Direction
import os

app = xw.App(visible=True, add_book=False)
bk = app.books.open(r'd:\python_file\bk4.xlsx')
app.screen_updating = False
app.display_alerts = False
sht = bk.sheets('TRX')
irow = sht.api.Range('a' + str(sht.api.Rows.Count)).End(Direction.xlUp).Row
strs = []
# 遍历数据表的每一行
for i in range(2, irow + 1):
    sht2 = bk.api.Worksheets('TRX')
    strt = sht2.Range('P' + str(i)).Text
    if (strt not in strs):
        # 如果是新部门，则添加名称到strs列表中,复制表头和数据
        strs.append(strt)
        bk.api.Worksheets.Add(After=bk.api.Worksheets(bk.api.Worksheets.Count))
        bk.api.ActiveSheet.Name = strt
        bk.api.Worksheets('TRX').Rows(1).Copy(bk.api.ActiveSheet.Rows(1))
        bk.api.Worksheets('TRX').Rows(i).Copy(bk.api.ActiveSheet.Rows(2))
    else:
        # 如果是已经存在的工作表的名称,则直接追加数据行
        bk.api.Worksheets(strt).Select()
        r = bk.api.ActiveSheet.Range('a' + str(bk.api.ActiveSheet.Rows.Count)).End(Direction.xlUp).Row + 1
        bk.api.Worksheets('TRX').Rows(i).Copy(bk.api.ActiveSheet.Rows(r))

# 删除新生成的工作表的第p列
for i in range(4, bk.api.Worksheets.Count + 1):
    bk.api.Worksheets(i).Columns(16).Delete()
app.screen_updating = True
app.display_alerts = True

bk.save(r'd:\python_file\bk8.xlsx')
bk.close()
print('done')
