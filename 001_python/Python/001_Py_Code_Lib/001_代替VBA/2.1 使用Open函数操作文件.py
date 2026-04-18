# 2.1.1 open 函数
f = open(r'd:\python_file\filetest.text','w')
f.write('hello world!')
f.close()

with open (r'd:\python_file\filetest2.text','w') as f:
    f.write('hello JimShen~~')


f3 = open(r'd:\python_file\filetest4.text','w')
f3.writelines(['hello python\n','hello Excel!'])
f3.close()

f4 = open(r'd:\python_file\filetest5.txt','w')
for i in range(10):
    f4.write('Hello Python!\r\n')
f4.close()