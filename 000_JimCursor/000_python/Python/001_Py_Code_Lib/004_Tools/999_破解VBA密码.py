# 将你的 .xlsm 文件路径填入脚本中 file_path 变量。
# 运行脚本后，生成一个新的文件，命名为 yourfilename_nopw.xlsm
# 打开该文件，VBA 项目密码已被绕过，你可以直接查看代码！


import zipfile
import shutil
import os
import olefile

def process_xls(file_path):
    print(f"🛠 正在处理 .xls 文件：{file_path}")
    with open(file_path, 'rb') as f:
        data = f.read()

    if b'DPB=' not in data:
        print("⚠️ 没有发现 VBA 密码标记（DPB=），可能未设置密码。")
        return

    new_data = data.replace(b'DPB=', b'DPx=')

    backup = file_path + ".bak"
    shutil.copy2(file_path, backup)
    with open(file_path, 'wb') as f:
        f.write(new_data)

    print(f"✅ 修改成功，原始文件已备份为：{backup}")


def process_xlsm_xlsb(file_path):
    print(f"🛠 正在处理基于 ZIP 的文件：{file_path}")
    base_dir = os.path.dirname(file_path)
    filename = os.path.basename(file_path)
    name_only, ext = os.path.splitext(filename)
    temp_dir = os.path.join(base_dir, f"{name_only}_unzip")
    output_file = os.path.join(base_dir, f"{name_only}_nopw{ext}")

    # 解压缩
    with zipfile.ZipFile(file_path, 'r') as zip_ref:
        zip_ref.extractall(temp_dir)

    vba_path = os.path.join(temp_dir, 'xl', 'vbaProject.bin')
    if not os.path.exists(vba_path):
        print("❌ 未找到 vbaProject.bin，无法修改 VBA 密码。")
        shutil.rmtree(temp_dir)
        return

    # 修改 DPB= 标记
    with open(vba_path, 'rb') as f:
        data = f.read()

    if b'DPB=' not in data:
        print("⚠️ 未发现密码标志（DPB=），可能未加密。")
    else:
        data = data.replace(b'DPB=', b'DPx=')
        with open(vba_path, 'wb') as f:
            f.write(data)
        print("✅ 成功修改 vbaProject.bin")

    # 重新打包
    def zipdir(path, ziph):
        for root, dirs, files in os.walk(path):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, path)
                ziph.write(full_path, rel_path)

    with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipdir(temp_dir, zipf)

    shutil.rmtree(temp_dir)
    print(f"🎉 解锁后的文件已生成：{output_file}")


def remove_vba_password(file_path):
    ext = os.path.splitext(file_path)[1].lower()

    if ext == ".xls":
        process_xls(file_path)
    elif ext in [".xlsm", ".xlsb"]:
        process_xlsm_xlsb(file_path)
    else:
        print("❌ 不支持的文件类型，请使用 .xls, .xlsm 或 .xlsb 文件")


# === 示例调用 ===
if __name__ == "__main__":
    # 修改为你的文件路径
    file_path = r"C:\Users\jishen\Downloads\RP 1020 vs AS400 report_20250714 0730.xlsb"
    remove_vba_password(file_path)
