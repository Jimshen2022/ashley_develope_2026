# 2.2.1 文件操作

# 创建新的文本文件
import os

f = os.open(r'd:\python_file\ostest.txt', os.O_RDWR|os.O_CREAT|os.O_TEXT)
# 用utf-8写入字符串
os.write(f,'Hello Python!'.encode('utf-8'))
# 关闭文件
os.close(f)

f = os.open(r'd:\python_file\ostest.txt',os.O_RDONLY)
ct = os.read(f,18).decode('utf-8')
print(ct)
os.close(f)

# 删除文件
# os.remove(r'd:\python_file\filetest.text')

# 文件改名
# os.rename(r'd:\python_file\filetest2.text',r'd:\python_file\jimtest.text')

# access函数判断文件的读写等权限
print(os.access(r'd:\python_file\ostest2.txt',os.W_OK))   # 写的权限
print(os.access(r'd:\python_file\ostest2.txt',os.R_OK))   # 读的权限
print(os.access(r'd:\python_file\ostest2.txt',os.X_OK))   # 执行的权限


