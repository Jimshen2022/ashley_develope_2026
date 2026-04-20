import fitz  # PyMuPDF
import os
import re
import openpyxl

def extract_highlighted_data_from_pdf(pdf_path):
    # 打开 PDF 文件
    doc = fitz.open(pdf_path)
    highlighted_data = []

    for page_num in range(doc.page_count):
        page = doc[page_num]
        text = page.get_text("text")  # 提取文本
        for annot in page.annots():  # 检查页面的注释和标注
            if annot.type[0] == 8:  # 检查是否为高亮标注
                highlight = annot.rect
                highlighted_text = page.get_textbox(highlight)  # 提取高亮文本
                surrounding_text = extract_surrounding_text(text, highlighted_text)  # 提取前面的描述
                highlighted_data.append((surrounding_text, highlighted_text))
    
    doc.close()
    return highlighted_data

def extract_surrounding_text(full_text, highlighted_text):
    # 使用正则表达式查找高亮文本前面的内容
    pattern = re.compile(r'(.+?)' + re.escape(highlighted_text))
    match = pattern.search(full_text)
    if match:
        return match.group(1).strip()
    return ""

def write_to_excel(data, output_excel_path, pdf_filename):
    # 如果 Excel 文件不存在则创建
    if not os.path.exists(output_excel_path):
        workbook = openpyxl.Workbook()
        sheet = workbook.active
        sheet.append(["Field", "Value", "PDF Filename"])  # 添加表头
    else:
        workbook = openpyxl.load_workbook(output_excel_path)
        sheet = workbook.active

    # 写入数据
    for field, value in data:
        sheet.append([field, value, pdf_filename])

    # 保存 Excel 文件
    workbook.save(output_excel_path)

# 主函数
def process_pdfs_in_folder(folder_path, output_excel_path):
    for filename in os.listdir(folder_path):
        if filename.endswith(".pdf"):
            pdf_path = os.path.join(folder_path, filename)
            highlighted_data = extract_highlighted_data_from_pdf(pdf_path)
            write_to_excel(highlighted_data, output_excel_path, filename)

# 运行代码
folder_path = "/path/to/your/pdf/folder"  # 替换为你的 PDF 文件夹路径
output_excel_path = "output.xlsx"  # 输出的 Excel 文件
process_pdfs_in_folder(folder_path, output_excel_path)
