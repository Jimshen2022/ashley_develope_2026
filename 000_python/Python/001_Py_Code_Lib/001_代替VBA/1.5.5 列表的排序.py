# sort 方法
ls = [4,2,1,3]
ls.sort()

a = [4,2,1,3,5,7,9,12]
a.sort(reverse=True)   # 降序排列

# sorted方法，  注意与上述不同，它不修改原有列表内容，会新建列表
a1 = [4,2,1,3]
a1 = sorted(a1)   # 默认升序
a2 = sorted(a1,reverse=True)   # 降序排列

print(ls)
print(a)
print(a1)
print(a2)
