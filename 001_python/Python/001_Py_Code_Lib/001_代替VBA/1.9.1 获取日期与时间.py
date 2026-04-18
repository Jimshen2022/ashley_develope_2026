# 时间戳 指 从1970/1/1 0:00:00 到当前所经历的秒数
import time
t1 = time.time()     # 时间戳
t2 = time.localtime(time.time())  # 当前日期和时间
t3 = time.asctime(time.localtime(time.time()))    # asctime 函数获取格式化的日期和时间
t4 = time.localtime()  # 当前日期和时间
t5 = time.asctime(time.localtime())    # asctime 函数获取格式化的日期和时间
print(t1)
print(t2)
print(t3)
print(t4)