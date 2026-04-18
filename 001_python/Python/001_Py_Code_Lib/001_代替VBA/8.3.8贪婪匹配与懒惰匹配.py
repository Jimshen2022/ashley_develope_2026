# P353
'''
*?      重复任意次, 但尽可能少重复;
+?      重复一次或更多, 但尽可能少重复
??      重复0次或一次, 但尽可能少重复
{n,m}?  重复n-m次, 但尽可能少重复
{n,}?   重复n次以上, 但尽可能少重复
'''

import re
# a = ' 123 abc53 59wt '
# m = re.finditer(r'\s.+\s',a)   # 在两个空白符间匹配
# for i in m:
#     print(i.group())   # 会匹配出整个字符串


a1 = ' 123  abc53  jim  59wt '
m1 = re.finditer(r'\s.+?\s', a1)  # 在两个空白符间匹配;
for j in m1:
    print(j.group())  # 会匹配出整个字符串




