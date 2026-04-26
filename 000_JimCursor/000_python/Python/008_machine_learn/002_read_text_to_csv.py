import easyocr
import cv2
import matplotlib.pyplot as plt
import pandas as pd
import os
import time
from datetime import datetime

# 图像路径
image_path = r'C:\Users\jishen\Pictures\69259.png'

# 原始图像
image = cv2.imread(image_path)

# 灰度 + 自适应二值化（更稳）
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
thresh = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                               cv2.THRESH_BINARY, 11, 2)

# 保存临时图像供 EasyOCR 使用
temp_path = os.path.join(os.path.dirname(image_path), 'temp_cleaned.png')
cv2.imwrite(temp_path, thresh)

# 初始化 OCR 识别器
reader = easyocr.Reader(['en'])

# 不使用 allowlist，启用段落识别
# results = reader.readtext(temp_path, paragraph=True)
results = reader.readtext(temp_path)

# 可视化标记
for (bbox, text, prob) in results:
    (top_left, top_right, bottom_right, bottom_left) = bbox
    top_left = tuple(map(int, top_left))
    bottom_right = tuple(map(int, bottom_right))
    cv2.rectangle(image, top_left, bottom_right, (0, 255, 0), 2)
    cv2.putText(image, text, (top_left[0], top_left[1] - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 0, 0), 2)

# 显示图像
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
plt.figure(figsize=(12, 8))
plt.imshow(image_rgb)
plt.axis('off')
plt.title("OCR Result")
plt.show()

# 结果导出
data = []
for (bbox, text, prob) in results:
    data.append({
        'text': text.strip(),
        'confidence': round(prob, 4),
        'top_left': bbox[0],
        'top_right': bbox[1],
        'bottom_right': bbox[2],
        'bottom_left': bbox[3]
    })

df = pd.DataFrame(data)

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
file_name = f'ocr_results_{current_time}.csv'
downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads')
file_path = os.path.join(downloads_path, file_name)
df.to_csv(file_path, index=False, encoding='utf-8-sig')

print(f"OCR 结果已保存到：{file_path}")
