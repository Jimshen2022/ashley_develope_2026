## Cursor Cloud specific instructions

### Codebase overview

This is a **warehouse/distribution center BI & analytics repository** for Ashley Furniture Industries (AFI). It contains:

- **Python scripts** (~470+ files): Data processing, reporting, Excel automation, and DB queries
- **SQL queries** (~680+ files): IBM DB2/AS400, SQL Server T-SQL, and Azure SQL
- **Power Query M files** (~35 files): Power BI data transformations
- **Power BI conversion tools** (root-level): `power_bi_converter.py`, `power_bi_auto_converter.py`, `Convert-PowerBIFiles.ps1`, batch scripts

This is **not** a traditional web application. There is no `package.json`, `docker-compose`, `Makefile`, or CI/CD pipeline. The only dependency spec is a Conda `environment.yml` at `000_python/Python/Python_Ashley_6/environment.yml` targeting Windows.

### Key limitations on Linux / Cloud Agent VMs

- Many Python scripts depend on **Windows-only** libraries: `win32com.client`, `xlwings`, `pyautogui`, `pygetwindow`. These cannot run on Linux.
- Most data-processing scripts require **corporate database access** (IBM AS400 via ODBC DSN `AFIPROD`, SQL Server `MillenniumWHJSQLprod`, Azure SQL `ashley-edw.database.windows.net`). These are unreachable from the Cloud Agent VM.
- Power BI conversion tools require **Power BI Desktop** (Windows-only GUI application).

### What works on Linux

- **Pure Python logic and data transformations** using pandas, openpyxl, duckdb, numpy, scipy, scikit-learn, plotly, dash, flask, and other cross-platform packages.
- **Linting**: `flake8 --max-line-length=120 <file>` works on all `.py` files.
- **pytest**: Available but no automated tests exist in the repo (exit code 5 = no tests collected).
- **`FILES_MANIFEST.py`**: Runs and prints a project guide (note: has a pre-existing bug on line 212 — trailing comma turns a dict into a tuple, causing a TypeError at the end).

### Running commands

- **Lint**: `flake8 --max-line-length=120 <file.py>`
- **Run any script**: `python3 <script.py>` (ensure `$HOME/.local/bin` is on `PATH`)
- **Test**: `python3 -m pytest` (no tests exist currently)
- **Hello world**: `python3 FILES_MANIFEST.py` (prints project manifest; exits with error due to pre-existing bug)

### Installed Python packages (pip, not conda)

Core packages from `environment.yml` that are cross-platform: pandas, openpyxl, pyodbc, sqlalchemy, plotly, dash, flask, duckdb, scikit-learn, scipy, statsmodels, seaborn, matplotlib, numpy, requests, beautifulsoup4, lxml, xlrd, xlsxwriter, pyxlsb, pyyaml, python-dotenv, tabulate, rich, tqdm, jinja2, click, pillow, flake8, pylint, pytest.
