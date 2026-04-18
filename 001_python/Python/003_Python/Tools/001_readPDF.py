import os
import fitz  # PyMuPDF

# 获取当前 Python 文件的目录
# current_dir = '/path/to/your/pdf/file.pdf'
current_dir = os.path.dirname(__file__)

# 拼接你的文件夹路径
folder_path = os.path.join(current_dir, 'pdf')

# 遍历文件夹中的所有 PDF 文件
for filename in os.listdir(folder_path):
    if filename.endswith('.pdf'):
        pdf_path = os.path.join(folder_path, filename)
        
        # 打开 PDF 文件
        pdf_document = fitz.open(pdf_path)
        
        # 提取文本
        text = ""
        for page_num in range(len(pdf_document)):
            page = pdf_document.load_page(page_num)
            text += page.get_text()
        
        # 打印或保存提取的文本
        print(f"内容来自文件: {filename}")
        print(text)
        
        # 关闭 PDF 文件
        pdf_document.close()
