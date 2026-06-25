import pandas as pd
import os

def analyze_xlsb_first_principles(file_path):
    """
    基于第一性原理对 xlsb 数据文件进行深度解构和分析：
    1. 物理层：解析文件结构（包含哪些 Sheet，每个 Sheet 的大小）
    2. 数据层：解析每个表的数据结构（列名、数据类型、缺失值情况）
    3. 逻辑层：抽取核心特征和统计分布
    4. 存储层：将所有非空工作表持久化为纯文本 CSV 格式，打破平台壁垒
    """
    print(f"========== 开启第一性原理深度解析 ==========")
    print(f"目标文件: {file_path}")
    
    if not os.path.exists(file_path):
        print(f"错误: 找不到文件 {file_path}")
        return

    # 初始化导出目录
    base_dir = os.path.dirname(file_path)
    file_name = os.path.splitext(os.path.basename(file_path))[0]
    output_dir = os.path.join(base_dir, f"{file_name}_extracts")
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"创建数据持久化目录: {output_dir}")

    try:
        # 注意: 读取 xlsb 需要安装 pyxlsb 库 (pip install pyxlsb)
        print("\n[1/4] 正在加载二进制工作簿引擎...")
        xls = pd.ExcelFile(file_path, engine='pyxlsb')
    except Exception as e:
        print(f"加载文件失败，请确保已安装 pyxlsb (pip install pyxlsb)。错误信息: {e}")
        return

    sheet_names = xls.sheet_names
    print(f"\n[2/4] 物理层解构完成，共发现 {len(sheet_names)} 个工作表:")
    
    for idx, sheet_name in enumerate(sheet_names):
        print(f"\n--- 正在深度扫描 Sheet ({idx+1}/{len(sheet_names)}): {sheet_name} ---")
        try:
            df = pd.read_excel(xls, sheet_name=sheet_name)
        except Exception as e:
            print(f"读取工作表 {sheet_name} 失败: {e}")
            continue
            
        # 1. 基础维度
        rows, cols = df.shape
        print(f"▶ 基础维度: {rows} 行 × {cols} 列")
        
        if rows == 0:
            print("▶ 状态: 空表，跳过深度特征提取和导出。")
            continue
            
        # 2. 列属性解构 (包含数据类型和缺失率)
        print(f"▶ 字段解构与质量评估 (前 15 列展示):")
        col_info = []
        for col in df.columns[:15]:
            dtype = df[col].dtype
            null_count = df[col].isnull().sum()
            null_rate = (null_count / rows) * 100
            unique_count = df[col].nunique()
            col_info.append(f"  - {col}: 类型={dtype}, 唯一值={unique_count}, 缺失率={null_rate:.1f}%")
        
        for info in col_info:
            print(info)
            
        if cols > 15:
            print(f"  - ... (剩余 {cols - 15} 列省略)")

        # 3. 核心统计特征 (针对数值型列)
        numeric_cols = df.select_dtypes(include=['number']).columns
        if len(numeric_cols) > 0:
            print(f"▶ 数值型字段统计特征 (抽取前 3 个核心指标):")
            desc = df[numeric_cols[:3]].describe()
            print(desc)
        else:
            print(f"▶ 数值型字段: 无")
            
        # 4. 持久化为纯文本 (CSV)
        # 净化文件名，移除特殊字符
        safe_sheet_name = "".join([c for c in str(sheet_name) if c.isalnum() or c in ' _-']).rstrip()
        output_path = os.path.join(output_dir, f"{safe_sheet_name}.csv")
        
        print(f"▶ [4/4] 正在将数据持久化至存储层: {output_path}")
        try:
            df.to_csv(output_path, index=False, encoding='utf-8')
            print(f"  - 导出成功！")
        except Exception as e:
            print(f"  - 导出失败: {e}")

    print(f"\n========== 深度解析与持久化全部完成 ==========")
    print(f"所有非空数据表已导出为 CSV，保存在:\n{output_dir}")

if __name__ == "__main__":
    # 指向同一目录下的 xlsb 文件，采用相对路径更灵活
    # 获取脚本当前所在目录的绝对路径
    current_dir = os.path.dirname(os.path.abspath(__file__))
    target_file = os.path.join(current_dir, 'Ashton Slotting Report - 20260404.xlsb')
    analyze_xlsb_first_principles(target_file)