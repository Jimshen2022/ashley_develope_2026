import os
f = open(r'd:\python_file\ostest\ostest.txt','w')
f.close()

# isdir 函数判断指定路径是否为目录
print(os.path.isdir(r'd:\python_file\ostest'))

# isfile
print(os.path.isfile(r'd:\python_file\ostest\ostest.txt'))

# exists
print(os.path.exists(r'd:\python_file\ostest\ostest.txt'))

# basename
print(os.path.basename(r'd:\python_file\ostest\ostest.txt'))

# dirname
print(os.path.dirname(r'd:\python_file\ostest\ostest.txt'))

# abspath
print(os.path.abspath('d:\\python_file\\ostest\\ostest.txt'))

# getsize 取得文件大小
print(os.path.getsize(r'd:\python_file\ostest\ostest.txt'))






