import pandas as pd
import re
import os
from pathlib import Path
import argparse
import logging
from typing import List, Dict, Optional

# 设置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class PDFDataExtractor:
    def __init__(self):
        self.supported_formats = ['.pdf', '.txt']

    def read_pdf_content(self, file_path: str) -> Optional[str]:
        """
        读取PDF或文本文件内容
        """
        file_path = Path(file_path)

        if file_path.suffix.lower() == '.pdf':
            try:
                import pdfplumber
                with pdfplumber.open(file_path) as pdf:
                    content = ''
                    for page in pdf.pages:
                        page_text = page.extract_text()
                        if page_text:
                            content += page_text + '\n'
                    return content
            except ImportError:
                logger.error("需要安装pdfplumber库来处理PDF文件: pip install pdfplumber")
                return None
            except Exception as e:
                logger.error(f"读取PDF文件 {file_path} 时出错: {e}")
                return None

        elif file_path.suffix.lower() == '.txt':
            try:
                with open(file_path, 'r', encoding='utf-8') as file:
                    return file.read()
            except Exception as e:
                logger.error(f"读取文本文件 {file_path} 时出错: {e}")
                return None

        else:
            logger.warning(f"不支持的文件格式: {file_path.suffix}")
            return None

    def extract_basic_info(self, content: str) -> Dict[str, str]:
        """
        提取基本信息（PO#, 供应商等）
        """
        info = {
            'po_number': '',
            'supplier_code': '',
            'supplier_name': '',
            'container_number': '',
            'bill_of_lading': '',
            'carrier': ''
        }

        # 提取PO号
        po_patterns = [
            r'PO\s*#\s*:\s*(\S+)',
            r'PO\s*:\s*(\S+)',
            r'PO\s+(\S+)'
        ]
        for pattern in po_patterns:
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                info['po_number'] = match.group(1)
                break

        # 提取供应商代号
        vendor_patterns = [
            r'Vendor\s*:\s*(\d+)',
            r'供应商\s*:\s*(\d+)',
            r'Supplier\s*:\s*(\d+)'
        ]
        for pattern in vendor_patterns:
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                info['supplier_code'] = match.group(1)
                break

        # 提取供应商名称
        vessel_patterns = [
            r'Vessel Report\s*-\s*(.+?)Voyage',
            r'船舶报告\s*-\s*(.+?)航次',
            r'Vessel\s*:\s*(.+?)(?:\n|$)'
        ]
        for pattern in vessel_patterns:
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                info['supplier_name'] = match.group(1).strip()
                break

        # 提取集装箱号
        container_patterns = [
            r'(\w{4}\d{7})',  # 标准集装箱号格式
            r'Container\s*:\s*(\S+)'
        ]
        for pattern in container_patterns:
            match = re.search(pattern, content)
            if match:
                info['container_number'] = match.group(1)
                break

        # 提取提单号
        bl_patterns = [
            r'Bill of Lading\s*:\s*(\S+)',
            r'B/L\s*:\s*(\S+)',
            r'提单\s*:\s*(\S+)'
        ]
        for pattern in bl_patterns:
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                info['bill_of_lading'] = match.group(1)
                break

        # 提取承运人
        carrier_patterns = [
            r'Carrier\s*:\s*(.+?)(?:\n|Vendor)',
            r'承运人\s*:\s*(.+?)(?:\n|$)'
        ]
        for pattern in carrier_patterns:
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                info['carrier'] = match.group(1).strip()
                break

        return info

    def extract_items_data(self, content: str, basic_info: Dict[str, str]) -> List[Dict[str, str]]:
        """
        提取物品数据
        """
        items_data = []
        current_item_code = ''

        # 预处理内容，清理多余的空格和换行
        lines = [line.strip() for line in content.split('\n') if line.strip()]

        i = 0
        while i < len(lines):
            line = lines[i]

            # 跳过标题行和无关行
            if any(keyword in line.upper() for keyword in [
                'ITEM #', 'ITEM DESCRIPTION', 'QTY', 'PAGE', 'CONTAINER VERIFICATION',
                'VESSEL REPORT', 'VOYAGE', 'RECEIVED CONTAINER'
            ]):
                i += 1
                continue

            # 检查是否包含序列号信息
            if 'start' in line.lower() and 'finish' in line.lower():
                # 可能需要向前查找几行来获取完整的物品信息
                item_info_lines = []

                # 向前查找相关行
                for j in range(max(0, i - 3), i + 1):
                    if j < len(lines):
                        item_info_lines.append(lines[j])

                # 合并所有相关行
                full_text = ' '.join(item_info_lines)

                # 解析数据
                item_data = self.parse_item_line(full_text, current_item_code, basic_info)

                if item_data:
                    # 更新当前物品代码
                    if item_data[0]['Item #']:
                        current_item_code = item_data[0]['Item #']

                    items_data.extend(item_data)

            i += 1

        return items_data

    def parse_item_line(self, text: str, current_item_code: str, basic_info: Dict[str, str]) -> List[Dict[str, str]]:
        """
        解析单行物品数据
        """
        # 查找物品代码
        item_code_match = re.search(r'\b([A-Z]\d{6,})\b', text)
        item_code = item_code_match.group(1) if item_code_match else current_item_code

        # 提取序列号范围
        start_match = re.search(r'start\s+(\d+)', text, re.IGNORECASE)
        finish_match = re.search(r'finish\s+(\d+)', text, re.IGNORECASE)

        if not (start_match and finish_match):
            return []

        start_serial = int(start_match.group(1))
        finish_serial = int(finish_match.group(1))

        # 提取数量
        numbers = re.findall(r'\b(\d+)\b', text)
        qty = 0

        # 尝试找到合理的数量值（通常是序列号数量或接近的数字）
        expected_count = finish_serial - start_serial + 1
        for num_str in numbers:
            num = int(num_str)
            if num == expected_count or (1 <= num <= 1000 and num != start_serial and num != finish_serial):
                qty = num
                break

        if qty == 0:
            qty = expected_count

        # 提取描述
        description = self.extract_description(text, item_code, qty, start_serial, finish_serial)

        # 生成每个序列号的记录
        items = []
        for serial_num in range(start_serial, finish_serial + 1):
            items.append({
                '供应商代号': basic_info['supplier_code'],
                '供应商名称': basic_info['supplier_name'],
                'PO#': basic_info['po_number'],
                '集装箱号': basic_info['container_number'],
                '提单号': basic_info['bill_of_lading'],
                '承运人': basic_info['carrier'],
                'Item #': item_code,
                'Item Description': description,
                'Qty': qty,
                'Serial Number': str(serial_num)
            })

        return items

    def extract_description(self, text: str, item_code: str, qty: int, start_serial: int, finish_serial: int) -> str:
        """
        提取物品描述
        """
        # 移除物品代码、数量和序列号信息
        description_text = text

        # 移除已知的非描述性内容
        remove_patterns = [
            r'\b' + re.escape(item_code) + r'\b',
            r'\b' + str(qty) + r'\b',
            r'\b' + str(start_serial) + r'\b',
            r'\b' + str(finish_serial) + r'\b',
            r'start\s+\d+',
            r'finish\s+\d+',
            r'start',
            r'finish'
        ]

        for pattern in remove_patterns:
            description_text = re.sub(pattern, '', description_text, flags=re.IGNORECASE)

        # 清理多余的空格
        description_text = ' '.join(description_text.split())

        # 如果描述太短，尝试从常见的物品类型中推断
        if len(description_text) < 3:
            if item_code.startswith('A'):
                description_text = 'ACCESSORY'
            elif item_code.startswith('L'):
                description_text = 'LIGHTING'
            else:
                description_text = 'ITEM'

        return description_text.strip()

    def process_single_file(self, file_path: str) -> List[Dict[str, str]]:
        """
        处理单个文件
        """
        logger.info(f"处理文件: {file_path}")

        # 读取文件内容
        content = self.read_pdf_content(file_path)
        if not content:
            return []

        # 提取基本信息
        basic_info = self.extract_basic_info(content)

        # 提取物品数据
        items_data = self.extract_items_data(content, basic_info)

        logger.info(f"从 {file_path} 提取了 {len(items_data)} 条记录")
        return items_data

    def process_batch(self, input_path: str, output_file: str = None) -> None:
        """
        批量处理文件
        """
        input_path = Path(input_path)
        all_data = []

        if input_path.is_file():
            # 处理单个文件
            data = self.process_single_file(str(input_path))
            all_data.extend(data)

        elif input_path.is_dir():
            # 处理目录中的所有支持格式文件
            for ext in self.supported_formats:
                files = list(input_path.glob(f"*{ext}"))
                for file_path in files:
                    data = self.process_single_file(str(file_path))
                    all_data.extend(data)

        else:
            logger.error(f"路径不存在: {input_path}")
            return

        # 保存结果
        if all_data:
            if output_file is None:
                output_file = input_path.parent / "extracted_data.xlsx" if input_path.is_file() else input_path / "extracted_data.xlsx"

            self.save_to_excel(all_data, output_file)
        else:
            logger.warning("没有提取到任何数据")

    def save_to_excel(self, data: List[Dict[str, str]], output_file: str) -> None:
        """
        保存数据到Excel文件
        """
        if not data:
            logger.warning("没有数据需要保存")
            return

        df = pd.DataFrame(data)

        # 创建输出目录
        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # 保存到Excel，每个PO作为单独的工作表
        po_groups = df.groupby('PO#')

        with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
            # 汇总工作表
            df.to_excel(writer, sheet_name='全部数据', index=False)

            # 按PO分组的工作表
            for po, group_df in po_groups:
                sheet_name = f"PO_{po}" if po else "未知PO"
                # Excel工作表名称限制
                sheet_name = sheet_name[:31]
                group_df.to_excel(writer, sheet_name=sheet_name, index=False)

        logger.info(f"数据已保存到: {output_file}")
        logger.info(f"总共处理了 {len(data)} 条记录")
        logger.info(f"涉及 {len(po_groups)} 个PO")


def main():
    parser = argparse.ArgumentParser(description='批量提取PDF文件中的物品数据')
    parser.add_argument('input_path', help='输入文件或目录路径')
    parser.add_argument('-o', '--output', help='输出Excel文件路径')
    parser.add_argument('-v', '--verbose', action='store_true', help='详细输出')

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    extractor = PDFDataExtractor()
    extractor.process_batch(args.input_path, args.output)


if __name__ == "__main__":
    # 如果直接运行脚本，处理当前目录下的所有PDF文件
    if len(os.sys.argv) == 1:
        print("使用方法:")
        print("1. 处理单个文件: python script.py file.pdf")
        print("2. 处理整个目录: python script.py /path/to/pdf/directory")
        print("3. 指定输出文件: python script.py input_path -o output.xlsx")
        print("4. 详细模式: python script.py input_path -v")
        print()
        print("正在处理当前目录下的PDF文件...")

        extractor = PDFDataExtractor()
        extractor.process_batch(".", "extracted_data.xlsx")
    else:
        main()