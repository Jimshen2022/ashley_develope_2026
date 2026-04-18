import easyocr
import cv2
import matplotlib.pyplot as plt

# 初始化 OCR 读取器，支持英文和数字
reader = easyocr.Reader(['en'])

# 读取图像（路径替换为你的图像路径）
image_path = r'C:\Users\jishen\Pictures\69259.png'
image = cv2.imread(image_path)

# EasyOCR 会自动处理图像
results = reader.readtext(image_path)

# 可视化：画框显示结果
for (bbox, text, prob) in results:
    (top_left, top_right, bottom_right, bottom_left) = bbox
    top_left = tuple(map(int, top_left))
    bottom_right = tuple(map(int, bottom_right))
    cv2.rectangle(image, top_left, bottom_right, (0, 255, 0), 2)
    cv2.putText(image, text, (top_left[0], top_left[1] - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 0, 0), 2)

# 转换为 RGB 显示
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

plt.figure(figsize=(12, 8))
plt.imshow(image_rgb)
plt.axis('off')
plt.title("OCR Result")
plt.show()
