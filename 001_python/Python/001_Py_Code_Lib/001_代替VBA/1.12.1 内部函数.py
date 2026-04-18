# # type, format, range, slice, len
#
# a = list(range(10))
# print(a)
#
# slice1 = slice(6)  # 取前6个元素
# slice2 = slice(2, 9, 2)  # 取前2-8范围内隔一个数取一个数
#
# print(a[slice1])
# print(a[slice2])

a1 = list(range(-5, 5))
print(a1)

a2 = sorted(a1, reverse=True)  # 对列表元素逆序排列


def filtertest(a):  # 定义一个函数,过滤规则为列表中的元素值大于0
    return a > 0


a3 = filter(filtertest, a1)    # 用函数定义的规则对列表a1进行过滤
a4 = list(a3)
print(a4)













