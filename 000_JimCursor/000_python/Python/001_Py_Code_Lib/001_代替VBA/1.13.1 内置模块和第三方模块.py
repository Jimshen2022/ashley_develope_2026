# Student类
class student:
    ID='No001'    # ID属性

    def __init__(self,id2):   # 构造函数
        self.ID=id2

    def run(self):    # run方法
        print('跑起来')
        return
st = student('No001')    # 用构造函数创建类实例
print(st.ID)
st.run()
