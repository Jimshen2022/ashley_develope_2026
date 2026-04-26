import pandas as pd
import os

# File path
file_path = r"D:\Documents\08-Ashton_Phu_my\03-RP\1020.01.26\RP as400 vs 1020.01.26\Trip12608 Shipped RP Orders-2.xlsx"

# Read the data from the 'Merged' worksheet
# Note: For .xlsb files, we need to use the engine='pyxlsb'
df = pd.read_excel(file_path, sheet_name='Merged', engine='openpyxl')

# Select only the needed columns
df = df[['Sheet Name', 'PALLET ID', 'ITEM NUMBER', 'RP QTY', 'CARTON QTY']]

# Create the Locations column by concatenating Sheet Name, PALLET ID #1, and RP QTY with asterisks
df['Locations'] = df['Sheet Name'] + '*' + df['PALLET ID'] + '*' + df['RP QTY'].astype(str)

# Group by ITEM NUMBER and calculate sum of RP QTY and CARTON QTY
grouped_df = df.groupby('ITEM NUMBER').agg({
    'RP QTY': 'sum',
    'CARTON QTY': 'sum',
    'Locations': lambda x: ', '.join(x)
}).reset_index()

# Rename columns
grouped_df.columns = ['ITEM NUMBER', 'RP_QTY', 'Carton_qty', 'Locations']

# Open the existing Excel file and write to a new sheet
with pd.ExcelWriter(file_path, engine='openpyxl', mode='a') as writer:
    # Check if 'Location' sheet already exists, if yes, remove it
    if 'Location' in pd.ExcelFile(file_path).sheet_names:
        # We need to create a new workbook with all sheets except 'Location'
        book = writer.book
        if 'Location' in book.sheetnames:
            idx = book.sheetnames.index('Location')
            book.remove(book.worksheets[idx])

    # Write the grouped dataframe to the new 'Location' sheet
    grouped_df.to_excel(writer, sheet_name='Location', index=False)

print("Processing completed. Results written to 'Location' sheet.")