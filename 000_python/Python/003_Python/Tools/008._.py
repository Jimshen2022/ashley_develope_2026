import fitz  # PyMuPDF
import os
import re
import openpyxl

# 定义要提取的字段名称
fields = [
    "BOOKING NUMBER:",
    "TOTAL BOOKING CONTAINER QTY SIZE/TYPE:",
    "INTENDED VESSEL/VOYAGE:",
    "ETD:",
    "FINAL DESTINATION:",
    "ETA:",
    "INTENDED VGM CUT-OFF:",
    "INTENDED FCL CY CUT-OFF:",
    "INTENDED ESI CUT-OFF:"
]

def extract_field_data_from_pdf(pdf_path):
    doc = fitz.open(pdf_path)
    field_data = []
    current_field = None
    current_value = []
    collecting = False  # 用于标记是否继续收集字段的值

    for page_num in range(doc.page_count):
        page = doc[page_num]
        lines = page.get_text("text").split("\n")
        
        # 遍历每一行文本
        for line in lines:
            line = line.strip()
            
            if collecting:
                # 如果正在收集字段的值，检查是否到了下一个字段或行结束
                if any(field in line for field in fields) and current_field is not None:
                    field_data.append((current_field, " ".join(current_value).strip()))
                    current_field = None
                    current_value = []
                    collecting = False  # 停止收集当前字段
                else:
                    # 如果没有遇到下一个字段，继续收集当前字段的多行值
                    current_value.append(line)
            
            if not collecting:
                # 检查这一行是否包含我们需要的字段
                for field in fields:
                    if field in line:
                        # 找到字段，开始记录字段值
                        pattern = re.compile(re.escape(field) + r'\s*(.+)')
                        match = pattern.search(line)
                        if match:
                            current_field = field
                            current_value.append(match.group(1).strip())
                            collecting = True  # 开始收集字段后跨行的值
                        break
    
    # 如果还有正在收集的字段，最后将其记录下来
    if current_field is not None:
        field_data.append((current_field, " ".join(current_value).strip()))
    
    doc.close()
    return field_data

def write_to_excel(data, output_excel_path, pdf_filename):
    if not os.path.exists(output_excel_path):
        workbook = openpyxl.Workbook()
        sheet = workbook.active
        sheet.append(["Field", "Value", "PDF Filename"])  # 添加表头
    else:
        workbook = openpyxl.load_workbook(output_excel_path)
        sheet = workbook.active

    for field, value in data:
        sheet.append([field, value, pdf_filename])

    workbook.save(output_excel_path)
    print(f"Excel saved to {output_excel_path}")

# 主函数
def process_pdfs_in_folder(folder_path, output_excel_path):
    for filename in os.listdir(folder_path):
        if filename.endswith(".pdf"):
            print(f"Processing file: {filename}")
            pdf_path = os.path.join(folder_path, filename)
            field_data = extract_field_data_from_pdf(pdf_path)
            write_to_excel(field_data, output_excel_path, filename)

# 运行代码
folder_path = '/Python2038/016_Python/Tools/pdf'  # 替换为你的 PDF 文件夹路径
output_excel_path = '/Python2038/016_Python/Tools/output.xlsx'  # 输出的 Excel 文件
process_pdfs_in_folder(folder_path, output_excel_path)
