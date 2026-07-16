# KNQ / HJ / AS400 Python Migration

This project is the Python replacement for the Excel workbook:

- `MAPICS vs HJ vs KNQ report - 20260710.xlsb`

## What is included

- Workbook reverse-engineering artifacts under `analysis/`
- Exported VBA modules for traceability
- Sheet map, previews, and macro dependency indexes
- A snapshot pipeline that rebuilds the `DATA` report from workbook sheets
- A live SQL pipeline that pulls source data through independent Python connectors
- VBA-compatible Setup parameter loading for SQL date ranges and AS400 credentials

## Project modes

### 1. Workbook analysis

```powershell
python -m knq_hj_as400.extract_workbook "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\KNQ_HJ_AS400\MAPICS vs HJ vs KNQ report - 20260710.xlsb" --output-dir "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\knq_hj_as400_python\analysis"
```

### 2. Snapshot pipeline

This mode rebuilds the variance report from the workbook's staged sheets.

```powershell
$env:PYTHONPATH='src'
python -m knq_hj_as400.run_pipeline_fast --workbook "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\KNQ_HJ_AS400\MAPICS vs HJ vs KNQ report - 20260710.xlsb" --limit 10
```

### 3. Live SQL pipeline

This mode keeps the workbook only as the parameter and manual-sheet source, while SQL pulls are executed by Python connectors.

```powershell
$env:PYTHONPATH='src'
python -m knq_hj_as400.run_live_pipeline --workbook "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\KNQ_HJ_AS400\MAPICS vs HJ vs KNQ report - 20260710.xlsb" --limit 10
```

## VBA-compatible SQL parameter rules

The Python connectors follow the same workbook-driven parameters as VBA:

- `Setup!C2` and `Setup!C3` drive KNQ import/export date ranges
- `Setup!C3` drives KNQ on-hand target date
- `Setup!R1` and `Setup!R2` drive AS400 credentials
- HJ SQL modules preserve raw quoted date values where the VBA query injected them directly
- KNQ SQL modules sanitize the dates where VBA wrapped them in SQL string literals
- AS400 sales-activity queries keep the VBA `Date` and `Date - 3` IBM `CYYMMDD` logic

## Current verification

The migration has been verified locally at the code level:

- VBA SQL extraction rebuilds the full text for the SQL-backed modules
- KNQ date parameters compile exactly once instead of double-quoting
- HJ received and shipped queries preserve the original VBA `BETWEEN startdate AND enddate` pattern
- The live pipeline imports successfully
- The snapshot pipeline was previously run successfully and produced a 4,623-row report summary

Direct database execution depends on environment access to SQL Server and AS400 DSNs.
