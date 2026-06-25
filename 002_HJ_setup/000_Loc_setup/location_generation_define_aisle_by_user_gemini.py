import csv
from datetime import datetime
from pathlib import Path


def generate_warehouse_locations():
    # 基础配置常量
    BUILDING = "A3"
    SIDE_C_LETTERS = ['C', 'E', 'G', 'J', 'L', 'N', 'Q', 'S', 'U', 'W', 'Y']
    SIDE_D_LETTERS = ['D', 'F', 'H', 'K', 'M', 'P', 'R', 'T', 'V', 'X', 'Z']
    SECOND_LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M',
                      'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

    locations_data = []

    # 遍历通道 36 到 50
    for aisle_num in range(36, 51):
        aisle = f"{aisle_num:03d}"

        # 判断方向：36为forward(偶数)，37为backward(奇数)，依次交替
        is_forward = (aisle_num % 2 == 0)

        # 生成 Bay 的遍历顺序
        bays = range(1, 54) if is_forward else range(53, 0, -1)

        picking_seq_num = 1

        for bay in bays:
            # 计算第一个字母
            group_index = (bay - 1) // 6
            first_c = SIDE_C_LETTERS[group_index]
            first_d = SIDE_D_LETTERS[group_index]

            # 计算第二个字母（连续4个）
            pos_in_group = (bay - 1) % 6
            start_idx = pos_in_group * 4
            second_four = SECOND_LETTERS[start_idx: start_idx + 4]

            # 嵌套循环：Side -> 第二字母 -> Level
            for side in ['C', 'D']:
                first_letter = first_c if side == 'C' else first_d

                for second_letter in second_four:
                    section = first_letter + second_letter

                    for level in [1, 2, 3, 4]:
                        # 组装 Location 和 Picking Sequence
                        location = f"{BUILDING}{aisle}{section}{level}"
                        picking_sequence = f"1{aisle}{picking_seq_num:07d}"

                        # 记录数据
                        locations_data.append({
                            'Location': location,
                            'Building': BUILDING,
                            'Aisle': aisle,
                            'Bay_Number': bay,
                            'Section': section,
                            'Level': level,
                            'Side': side,
                            'Picking_Sequence': picking_sequence
                        })

                        picking_seq_num += 1

    return locations_data


def export_to_downloads(data):
    # 获取系统当前的 Downloads 文件夹路径
    downloads_path = Path.home() / "Downloads"

    # 如果 Downloads 文件夹不存在（比如某些系统语言不同），则保存在当前脚本目录
    if not downloads_path.exists():
        downloads_path = Path.cwd()
        print("未找到系统的 Downloads 文件夹，将保存在当前目录。")

    # 生成带时间戳的文件名
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"warehouse_locations_{timestamp}.csv"
    file_path = downloads_path / filename

    # 写入 CSV 文件
    headers = ['Location', 'Building', 'Aisle', 'Bay_Number', 'Section', 'Level', 'Side', 'Picking_Sequence']

    with open(file_path, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        writer.writerows(data)

    print(f"✅ 数据导出成功！")
    print(f"文件位置: {file_path}")
    print(f"共生成记录: {len(data)} 条")


if __name__ == "__main__":
    print("开始生成库位数据...")
    data = generate_warehouse_locations()
    export_to_downloads(data)