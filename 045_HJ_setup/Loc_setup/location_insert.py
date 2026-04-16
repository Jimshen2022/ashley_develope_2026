import pyautogui
import time
import cv2

# 配置参数
CONFIDENCE_LEVEL = 0.8  # 图像识别精准度 (0-1)
RETRY_INTERVAL = 1  # 找不到按钮时的重试间隔（秒）


def click_image(image_path, timeout=30):
    """
    在屏幕上寻找图片并点击。如果在 timeout 时间内没找到，则报错。
    """
    start_time = time.time()
    while True:
        try:
            # 寻找目标图片中心位置
            location = pyautogui.locateCenterOnScreen(image_path, confidence=CONFIDENCE_LEVEL)
            if location:
                pyautogui.click(location)
                print(f"成功点击: {image_path}")
                return True
        except Exception:
            pass

        if time.time() - start_time > timeout:
            print(f"超时：未能在屏幕上找到 {image_path}")
            return False

        time.sleep(RETRY_INTERVAL)


def main():
    # 让用户输入循环次数
    try:
        loop_count = int(input("请输入需要循环执行的次数: "))
    except ValueError:
        print("错误：请输入有效的数字！")
        return

    print("程序将在 5 秒后开始，请立即切换到 HighJump 浏览器窗口...")
    time.sleep(5)

    # 开启故障保险：鼠标移动到屏幕四个角任何一个即可强制停止脚本
    pyautogui.FAILSAFE = True

    for i in range(loop_count):
        print(f"\n--- 正在执行第 {i + 1} / {loop_count} 次循环 ---")

        # 1. 点击 Query 按钮
        if not click_image('query_btn.png'):
            print("未能找到 Query 按钮，停止运行。")
            break

        # 2. 等待并点击后退箭头 (系统处理可能需要时间)
        print("等待系统处理中...")
        if not click_image('back_btn.png', timeout=60):  # 结果页可能加载较慢，超时设长一点
            print("未能找到后退箭头，停止运行。")
            break

        # 3. 稍微等待回到主页面加载完成
        time.sleep(2)

    print("\n任务已全部完成！")


if __name__ == "__main__":
    main()