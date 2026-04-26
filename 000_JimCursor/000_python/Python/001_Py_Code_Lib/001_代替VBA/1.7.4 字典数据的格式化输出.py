student = {'name':'张三','sex':'男'}
print('姓名:{0},性别:{1}'.format(student['name'],student['sex']))
print('姓名:{name},性别:{sex}'.format(name=student['name'],sex=student['sex']))
print('姓名:{name},性别:{sex}'.format(**student))
print('{0[name]}:{0[sex]}'.format(student))   # 在括号内添加字典的索引形式,但是字典名称用0代替







