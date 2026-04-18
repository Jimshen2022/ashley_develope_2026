import pyodbc

# Connect to the database
cnxn = pyodbc.connect('DSN=AFIPROD; PWD=MJ2080')
cursor = cnxn.cursor()

# Execute the query to retrieve data
cursor.execute("""
Select SYSTEM_TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, varchar(COLUMN_TEXT, 50) As COLUMN_DESC 
From QSYS2.SYSCOLUMNS
Where TABLE_NAME in ('BTTRIPD','BTTRIPH','ITEMBL','ITMRVA','ITMEXT','ITMFPR','ITMPRB','PRICE','UAG3CPP','SETDETL','SETHEDR','SetAppl','PSTRUC','TBL_TRIPLESS_ITEM_DETAILS','LOGFCST',
'IMHIST','ATPSUM','CODATAN','SCP_FCST_ROOT','ATPSUP','TAGINVD','TAGINVD2','AINVCTL','INSTAT','INEXCD','COMAST','CODATAN','EXTORD',
'ACUSMASJ','AEXTCUS','VENNAML0','ITMEXT','ITEMASA','SetAppl')
LIMIT 10
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
