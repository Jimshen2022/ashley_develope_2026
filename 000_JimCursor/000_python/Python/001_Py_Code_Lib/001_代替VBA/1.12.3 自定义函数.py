# 1. 函数定义和调用
def starline():
    '星号分隔符'
    print('*' * 40)
    return


a = 1;
b = 2
print('a={},b={}'.format(1, 2))
print('a+b={}'.format(a + b))
starline()
print('a={},b={}'.format(1, 2))
print('a-b={}'.format(a - b))
starline()
print('a={},b={}'.format(1, 2))
print('a={},b={}'.format(1, 2))
print('a*b={}'.format(a * b))
help(starline)


def mysum(a, b):
    '求两个数的和'
    return a + b


print('3+6={}'.format(mysum(3, 6)))
print('12+9={}'.format(mysum(12, 9)))


# 2. 有多个返回值的情况, 如下例返回两个参数的和与差
def mycomp(a, b):
    c = a + b
    d = a - b
    return c, d


c, d = mycomp(2, 3)
print('2+3={}'.format(c))
print('2-3={}'.format(d))


def mycomp2(a, b):
    data = []
    data.append(a + b)
    data.append(a - b)
    return data


data = mycomp2(15, 10)
print(data)


# 3 默认参数
def defaultpara(id, score=80):
    print('ID:', id)
    print('Score: ', score)
    return


defaultpara('No001')


# 4 可变参数
def mysum2(arg1, *vartuple):
    sum = arg1
    for var in vartuple:
        sum += var
    return sum


x = mysum2(10, 10, 20, 30)
print(x)


# 5 参数为字典
def paradict(**vdict):
    print(vdict)
paradict(id='No.001',score=80)


# 6 传值还是传址 p74
def TP(a):
    a = 'Python'
b = 'hello'
TP(b)
print(b)


def TP1(lst):
    lst.append([6,7,8,9])
    return
lst = [1,2,3,4,5]
print(lst)
TP1(lst)
print(lst)






