# 用{}创建字典
dt = {}
dt1 = {'grade': 5, 'class': 2, 'id': 's195201', 'name': 'LunXi'}

# 用dict函数创建字典
dt2 = dict(grade=5, clas=2, id='s195201', name='Liuxin')
dt3 = dict([('grade', 5), ('class', 2), ('id', 's195201'), ('name', 'LunXi')])  # 一维列表转字典
dt4 = dict((('grade', 5), ('class', 2), ('id', 's195201'), ('name', 'LunXi')))  # 元组转字典
dt5 = dict([['grade', 5], ['class', 2], ['id', 's195201'], ['name', 'LunXi']])  # 二维列表转字典
dt6 = dict((['grade', 5], ['class', 2], ['id', 's195201'], ['name', 'LunXi']))  # 元组转字典
dt7 = dict({('grade', 5), ('class', 2), ('id', 's195201'), ('name', 'LunXi')})  # 集合转字典

# 重点： 用zip函数将两个列表zip后转成字典
k = ['grade', 'clss', 'id', 'name']
v = [5, 2, 's195201', 'LinXi']
p = zip(k, v)
dt9 = list(zip(k, v))  # list将zip可以分解成列表内的成对元组！！！！！！！！！！！
dt8 = dict(p)
dt10 = id(dt2)
dt11 = id(dt3)

# 使用fromkeys 方法可以创建值为空的字典
dt12 = dict.fromkeys({'grade','clas','id','name'})
