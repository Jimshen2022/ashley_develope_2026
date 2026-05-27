import pandas as pd

# Define the input and output file paths
input_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_Unkits_Ashton_Shipped_Details_with_Tihi_20260120.xlsx"
output_file = r"D:\Documents\08-Ashton_Phu_my\000-Project\001_ASRS\ASRS_DATA_with_8020_Range.csv"

# Read the 'DATA' sheet from the Excel file
df = pd.read_excel(input_file, sheet_name='DATA')

# Convert dimensions from inches to millimeters
df['L_mm'] = df['length(inch)'] * 25.4
df['W_mm'] = df['width(inch)'] * 25.4
df['H_mm'] = df['height(inch)'] * 25.4

# Sort dimensions from longest to shortest to allow carton rotation
df['Dim1'] = df[['L_mm', 'W_mm', 'H_mm']].max(axis=1)
df['Dim3'] = df[['L_mm', 'W_mm', 'H_mm']].min(axis=1)
df['Dim2'] = df[['L_mm', 'W_mm', 'H_mm']].sum(axis=1) - df['Dim1'] - df['Dim3']


# Apply the 80/20 rule to categorize carton sizes for 000_ASRS
def classify_dim(row):
    d1, d2, d3 = row['Dim1'], row['Dim2'], row['Dim3']

    # Handle missing data
    if pd.isna(d1):
        return "Unknown"

    # Category 1: Standard 000_ASRS size covering ~80% of items
    if d1 <= 2200 and d2 <= 1200 and d3 <= 600:
        return "Standard (80%) <= 2200*1200*600 (mm)"

    # Category 2: Large 000_ASRS size covering ~16% of items
    elif d1 <= 2400 and d2 <= 1400 and d3 <= 800:
        return "Large (16%) <= 2400*1400*800 (mm)"

    # Category 3: Oversized items covering the remaining ~2%
    else:
        return "Oversized (2%) > 2400*1400*800 (mm)"


# Create the new column
df['Carton Dimensions Range'] = df.apply(classify_dim, axis=1)

# Drop the temporary calculation columns
df.drop(columns=['L_mm', 'W_mm', 'H_mm', 'Dim1', 'Dim2', 'Dim3'], inplace=True, errors='ignore')

# Save the final dataset to your local drive
df.to_csv(output_file, index=False, encoding='utf-8-sig')
print(f"Process completed successfully. File saved as: {output_file}")