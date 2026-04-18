import pandas as pd
import math
import os

# 读取 CSV 文件
df = pd.read_csv(r'C:\Users\jishen\Downloads\INPUT_LIST-2.csv')

# 每 200 行一个文件
batch_size = 200
total_batches = math.ceil(len(df) / batch_size)

# 创建输出文件夹
output_folder = r'C:\Users\jishen\Downloads\mac_output'
os.makedirs(output_folder, exist_ok=True)

# 定义每个文件的头部和尾部（去掉 autECLIOIA/ECLOIA）
header = """[PCOMM SCRIPT HEADER]
LANGUAGE=VBSCRIPT
DESCRIPTION=
[PCOMM SCRIPT SOURCE]
OPTION EXPLICIT
autECLSession.SetConnectionByName(ThisSessionName)

REM This line calls the macro subroutine
subSub1_

sub subSub1_()
    autECLSession.autECLOIA.WaitForAppAvailable
"""

footer = "end sub"

# 生成脚本内容
for i in range(total_batches):
    chunk = df.iloc[i * batch_size : (i + 1) * batch_size]
    body = ""

    for _, row in chunk.iterrows():
        body += f"""       autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "O"
    autECLSession.autECLPS.SendKeys "{row['PALLET ID']}"
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "[tab]"
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "{row['ITEM NUMBER']}"
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "[enter]"
    autECLSession.autECLPS.SendKeys "[enter]"
    autECLSession.autECLPS.WaitForAttrib 8,19,"00","3c",3,10000
    autECLSession.autECLPS.WaitForCursor 8,20,10000
    autECLSession.autECLOIA.WaitForAppAvailable   
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "i"
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "[pf8]"
    autECLSession.autECLPS.WaitForAttrib 5,8,"00","3c",3,10000
    autECLSession.autECLPS.WaitForCursor 5,9,10000
    autECLSession.autECLOIA.WaitForAppAvailable
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "{row['RP QTY']}"
    autECLSession.autECLPS.SendKeys "[enter]"
     autECLSession.autECLPS.Wait 3   
    autECLSession.autECLPS.SendKeys "[pf3]"
    autECLSession.autECLOIA.WaitForAppAvailable   
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.WaitForCursor 8,20,10000
    autECLSession.autECLOIA.WaitForAppAvailable   
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "c"
    autECLSession.autECLPS.SendKeys "y"
    autECLSession.autECLPS.SendKeys "y"
    autECLSession.autECLOIA.WaitForInputReady
    autECLSession.autECLPS.SendKeys "n"
    autECLSession.autECLPS.SendKeys "[enter]"   
    autECLSession.autECLPS.WaitForCursor 8,20,10000
    autECLSession.autECLOIA.WaitForAppAvailable
"""

    full_script = f"{header}\n{body}{footer}"
    output_path = os.path.join(output_folder, f'RP_putaway_part_{i+1:02}.mac')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(full_script)

print("✅ 所有 .mac 文件已成功生成。位置：", output_folder)
