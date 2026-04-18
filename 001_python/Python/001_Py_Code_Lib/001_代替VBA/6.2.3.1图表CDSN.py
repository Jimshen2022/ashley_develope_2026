import cx_Oracle
import xlrd
import xlwt
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False


# 设置坐标轴数值以百分比(%)显示函数
def to_percent(temp, position):
    return '%1.0f' % (1 * temp) + '%'


# 字体设置
font2 = {'family': 'Times New Roman',
         'weight': 'normal',
         'size': 25,
         }

conn = cx_Oracle.connect('用户名/密码@IP:端口/数据库')
c = conn.cursor()
# sql查询语句，多行用()括起来
sql_detail = (
    "select substr(date1,6,10)date1,round(avg(r_qty))r_qty,round(avg(e_qty))e_qty,""round(avg(r_qty)/avg(e_qty),2)*100 userate,round(avg(uptime),2)*100 uptime from 表tp "
    "tp where 条件  "
    "group by date1 order by date1 ")

x = c.execute(sql_detail)
# 获取sql查询数据
data = x.fetchall()
# print(data)

# 新建Excel保存数据
xl = xlwt.Workbook()
ws = xl.add_sheet("ROBOT 30 DAYS MOVE ")
# ws.write_merge(0,1,0,4,"ROBOT_30_DAYS_MOVE")
for i, item in enumerate(data):
    for j, val in enumerate(item):
        ws.write(i, j, val)
xl.save("E:\\ROBOT_30_DAYS_MOVE.xls")

# 读取Excel数据
data1 = xlrd.open_workbook("E:\\ROBOT_30_DAYS_MOVE.xls")
sheet1 = data1.sheet_by_index(0)

date1 = sheet1.col_values(0)
r_qty = sheet1.col_values(1)
e_qty = sheet1.col_values(2)
userate = sheet1.col_values(3)
uptime = sheet1.col_values(4)

# 空值处理
for a in r_qty:
    if a == '':
        a = 0
for a in e_qty:
    if a == '':
        a = 0
for a in userate:
    if a == '':
        a = 0
for a in uptime:
    if a == '':
        a = 0
# 将list元素str转int类型
r_qty = list(map(int, r_qty))
e_qty = list(map(int, e_qty))
userate = list(map(int, userate))
uptime = list(map(int, uptime))
# 添加平均值mean求平均
r_qty.append(int(np.mean(r_qty)))
e_qty.append(int(np.mean(e_qty)))
userate.append(int(np.mean(userate)))
uptime.append(int(np.mean(uptime)))
date1.append('AVG')

# x轴坐标
x = np.arange(len(date1))
bar_width = 0.35

plt.figure(1, figsize=(19, 10))
# 绘制主坐标轴-柱状图
plt.bar(np.arange(len(date1)), r_qty, label='RBT_MOVE', align='center', alpha=0.8, color='Blue', width=bar_width)
plt.bar(np.arange(len(date1)) + bar_width, e_qty, label='EQP_MOVE', align='center', alpha=0.8, color='orange',
        width=bar_width)

# 设置主坐标轴参数
plt.xlabel('')
plt.ylabel('Move', fontsize=18)
plt.legend(loc=1, bbox_to_anchor=(0, 0.97), borderaxespad=0.)
# plt.legend(loc='upper left')
for x, y in enumerate(r_qty):
    plt.text(x, y + 100, '%s' % y, ha='center', va='bottom')
for x, y in enumerate(e_qty):
    plt.text(x + bar_width, y + 100, '%s' % y, ha='left', va='top')
plt.ylim([0, 8000])

# 调用plt.twinx()后可绘制次坐标轴
plt.twinx()

# 次坐标轴参考线
target1 = [90] * len(date1)
target2 = [80] * len(date1)

x = list(range(len(date1)))
plt.xticks(x, date1, rotation=45)

# 绘制次坐标轴-折线图
plt.plot(np.arange(len(date1)), userate, label='USE_RATE', color='green', linewidth=1, linestyle='solid', marker='o',
         markersize=3)
plt.plot(np.arange(len(date1)), uptime, label='UPTIME', color='red', linewidth=1, linestyle='--', marker='o',
         markersize=3)

plt.plot(np.arange(len(date1)), target1, label='90%target', color='black', linewidth=1, linestyle='dashdot')
plt.plot(np.arange(len(date1)), target2, label='80%target', color='black', linewidth=1, linestyle='dashdot')

# 次坐标轴刻度百分比显示
plt.gca().yaxis.set_major_formatter(FuncFormatter(to_percent))

plt.xlabel('')
plt.ylabel('Rate', fontsize=18)
# 图列
plt.legend(loc=2, bbox_to_anchor=(1.01, 0.97), borderaxespad=0.)
plt.ylim([0, 100])
for x, y in enumerate(userate):
    plt.text(x, y - 1, '%s' % y, ha='right', va='bottom', fontsize=14)
for x, y in enumerate(uptime):
    plt.text(x, y + 1, '%s' % y, ha='left', va='top', fontsize=14)

plt.title("ROBOT 30 DAYS MOVE")

# 图表Table显示plt.table()
listdata = [r_qty] + [e_qty] + [userate] + [uptime]  # 数据
table_row = ['RBT_MOVE', 'EQP_MOVE', 'USE_RATE(%)', 'UPTIME(%)']  # 行标签
table_col = date1  # 列标签
print(listdata)
print(table_row)
print(table_col)

the_table = plt.table(cellText=listdata, cellLoc='center', rowLabels=table_row, colLabels=table_col, rowLoc='center',
                      colLoc='center')
# Table参数设置-字体大小太小，自己设置
the_table.auto_set_font_size(False)
the_table.set_fontsize(12)
# Table参数设置-改变表内字体显示比例，没有会溢出到表格线外面
the_table.scale(1, 3)
# plt.show()

plt.savefig(r"E:\\ROBOT_30_DAYS_MOVE.png", bbox_inches='tight')
# 关闭SQL连接
c.close()
conn.close()