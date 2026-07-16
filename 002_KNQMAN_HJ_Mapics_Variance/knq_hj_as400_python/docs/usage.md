# Usage

## Extract workbook sources

```powershell
$env:PYTHONPATH = "src"
python -m knq_hj_as400.extract_workbook "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\KNQ_HJ_AS400\MAPICS vs HJ vs KNQ report - 20260710.xlsb" --output-dir "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\knq_hj_as400_python\analysis"
```

## Rebuild DATA with pandas

```powershell
$env:PYTHONPATH = "src"
python -m knq_hj_as400.run_pipeline --workbook "D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\KNQ_HJ_AS400\MAPICS vs HJ vs KNQ report - 20260710.xlsb" --limit 15
```
