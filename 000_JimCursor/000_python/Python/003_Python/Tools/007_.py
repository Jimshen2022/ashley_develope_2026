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
    "INTENDED ESI CUT-OFF:",
    "Booking Number:",
    "Vessel/Voyage:",
    
]

def extract_field_data_from_pdf(pdf_path):
    doc = fitz.open(pdf_path)
    field_data = []
    current_field = None
    current_value = []
    next_field_found = False

    for page_num in range(doc.page_count):
        page = doc[page_num]
        lines = page.get_text("text").split("\n")
        
        # 遍历每一行文本
        for line in lines:
            # 如果当前没有在处理某个字段，尝试匹配字段名
            if current_field is None:
                for field in fields:
                    if field in line:
                        # 如果找到了字段，开始记录它的值
                        pattern = re.compile(re.escape(field) + r'\s*(.+)')
                        match = pattern.search(line)
                        if match:
                            current_field = field
                            current_value.append(match.group(1).strip())
                        break
            else:
                # 如果字段已经匹配上，继续读取该字段后可能跨越多行的内容
                next_field_found = False
                for field in fields:
                    if field in line and field != current_field:
                        next_field_found = True
                        break
                
                if next_field_found:
                    # 把当前字段及其值记录下来
                    field_data.append((current_field, " ".join(current_value)))
                    # 开始新字段的处理
                    current_field = None
                    current_value = []
                    break
                else:
                    # 如果还没有到下一个字段，继续收集当前字段的值（包括多行）
                    current_value.append(line.strip())
        
        # 如果当前处理的是某个字段，且到达页面末尾了，记录该字段的值
        if current_field is not None:
            field_data.append((current_field, " ".join(current_value)))
            current_field = None
            current_value = []

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
