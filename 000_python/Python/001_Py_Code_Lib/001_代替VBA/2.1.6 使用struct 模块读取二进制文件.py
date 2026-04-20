from struct import *

f = open(r'd:\python_file\bftest2.cad', 'wb')
f.write(pack('iiii', 10, 10, 100, 200))
f.close()

# 打开二进制文件, mode参数改为'rb'
f = open(r'd:\python_file\bftest2.cad', 'rb')
# 使用unpack函数解包数据, 以元组形式返回
(a, b, c, d) = unpack('iiii', f.read())
print(a, b, c, d)
print(type(a))
