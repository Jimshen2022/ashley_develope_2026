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
    intended_vessel_etd = None
    final_destination_eta = None

    for page_num in range(doc.page_count):
        page = doc[page_num]
        # 逐行解析文本
        lines = page.get_text("text").split("\n")
        
        # 遍历每一行文本
        for line in lines:
            # 查找 INTENDED VESSEL/VOYAGE: 和 ETD:
            if "INTENDED VESSEL/VOYAGE:" in line and "ETD:" in line:
                # 使用正则匹配 INTENDED VESSEL/VOYAGE 和 ETD 的值
                vessel_pattern = re.search(r"INTENDED VESSEL/VOYAGE:\s*(.+?)\s*ETD:", line)
                etd_pattern = re.search(r"ETD:\s*(.+)", line)
                if vessel_pattern and etd_pattern:
                    intended_vessel_etd = (vessel_pattern.group(1).strip(), etd_pattern.group(1).strip())
                    field_data.append(("INTENDED VESSEL/VOYAGE:", intended_vessel_etd[0]))
                    field_data.append(("ETD:", intended_vessel_etd[1]))
                    print(f"Found INTENDED VESSEL/VOYAGE and ETD: {intended_vessel_etd}")

            # 查找 FINAL DESTINATION: 和 ETA:
            if "FINAL DESTINATION:" in line and "ETA:" in line:
                # 使用正则匹配 FINAL DESTINATION 和 ETA 的值
                destination_pattern = re.search(r"FINAL DESTINATION:\s*(.+?)\s*ETA:", line)
                eta_pattern = re.search(r"ETA:\s*(.+)", line)
                if destination_pattern and eta_pattern:
                    final_destination_eta = (destination_pattern.group(1).strip(), eta_pattern.group(1).strip())
                    field_data.append(("FINAL DESTINATION:", final_destination_eta[0]))
                    field_data.append(("ETA:", final_destination_eta[1]))
                    print(f"Found FINAL DESTINATION and ETA: {final_destination_eta}")
    
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

    # 写入数据并打印每次写入的内容
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
