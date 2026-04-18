import pandas as pd
from datetime import datetime, timedelta
from pathlib import Path


def convert_hold_list(excel_path):
    """
    转换HoldList Excel表格到指定格式，并生成MAC脚本文件
    """
    # 读取Excel文件，将Serial Number作为字符串读取避免精度丢失
    df = pd.read_excel(excel_path, sheet_name='Remain', dtype={'Serial Number': str})

    # 计算日期 (今天 + 2周)，格式为：2025-08-04
    today_plus_2weeks = (datetime.now() + timedelta(weeks=2)).strftime('%Y-%m-%d')

    # 转换Serial Number为数字并删除空值
    df['Serial Number'] = df['Serial Number'].astype(str).str.strip()
    # .str 是 pandas 用来批量处理 Series 里每个元素的“字符串方法”的入口, 比如 .str.strip()，.str.lower()，.str.replace() 等。
    # .astype(str)
    # 这个方法会把这一列里的每个元素（无论原来是数字、空值还是别的）都强制转成字符串类型。
    # 执行完这步后，这一列的“每个元素”就都是字符串了。

    df = df[df['Serial Number'] != 'nan']  # 删除字符串形式的nan
    df = df[df['Serial Number'] != '']  # 删除空字符串

    df['Serial Number'] = pd.to_numeric(df['Serial Number'], errors='coerce').astype('Int64')

    # 按Item Number和Master MO/PO分组处理连续性
    def process_serials(group):
        serials = sorted(group['Serial Number'].tolist())
        results = []

        if len(serials) == 1:
            results.append({
                'Item Number': group['Item Number'].iloc[0],
                'Master MO/PO': group['Master MO/PO'].iloc[0],
                'Comments' : group['Comments'].iloc[0],
                'Begin Serial#': serials[0],
                'Ending Ser#': serials[0],
                'Qty Needed': 1
            })
        else:
            current_start = serials[0]
            current_end = serials[0]

            for i in range(1, len(serials)):
                if serials[i] == serials[i - 1] + 1:
                    current_end = serials[i]
                else:
                    results.append({
                        'Item Number': group['Item Number'].iloc[0],
                        'Master MO/PO': group['Master MO/PO'].iloc[0],
                        'Comments': group['Comments'].iloc[0],
                        'Begin Serial#': current_start,
                        'Ending Ser#': current_end,
                        'Qty Needed': current_end - current_start + 1
                    })
                    current_start = serials[i]
                    current_end = serials[i]

            results.append({
                'Item Number': group['Item Number'].iloc[0],
                'Master MO/PO': group['Master MO/PO'].iloc[0],
                'Comments': group['Comments'].iloc[0],
                'Begin Serial#': current_start,
                'Ending Ser#': current_end,
                'Qty Needed': current_end - current_start + 1
            })
        return results

    all_results = []
    for (item, po,Comments), group in df.groupby(['Item Number', 'Master MO/PO','Comments']):
        all_results.extend(process_serials(group))

    result = pd.DataFrame(all_results)

    # 注意列顺序，Qty Needed 放到 Begin Serial# 前面
    final_df = pd.DataFrame({
        'WHSE': '="335"',
        'Estimated Release Date': '="' + today_plus_2weeks + '"',
        'Item': result['Item Number'],
        'Customer Order Need Date': '="' + today_plus_2weeks + '"',
        'PO#': result['Master MO/PO'],
        'Qty Needed': result['Qty Needed'],
        'Begin Serial#': "'" + result['Begin Serial#'].astype(str),
        'Ending Ser#': "'" + result['Ending Ser#'].astype(str),
        'Comments': result['Comments']
    })

    # 保存CSV文件到Downloads文件夹
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_path = Path.home() / "Downloads" / f'hold list - {timestamp}.csv'

    # 使用特殊格式保存，确保大数字和日期显示为文本
    with open(output_path, 'w', newline='', encoding='utf-8-sig') as f:
        # 写入表头
        f.write(','.join(final_df.columns) + '\n')

        for _, row in final_df.iterrows():
            line = []
            for col in final_df.columns:
                if col in ['Begin Serial#', 'Ending Ser#']:
                    # 序列号列用双引号包围并添加制表符，强制文本格式
                    line.append(f'="{row[col][1:]}"')
                else:
                    line.append(str(row[col]))
            f.write(','.join(line) + '\n')

    print(f"CSV文件转换完成！文件保存至: {output_path}")

    # 生成MAC脚本文件
    generate_mac_script(result, today_plus_2weeks, timestamp)

    print(f"处理了 {len(final_df)} 个Item/PO组合")
    print("\n结果预览:")
    print(final_df.head())

    return final_df


def generate_mac_script(result_df, release_date, timestamp):
    """
    生成MAC脚本文件
    """
    # MAC文件保存路径
    mac_filename = f"wh335hold{timestamp}.mac"
    mac_path = Path("D:/Documents/23-HOLD") / mac_filename

    # 确保目录存在
    mac_path.parent.mkdir(parents=True, exist_ok=True)

    # 生成MAC脚本内容
    mac_content = []

    # 添加文件头
    mac_content.append("Description =")
    mac_content.append("[wait app]")
    mac_content.append("[wait inp inh]")
    mac_content.append("")

    # 为每一行数据生成MAC命令
    for _, row in result_df.iterrows():
        item_number = str(row['Item Number'])
        po_number = str(row['Master MO/PO'])
        qty_needed = str(row['Qty Needed'])
        begin_serial = str(row['Begin Serial#'])
        ending_serial = str(row['Ending Ser#'])
        Comments = str(row['Comments'])


        # 生成单个记录的MAC命令块1246
        record_block = f"""[pf6]
wait 1 sec until cursor at (5,21)
"335
wait 5 msec 
"{release_date}
wait 5 msec 
"{item_number}
[tab field]
"{release_date}
wait 5 msec 
"{po_number}
wait 5 msec 
"{qty_needed}
[tab field]
"{begin_serial}
[tab field]
"{ending_serial}
[tab field]
"{Comments}

[enter]

[enter]
wait 5 msec 
[wait inp inh]

"""
        mac_content.append(record_block)

    # 写入MAC文件
    with open(mac_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(mac_content))

    print(f"MAC脚本文件生成完成！文件保存至: {mac_path}")


# 使用示例
if __name__ == "__main__":
    # 请替换为您的Excel文件路径
    excel_file = r"D:\Documents\23-HOLD\hold_list\20260312.xlsx"
    convert_hold_list(excel_file)
