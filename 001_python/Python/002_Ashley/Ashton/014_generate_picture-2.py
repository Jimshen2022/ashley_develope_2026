from PIL import Image, ImageDraw, ImageFont

# 创建自定义背景图片（RGB(55, 126, 184)）
image = Image.new("RGB", (800, 400), (55, 126, 184))  # 修改此处背景色
draw = ImageDraw.Draw(image)

# 加载字体（确保字体路径正确）
try:
    font = ImageFont.truetype("arial.ttf", 36)  # 可替换为系统支持的其他字体路径
except:
    font = ImageFont.load_default()

title_text = "Ashton Receiving & Loading\nPlanned vs Actual by Hour"

# 使用 textbbox 计算文本尺寸
bbox = draw.textbbox((0, 0), title_text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

# 居中计算文本位置
x = (800 - text_width) / 2
y = (400 - text_height) / 2

# 添加白色文字
draw.multiline_text((x, y), title_text, fill=(255, 255, 255), font=font, align="center")

# 保存图片
image.save("ashton_title_image.png")
print("图片已生成！")


