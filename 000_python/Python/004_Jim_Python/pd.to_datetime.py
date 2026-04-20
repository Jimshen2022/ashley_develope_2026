import pandas as pd

# Sample DataFrame
df = pd.DataFrame({'Invoice_Date': ['20230317', 'invalid date', '20230830', '20231019', '20230922']})

# Convert 'Invoice_Date' column to datetime format, ignoring errors
df['Invoice_Date'] = pd.to_datetime(df['Invoice_Date'], format='%Y%m%d', errors='ignore')

# Print updated DataFrame
print(df)