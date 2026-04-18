import fitz  # PyMuPDF
import os
import re
import openpyxl


"""
文字提取：PyMuPDF 或 pdfplumber
表格提取：camelot 或 pdfplumber
图片提取：PyMuPDF 或 pdf2image
如果需要一个包处理多个功能，推荐 pdfplumber。它功能全面且易用！
"""
# 定义要提取的字段名称
fields = [
    "BOOKING NUMBER:",
    "QTY SIZE/TYPE:",
    "INTENDED VESSEL/VOYAGE:",
    "ETD:",
    "PORT OF DISCHARGE:",
    "FINAL DESTINATION:",
    "ETA:",
    "INTENDED VGM CUT-OFF:",
    "INTENDED FCL CY CUT-OFF:",
    "INTENDED ESI CUT-OFF:"
]

def extract_field_data_from_pdf(pdf_path):
    # Open the PDF file
    doc = fitz.open(pdf_path)
    field_data = []
    # Iterate through each page of the PDF
    for page_num in range(doc.page_count):
        page = doc[page_num]
        text = page.get_text("text")  # Get the text from the page
        # Iterate through the fields to extract
        for field in fields:
            # Use a regex pattern to find the field and its following content, allowing for newlines
            pattern = re.compile(re.escape(field) + r'\s*(.+?)(?=\n\S|$)', re.DOTALL)
            match = pattern.search(text)
            if match:
                value = match.group(1).strip()  # Extract the content after the field
                field_data.append((field, value))
    doc.close()
    return field_data
def extract_field_data_from_pdf(pdf_path):
    # Open the PDF file
    doc = fitz.open(pdf_path)
    field_data = []
    # Iterate through each page of the PDF
    for page_num in range(doc.page_count):
        page = doc[page_num]
        text = page.get_text("text")  # Get the text from the page
        # Iterate through the fields to extract
        for field in fields:
            # Use a regex pattern to find the field and its following content, allowing for newlines
            pattern = re.compile(re.escape(field) + r'\s*(.+?)(?=\n\S|$)', re.DOTALL)
            match = pattern.search(text)
            if match:
                value = match.group(1).strip()  # Extract the content after the field
                field_data.append((field, value))
    doc.close()
    return field_data

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
    # 删除已有的 Excel 文件（如果存在）
    if os.path.exists(output_excel_path):
        os.remove(output_excel_path)

    for filename in os.listdir(folder_path):
        if filename.endswith(".pdf"):
            pdf_path = os.path.join(folder_path, filename)
            field_data = extract_field_data_from_pdf(pdf_path)
            write_to_excel(field_data, output_excel_path, filename)

# 运行代码
folder_path = '/Python2038/016_Python/Tools/pdf'  # 替换为你的 PDF 文件夹路径
output_excel_path = '/Python2038/016_Python/Tools/output.xlsx'  # 输出的 Excel 文件
process_pdfs_in_folder(folder_path, output_excel_path)