import smtplib
import imaplib
import email
from email.mime.text import MIMEText
from datetime import datetime, timedelta
import getpass

# Configuration
imap_server = 'imap.wanvogfurniture.com'
smtp_server = 'smtp.wanvogfurniture.com'
email_address = 'jishen@wanvogfurniture.com'
password = getpass.getpass('abcde@456789')  # Securely ask for password

# Connect to IMAP server
mail = imaplib.IMAP4_SSL(imap_server)
mail.login(email_address, password)

# Select the mailbox you want to check (INBOX, Sent, etc.)
mail.select('inbox')

# Search for emails from the last week
date = (datetime.now() - timedelta(days=7)).strftime("%d-%b-%Y")
result, data = mail.uid('search', None, '(SINCE {})'.format(date))

# Fetch the emails
ids = data[0].split()
emails_sent = 0
emails_replied = 0

for email_id in ids:
    result, data = mail.uid('fetch', email_id, '(RFC822)')
    raw_email = data[0][1]
    email_message = email.message_from_bytes(raw_email)

    # Check if the email was sent or replied to
    if email_message['From'] == email_address:
        emails_sent += 1
    elif email_message['To'] == email_address:
        emails_replied += 1

# Close the connection
mail.close()
mail.logout()

# Prepare email summary
summary = 'Last week, you sent {} emails and replied to {} emails.'.format(emails_sent, emails_replied)

# Send the summary via email
smtp = smtplib.SMTP(smtp_server)
smtp.starttls()
smtp.login(email_address, password)
message = MIMEText(summary)
message['Subject'] = 'Your Weekly Email Summary'
message['From'] = email_address
message['To'] = email_address
smtp.sendmail(email_address, [email_address], message.as_string())
smtp.quit()

print('Summary sent successfully!')
