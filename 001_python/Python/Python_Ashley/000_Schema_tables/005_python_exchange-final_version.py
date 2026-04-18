import win32com.client
import os
from datetime import datetime, timedelta
import pandas as pd

# 📂 保存路径
BASE_DOWNLOAD_DIR = r'D:\Documents\EmailDownload'

# 📅 最近7天
start_date = datetime.now() - timedelta(days=14)
start_date = start_date.replace(tzinfo=None)  # 去除时区信息

# 启动Outlook
outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
inbox = outlook.GetDefaultFolder(6)  # 6 = 收件箱
messages = inbox.Items
messages.Sort("[ReceivedTime]", True)  # 按时间降序

results = []

for msg in messages:
    try:
        received_time = msg.ReceivedTime
        received_time_naive = received_time.replace(tzinfo=None)

        if received_time_naive < start_date:
            break  # 跳出循环

        subject = msg.Subject
        sender = msg.SenderEmailAddress
        body = msg.Body

        subject_match = 'Payslip' in subject
        body_match = any(k in body for k in ['urgent', 'payment due'])

        attachment_names = []
        attachment_paths = []

        attachment_match = False
        for att in msg.Attachments:
            name = att.FileName.lower()
            if any(name.endswith(ext) for ext in ['.pdf', '.xlsx']):
                attachment_match = True
                date_folder = received_time.strftime('%Y-%m-%d')
                save_dir = os.path.join(BASE_DOWNLOAD_DIR, date_folder)
                os.makedirs(save_dir, exist_ok=True)

                save_path = os.path.join(save_dir, att.FileName)
                att.SaveAsFile(save_path)

                attachment_names.append(att.FileName)
                attachment_paths.append(save_path)

        if subject_match or body_match or attachment_match:
            results.append({
                'Subject': subject,
                'Sender': sender,
                'Received': received_time.strftime('%Y-%m-%d %H:%M'),
                'Attachments': ', '.join(attachment_names),
                'Attachment Paths': ', '.join(attachment_paths),
                'Preview': body[:100]
            })

    except Exception as e:
        print(f"Error: {e}")

# # 导出CSV
# df = pd.DataFrame(results)
# csv_path = os.path.join(BASE_DOWNLOAD_DIR, 'filtered_emails_outlook.csv')
# df.to_csv(csv_path, index=False, encoding='utf-8-sig')
# print(f"✅ 完成：{csv_path}")

# --- 导出CSV（加时间戳） ---
df = pd.DataFrame(results)
timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M')
csv_filename = f'filtered_emails_outlook_{timestamp}.csv'
csv_path = os.path.join(BASE_DOWNLOAD_DIR, csv_filename)

df.to_csv(csv_path, index=False, encoding='utf-8-sig')
print(f"✅ 完成：{csv_path}")
