import pyautogui
import random
import time

# 定义屏幕边界
screenWidth, screenHeight = pyautogui.size()

# 定义随机移动鼠标的函数
def move_mouse_randomly():
    x = random.randint(0, screenWidth - 1)
    y = random.randint(0, screenHeight - 1)
    duration = random.uniform(0.1, 2.0)  # 移动时间在0.5到2秒之间
    pyautogui.moveTo(x, y, duration=duration)
    print(f"Mouse moved to ({x}, {y})")

# 主循环
try:
    while True:
        move_mouse_randomly()
        sleep_time = random.uniform(10, 30)  # 随机等待时间在10到60秒之间
        time.sleep(sleep_time)
        # 这里最好加一个点击到软件空白页的事件，比如点击到跟自己的聊天框
        # 下面的坐标请根据实际情况填写
        pyautogui.click(1400, 500)
except KeyboardInterrupt:
    print("已经被用户停止.")