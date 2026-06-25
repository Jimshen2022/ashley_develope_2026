import pandas as pd
import os
import glob
from collections import defaultdict

def build_digital_lineage(extracts_dir):
    """
    基于第一性原理，建立业务数据的『数字血缘』（Digital Lineage）。
    1. 实体降维：扫描所有导出的独立 CSV，将其视为一个个离散的业务实体。
    2. 特征提取：提取每个实体的属性（列名）。
    3. 拓扑网络映射：寻找跨越不同实体的共性基因（同名字段），推演隐藏的血缘关联（PK/FK 关系）。
    4. 核心节点识别：通过计算图中节点的度（Degree），定位驱动整个业务运转的第一性核心维度。
    """
    print("========== 开启数字血缘 (Digital Lineage) 拓扑重构 ==========")
    
    if not os.path.exists(extracts_dir):
        print(f"错误: 找不到提取的数据目录 {extracts_dir}")
        print("请先运行 deep_analyze_xlsb.py 将二进制报表降维为纯文本数据。")
        return

    csv_files = glob.glob(os.path.join(extracts_dir, "*.csv"))
    if not csv_files:
        print(f"未在 {extracts_dir} 中发现任何 CSV 文件。")
        return
        
    print(f"\n[1/3] 正在扫描业务实体：共发现 {len(csv_files)} 个独立数据表。")
    
    # 实体到属性的映射（Entity -> Attributes）
    table_columns_map = {}
    # 属性到实体的反向索引（Attribute -> Entities）
    column_to_tables = defaultdict(list)
    
    print("\n[2/3] 正在提取业务实体的特征基因...")
    for file_path in csv_files:
        table_name = os.path.basename(file_path).replace('.csv', '')
        try:
            # 第一性原理：我们只需要骨架，不需要血肉。只读第一行表头即可完成拓扑分析，极大节省内存和时间。
            df = pd.read_csv(file_path, nrows=0)
            columns = df.columns.tolist()
            table_columns_map[table_name] = columns
            
            # 构建属性基因的反向映射图
            for col in columns:
                # 基因清洗：去除空格，转为小写，抹平格式差异造成的维度误判
                clean_col = str(col).strip().lower()
                
                # 基因降噪：过滤掉系统生成的无意义特征（如 Pandas 的 Unnamed）和过于通用的非核心维度
                if not clean_col.startswith('unnamed') and clean_col not in ['index', 'id', 'date', 'time', 'status', 'description']:
                    column_to_tables[clean_col].append({
                        'table': table_name,
                        'original_col': col
                    })
        except Exception as e:
            print(f"  - 无法读取实体 {table_name}: {e}")
            
    print(f"  - 成功解码 {len(table_columns_map)} 个实体的表层基因结构。")
    print(f"  - 共计发现 {len(column_to_tables)} 个独立维度的特征节点。")

    print("\n[3/3] 正在推演业务拓扑与数字血缘网络...")
    # 寻找多重共病基因（出现在两个及以上表中的字段），它们就是连接孤岛的桥梁（Join Keys）
    lineage_links = []
    
    for clean_col, tables_info in column_to_tables.items():
        if len(tables_info) > 1:
            table_names = [t['table'] for t in tables_info]
            original_names = [t['original_col'] for t in tables_info]
            
            lineage_links.append({
                'key_node': clean_col,
                'original_keys': list(set(original_names)),
                'connected_tables': table_names,
                'degree': len(table_names) # 图论：节点的度
            })
            
    # 第一性原理：在复杂网络中，度（Degree）越高的节点，代表越核心的本质。
    lineage_links.sort(key=lambda x: x['degree'], reverse=True)
    
    print("\n========== 数字血缘 (Digital Lineage) 分析报告 ==========")
    print("▶ 核心驱动维度 (Top Hubs - 按图论网络核心度排序):")
    for i, link in enumerate(lineage_links[:15]):
        print(f"  [{i+1}] 维度节点: '{link['original_keys'][0]}' (连接度: {link['degree']})")
        print(f"      🔗 串联以下业务域: {', '.join(link['connected_tables'])}")
        
    print("\n▶ 下一步行动指南 (Actionable Insights):")
    print("  1. 数据建模：在后续的 SQL 或 PowerBI 建模中，优先使用高连接度的节点（如上图 Top 5）作为主数据外键进行 JOIN。")
    print("  2. 数据治理：这几个高维特征是驱动 Slotting 业务的第一性维度，其数据质量（缺失、错误）将引起全网雪崩效应，需重点监控。")
    
    # 将完整的拓扑血缘图谱固化下来
    report_path = os.path.join(os.path.dirname(extracts_dir), "data_lineage_topology.txt")
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("========== Slotting 业务域 - 数字血缘拓扑报告 ==========\n\n")
        
        f.write("【一】核心血缘链路 (Lineage Links)\n")
        f.write("说明：以下字段出现在多个业务表中，是跨表关联（JOIN）的核心主键。\n\n")
        for i, link in enumerate(lineage_links):
            f.write(f"[{i+1}] 跨域节点: '{link['original_keys'][0]}' (核心度: {link['degree']})\n")
            f.write(f"    🔗 串联实体: {', '.join(link['connected_tables'])}\n\n")
            
        f.write("\n\n【二】实体基因字典 (Data Dictionary)\n")
        f.write("说明：各离散业务实体（数据表）内部的完整特征属性映射。\n")
        for table, cols in table_columns_map.items():
            clean_cols = [str(c) for c in cols if not str(c).lower().startswith('unnamed')]
            f.write(f"\n[{table}] ({len(clean_cols)} 个有效维度):\n  - {', '.join(clean_cols)}\n")

    print(f"\n✅ 完整的业务域数字血缘图谱已构建完毕，报告固化于: {report_path}")

if __name__ == "__main__":
    # 获取脚本当前所在目录的绝对路径，确保灵活运行
    current_dir = os.path.dirname(os.path.abspath(__file__))
    extracts_dir = os.path.join(current_dir, 'Ashton Slotting Report - 20260404_extracts')
    build_digital_lineage(extracts_dir)