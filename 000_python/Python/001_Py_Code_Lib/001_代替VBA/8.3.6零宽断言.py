# 查找指定内容之前或之后的内容, 不包括指定内容
import re
a = "10kg, 20kg, 30kg"
m = re.finditer(r'\d+(?=kg,?)',a)
for i in m:
    print(i.group())

b = '同学李海 战友李则 师兄王三'
m1 = re.finditer(r'(?<=同学|战友|师兄)\w+',b)
for i in m1:
    print(i.group())
