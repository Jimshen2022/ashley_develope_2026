import pandas as pd

df1 = pd.read_csv('table1.csv')
df2 = pd.read_csv('table2.csv')

# Concatenate the two tables
combined_df = pd.concat([df1, df2], ignore_index=True)

# Sort by item_number column
combined_df = combined_df.sort_values('item_number').reset_index(drop=True)

# Save the combined table to a new csv file
combined_df.to_csv('combined_table.csv', index=False)