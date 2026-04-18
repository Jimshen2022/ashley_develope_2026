# 1.11.1
# 4. 有嵌套的判断结构

y = 2020
if y % 400 == 0:  # 判断是否是世纪闰年
    yn = True
elif y % 4 == 0:  # 判断是否是普通闰年  (注意： 普通闰年能被4整除，不能被100整除）
    if y % 100 > 0:
        yn = True
    else:
        yn = False
else:
    yn = False
if yn:
    print('{0}年是闰年。'.format(y))
else:
    print('{0}年不是闰年。'.format(y))

# 5. 三元操作符

a = int(input('Please enter a number:    '))
print('>=10' if a >= 10 else '<10')


x,y,z = 10,30,20
small = (x if x < y else y)
small = (z if small > z else small)
print(small)