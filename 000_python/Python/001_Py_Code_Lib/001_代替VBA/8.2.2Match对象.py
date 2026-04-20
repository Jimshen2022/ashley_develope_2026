# Match对象的属性
import re
a = 'aBC123dEf456abc789abC'
m = re.search(r'(\d+)(\w+)',a)

m.string   # 返回原始字符串
m.re
m.pos
m.endpos
m.lastindex     # 最后一个捕获分组的索引号
m.lastgroup    # 最后一个捕获分组的别名,这里没有

m.group(1)
m.group(2)
m.group(1,2)
m.groups
d = m.groupdict()
m.start(1)    # 第1个分组捕获字符串的起始位置索引号
m.end(1)    # 第1个分组捕获字符串的终止位置索引号
m.start(2)    # 第2个分组捕获字符串的起始位置索引号
m.end(2)    # 第2个分组捕获字符串的终止位置索引号
m.span(1)    # 第1个分组捕获字符串的位置索引范围
m.span(2)    # 第2个分组捕获字符串的位置索引范围






