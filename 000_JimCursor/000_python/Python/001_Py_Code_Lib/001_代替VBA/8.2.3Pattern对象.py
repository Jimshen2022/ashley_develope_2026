# 利用re.compile函数创建pattern对象（即正则表达式对象), 利用该对象，也可以实现字符串的查找，替换和分割  P333
import re

# 1. Pattern对象的方法：
a = 'aBc12-3def456ABC17-89abc123def456abc12-3abc1'
p = re.compile('-',re.I)   # 创建pattern对象
m5 = p.findall(a,13,99)    # 查找
m6 = p.sub('jim',a,99)      # 替代
m7 = p.split(a,2)          # 分割

print(p)
print(m5)
print(m6)
print(m7)


# 2.Pattern对象的属性

b = 'aBc123def456ABC1789abc123def456abc123abc1'
p1 = re.compile('abc1',re.I)
m1 = p1.pattern      # 正则表达式字符串
m2 = p1.flags        # 匹配方式，用数字表示
m3 = p1.groups       # 正则表达式中分组的个数
m4 = p1.groupindex   # 以正则表达式中有别名的分组的别名为键，以该分组的编号为值的字典
