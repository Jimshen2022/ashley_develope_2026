import pandas as pd
from pathlib import Path
from datetime import datetime
import re
from decimal import Decimal

# 单文件最大 80KB
MAX_FILE_SIZE = 20 * 1024  # 80 KB

def clean_sn(raw) -> str | None:
    """
    把从 Excel 读出来的值，统一清洗成 “纯数字字符串”，去掉 .0、科学计数法等。
    """
    if raw is None:
        return None

    s = str(raw).strip()
    if not s:
        return None

    # 明确是 xxxx.0 这种
    if re.fullmatch(r"\d+\.0", s):
        return s[:-2]

    # 科学计数法：1.234E+11 / 1.234e+11
    if re.fullmatch(r"[0-9.]+e[+-]?[0-9]+", s, re.IGNORECASE):
        try:
            return str(int(Decimal(s)))
        except Exception:
            pass

    # 一般的小数，也尝试转成整数（比如 555637717861.0）
    if re.fullmatch(r"\d+\.\d+", s):
        try:
            return str(int(Decimal(s)))
        except Exception:
            pass

    # 纯数字直接返回
    if re.fullmatch(r"\d+", s):
        return s

    # 其他情况（如果你以后有字母混合的 SN），先原样返回
    return s

def read_serials_from_excel(excel_path: Path, sheet_name: str = "SN"):
    """
    从 .xlsb 的 SN sheet 读取 A 列流水号，并做清洗：
    - 去掉空值
    - 去掉 .0 / 科学计数法
    """
    df = pd.read_excel(
        excel_path,
        sheet_name=sheet_name,
        engine="pyxlsb",
        dtype=str,     # 尽量全部按字符串读
        usecols="A"
    )
    col = df.iloc[:, 0]

    serials: list[str] = []
    for v in col:
        sn = clean_sn(v)
        if sn:  # 非空才要
            serials.append(sn)

    return serials

def build_mac_header() -> str:
    # 和你给的文件完全一样
    return "Description =\r\n[wait app]\r\n[wait inp inh]\r\n\r\n"

def build_mac_block(sn: str) -> str:
    # 每个流水号一个 block，block 末尾带一个空行
    return (
        "wait 600 msec \r\n"
        f"\"{sn}\r\n"
        "[enter]\r\n"
        "[wait inp inh]\r\n"
        "\r\n"
    )

def finalize_content(content: str) -> str:
    """
    去掉最后多余的一行空行：
    把末尾的 '\r\n\r\n' 变成 '\r\n'，
    使最后一行就是 '[wait inp inh]' + 换行，和你 VBA 生成的一样。
    """
    if content.endswith("\r\n\r\n"):
        return content[:-2]  # 去掉最后一个 '\n'
    return content

def split_to_mac_files(serials, encoding="mbcs"):
    """
    把所有流水号拆成多个 < 80KB 的 MAC 文件文本内容。
    返回：每个元素是一整个 MAC 文件的文本。
    """
    files_contents: list[str] = []
    header = build_mac_header()
    header_size = len(header.encode(encoding))

    current_text = header
    current_size = header_size
    current_cnt = 0

    for sn in serials:
        block = build_mac_block(sn)
        block_size = len(block.encode(encoding))

        # 如果加上这个 block 超过 80KB，且当前文件已经有内容，就先封一个文件
        if current_size + block_size > MAX_FILE_SIZE and current_cnt > 0:
            files_contents.append(finalize_content(current_text))
            current_text = header
            current_size = header_size
            current_cnt = 0

        current_text += block
        current_size += block_size
        current_cnt += 1

    # 最后一个文件
    if current_cnt > 0:
        files_contents.append(finalize_content(current_text))

    return files_contents

def main():
    # 1. Excel 路径：Downloads 下的 .xlsb
    downloads_folder = Path.home() / "Downloads"
    excel_path = downloads_folder / "MIL SN MOVE MACRO IN AS400_version01.xlsb"
    if not excel_path.exists():
        raise FileNotFoundError(f"找不到 Excel 文件：{excel_path}")

    # 2. 读取 SN 列
    serials = read_serials_from_excel(excel_path, sheet_name="SN")
    if not serials:
        raise ValueError("SN 工作表 A 列没有读到任何流水号。")

    # 3. 拆成多个 <80KB 的 .mac 文本
    encoding = "mbcs"   # 在你的 Windows 上就是本地 ANSI，跟 VBA 最接近
    mac_files_contents = split_to_mac_files(serials, encoding=encoding)

    # 4. 输出目录
    output_dir = Path(r"D:\Documents\23-HOLD")
    output_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # 5. 写出文件
    for idx, content in enumerate(mac_files_contents, start=1):
        file_name = f"MIL_MOVE_{timestamp}-{idx:02d}.mac"
        output_file = output_dir / file_name

        with output_file.open("w", encoding=encoding, newline="\r\n") as f:
            f.write(content)

        print(f"生成：{output_file}  ({len(content.encode(encoding))} bytes)")

    print(f"\n共生成 {len(mac_files_contents)} 个 MAC 文件，总流水号：{len(serials)}")

if __name__ == "__main__":
    main()
