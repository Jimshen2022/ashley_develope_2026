import os
import sys
from pathlib import Path
import pandas as pd
from datetime import datetime


def get_folder_size(folder_path):
    """递归计算文件夹大小"""
    total_size = 0
    try:
        for path, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(path, file)
                try:
                    total_size += os.path.getsize(file_path)
                except (OSError, FileNotFoundError):
                    continue
    except (PermissionError, FileNotFoundError):
        return 0
    return total_size


def is_system_folder(folder_path):
    """检查是否为系统文件夹"""
    system_folders = {
        'Windows', 'Program Files', 'Program Files (x86)',
        'ProgramData', 'System Volume Information',
        '$Recycle.Bin', 'Recovery'
    }
    return any(sys_folder in str(folder_path) for sys_folder in system_folders)


def analyze_drive(drive_letter):
    """分析指定驱动器的文件夹大小"""
    results = []
    drive_path = f"{drive_letter}:\\"

    print(f"\n正在分析 {drive_letter} 盘...")

    try:
        # 获取第一级目录
        folders = [f for f in Path(drive_path).glob("*") if f.is_dir()]

        for folder in folders:
            if not is_system_folder(folder):
                size = get_folder_size(folder)
                if size > 0:  # 只添加非空文件夹
                    results.append({
                        'folder_name': str(folder),
                        'size_bytes': size,
                        'size_gb': size / (1024 ** 3),  # 转换为GB
                        'last_modified': datetime.fromtimestamp(os.path.getmtime(folder))
                    })
                    print(f"已分析: {folder.name}")

    except Exception as e:
        print(f"分析 {drive_letter} 盘时出错: {str(e)}")

    return results


def main():
    # 分析C盘和D盘
    all_results = []
    for drive in ['C', 'D']:
        if os.path.exists(f"{drive}:\\"):
            results = analyze_drive(drive)
            all_results.extend(results)

    # 创建DataFrame并排序
    if all_results:
        df = pd.DataFrame(all_results)
        df = df.sort_values('size_bytes', ascending=False)

        # 保存结果到CSV
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = f'folder_analysis_{timestamp}.csv'
        df.to_csv(output_file, index=False, encoding='utf-8-sig')

        # 打印结果
        print("\n=== 分析结果 ===")
        print("\n前10个最大的文件夹:")
        pd.set_option('display.float_format', lambda x: '%.2f' % x)
        print(df[['folder_name', 'size_gb', 'last_modified']].head(10))
        print(f"\n完整结果已保存到: {output_file}")
    else:
        print("未找到任何符合条件的文件夹")


if __name__ == "__main__":
    main()