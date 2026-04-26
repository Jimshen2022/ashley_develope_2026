list1 = "a,b,c,d,e,f,g"
a = list1.split(',')    # 以列表形式输出

a1 = 'hello'
b1 = 'python'
print(a1+b1)

def 合并(x,y):
    return x+y
a3=合并('520','1314')
print(a3)

a4 = "a b c".split()
print(a4)

a5 = 'python '
print(a5*3)

a7 = ','
a8 = 'abc'
a9 = a7.join(a8)    # 也可以将列表换成字符串
print(a9)

a10 = " ab cd ".strip(" ")     # 去除字符串首尾指定字符串
print(a10)

a11 = " ab cd ".strip()     # 去除字符串首尾空白字符
print(a11)

a12 = " ab cd ".lstrip(" ")
a13 = " ab cd ".rstrip()
print(a12)
print(a13)

a14 = '1234abcde'
del a14





