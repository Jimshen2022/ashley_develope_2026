for c in 'python':
    print(c)

for i in range(6):
    print(i)

ads = ['北京', '上海', '广州']
for ad in ads:
    print('当前地点： ', ad)

for index in range(len(ads)):
    print(ads[index])

# 元组用循环
for x in (1, 2, 3):
    print(x)

# 字典用循环
dt = {'grade': 2, 'class': 1, 'name': 'Jim'}
for x in dt:  # 逐个输出键
    print(x)

for x in dt.keys():  # 逐个输出键
    print(x)

for x in dt.values():  # 逐个输出值
    print(x)

for x in dt.items():  # 逐个输出键值对
    print(x)

# 对1~10累加
sum = 0
num = 0
for num in range(11):
    sum += num
print(sum)

# for else 用法
# 判断一个数是否是质数
n = 7
for i in range(2, n):
    if n % i == 0:
        print(str(n) + '不是质数')
        break
else:
    print(str(n) + '是质数')



# for 循环嵌套
for i in range(1,10):
    s = ''
    for j in range(1,i+1):
        s += str.format('{0}*{1}={2}\t',i,j,i*j)
    print(s)





