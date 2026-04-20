# 使用(), tuple, zip函数创建元组.

t = ('a',0,{},False)
t1 = 'a',0,{},False
t2 = (1,)     # 如果元组只有一个元素, 则必须在未尾加逗号
t3 = (1)  # int

a = tuple()
a1 = tuple('abcde')
a2 = tuple(range(5))
a3 = tuple([1,2,3,4,5])
a4 = tuple({1:'Jane',2:'Jim'})
a5 = tuple({1,2,3,4,'jim'})


c = [1,2,3]
d = [4,5,6]
a6 = zip(c,d)
a7 = list(a6)   # 使用list函数可以将zip对象转换为列表

