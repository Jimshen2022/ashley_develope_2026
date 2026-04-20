import os

list1 = os.listdir('C:')
print(list1)

# mkdir 函数创建一个新目录
# os.mkdir('d:\ostest5')

# getcwd函数获取当前目录
# file1 = os.mkdir('d:\python_file\ostest1')
# path1 = os.getcwd()
# print(file1)
# print(path1)

# 改变当前工作目录
os.chdir('d:\\python_file')
print(os.getcwd())

# 删除一个空目录
os.rmdir(r'd:\python_file\ostest1')











