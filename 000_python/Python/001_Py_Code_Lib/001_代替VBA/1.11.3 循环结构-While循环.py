# sum = 0
# num = 0
# while num <= 10:  # 循环累加
#     sum += num
#     num += 1
# print(sum)
#
# # 有分支的while循环
# sum = 0
# n = 0
# while (n<=10):
#     sum += n
#     n += 1
# else:
#     print('数字超出0-10的范围,计算终止.')
# print(sum)

# While循环嵌套
i = 0
while i < 9:
    j = 0
    i += 1
    s = ''
    while j < i:
        j +=1
        s += str.format('{0}*{1}={2}\t', i, j, i * j)
    print(s)


i = 0
while i<9:
    j = 0
    i +=1
    s =''
    for j in range(1,i+1):
        s += str.format('{0}*{1}={2}\t',i,j,i*j)
    print(s)