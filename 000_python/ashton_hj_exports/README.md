# Ashton HJ SQL Server Connection Notes

Verified on June 29, 2026.

## Verified Working Connection

This connection was successfully tested outside the sandbox with the current Windows login context:

```text
DRIVER={ODBC Driver 17 for SQL Server};
SERVER=AshtonWHJSQLprod;
DATABASE=AAD;
Authentication=ActiveDirectoryIntegrated;
Encrypt=yes;
TrustServerCertificate=yes;
```

## Why This Version Works

The earlier attempts that used `Trusted_Connection=yes` failed in the agent sandbox because the sandbox process did not have access to the normal Windows domain credentials.

The working pattern in [link_to_hj_sql_sev.py](../../000_hj_sql_schema/link_to_hj_sql_sev.py) uses:

- `Authentication=ActiveDirectoryIntegrated`
- `Encrypt=yes`
- `TrustServerCertificate=yes`
- SQLAlchemy + `mssql+pyodbc:///?odbc_connect=...`

That exact approach was re-tested successfully on June 29, 2026.

## Successful Verification Query

The following test query succeeded:

```sql
SELECT TOP 1 name FROM sys.tables;
```

Returned value:

```text
t_export_tran_backup_090425_INC0555136
```

## Files In This Folder

- `run_ashton_sql_export.py`
  Reusable export template. Usually you do not need to edit this file.
- `query_to_run.sql`
  Default SQL file. For most future use cases, only edit this file.
- `export_a3_x_locations.py`
  The first task-specific version kept for reference.

## Recommended Reusable Workflow

1. Edit `query_to_run.sql`
2. Run the template script
3. Find the timestamped Excel file in `Downloads`

Run command:

```powershell
python d:\GitHub\ashley_develope_2026\000_python\ashton_hj_exports\run_ashton_sql_export.py
```

## Optional Custom SQL File

You can also point the template to any other `.sql` file:

```powershell
python d:\GitHub\ashley_develope_2026\000_python\ashton_hj_exports\run_ashton_sql_export.py --sql-file "d:\GitHub\some_query.sql"
```

## Optional Output Prefix

If you want to control the export file name prefix:

```powershell
python d:\GitHub\ashley_develope_2026\000_python\ashton_hj_exports\run_ashton_sql_export.py --output-prefix "my_report"
```

Output format:

```text
C:\Users\jishen\Downloads\my_report_YYYYMMDD_HHMMSS.xlsx
```
