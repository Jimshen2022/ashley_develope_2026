# import pyodbc
import openpyxl
#
# # Connect to the database
# cnxn = pyodbc.connect('DSN=AFIPROD; PWD=MJ2078')
# cursor = cnxn.cursor()
#
# # Execute the query to retrieve data
# cursor.execute("""
#   SELECT T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T1.WHSLC, T1.QTSYR, T2.ITDSC
#   FROM AMFLIBA.ITEMBL T1, AMFLIBA.ITMRVA T2, AMFLIBA.WHSMST T3
#   WHERE T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR AND T2.STID = T3.STID AND
#   T1.HOUSE = T3.WHID AND T1.HOUSE='335' AND T1.MOHTQ<>0
#   LIMIT 100
# """)
#
# # Fetch all results
# data = cursor.fetchall()
#
# # Close the database connection
# cnxn.close()
#
# # Check if any data was fetched
# if data:
#     # Create a new workbook and worksheet
#     wb = openpyxl.Workbook()
#     ws = wb.active
#
#     # Extract column names reliably from cursor.description
#     column_names = []
#     for col in cursor.description:
#         if hasattr(col, 'name'):
#             column_names.append(col.name)
#         else:
#             column_names.append(col[0])  # Fallback to first element
#
#     # Write column headers using the extracted names
import pyodbc
import openpyxl
# Connect to the database
cnxn = pyodbc.connect('DSN=AFIPROD; PWD=MJ2081')
cursor = cnxn.cursor()

# Execute the query to retrieve data
cursor.execute("""

Select SYSTEM_TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, varchar(COLUMN_TEXT, 50) As COLUMN_DESC 
From QSYS2.SYSCOLUMNS
Where TABLE_NAME in ('BTTRIPD','BTTRIPH','ITEMBL','ITMRVA','ITMEXT','ITMFPR','ITMPRB','PRICE','UAG3CPP','SETDETL','SETHEDR','SetAppl','PSTRUC','TBL_TRIPLESS_ITEM_DETAILS','LOGFCST',
'IMHIST','ATPSUM','CODATAN','SCP_FCST_ROOT','ATPSUP','TAGINVD','TAGINVD2','AINVCTL','INSTAT','INEXCD','COMAST','CODATAN','EXTORD',
'ACUSMASJ','AEXTCUS','VENNAML0','ITMEXT','ITEMASA','SetAppl')
""")

# Fetch all results
data = cursor.fetchall()

# Close the database connection
cnxn.close()

# Print column names (headers)
column_names = []
for col in cursor.description:
    if hasattr(col, 'name'):
        column_names.append(col.name)
    else:
        column_names.append(col[0])  # Fallback to first element

print(*column_names, sep='\t')  # Print column names separated by tabs

# Print data rows
for row in data:
    print(*row, sep='\t')  # Print each row's values separated by tabs

# No data message remains the same
if not data:
    print("No data found")

    # Write data rows starting from the second row
    for row_index, row in enumerate(data, start=2):
        for col_index, value in enumerate(row):
            ws.cell(row=row_index, column=col_index+1).value = value

    # Save the workbook to D:\whs335onhand.xlsx
    wb.save(filename="D:\\as400schema.xlsx")
    print("Data exported successfully to D:\\as400schema.xlsx")
else:
    print("No data found")
