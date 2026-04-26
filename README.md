# BI scripts development environment

This repository contains warehouse, BI, SQL, Power BI, and Python utility scripts. It does not have a single root application; most folders are standalone analyses or scripts.

## Python setup on Linux

Install the native packages needed for virtual environments and SQL Server ODBC access:

```bash
sudo apt-get update
sudo apt-get install -y python3.12-venv unixodbc tdsodbc
printf '\n[SQL Server]\nDescription=FreeTDS alias for legacy SQL Server connection strings\nDriver=libtdsodbc.so\nSetup=libtdsS.so\nUsageCount=1\n' | sudo tee -a /etc/odbcinst.ini >/dev/null
```

Create a virtual environment from the repository root and install the shared Python dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

The original Visual Studio/Anaconda exports are available at:

- `000_python/Python/Python_Ashley/environment.yml`
- `000_python/Python/Python_Ashley_6/environment.yml`

Those files were exported from Windows and include Windows-specific packages and prefixes, so the root `requirements.txt` is the recommended Linux setup for Cursor Cloud.

## Runnable local Flask app

The local web app is in `000_python/Python/006_i7SQLSERVER`.

Run it with:

```bash
source .venv/bin/activate
cd 000_python/Python/006_i7SQLSERVER
python app.py
```

Open `index.html` in a browser or call `http://127.0.0.1:5000/api/query`.

The app starts without a database connection, but its API routes query SQL Server using `pyodbc`:

- server: `JIM_SHEN`
- database: `JIMSHEN666`
- table: `item_master`

On Linux, successful API calls require a reachable SQL Server instance compatible with the connection string in `app.py`. Without access to `JIM_SHEN`, `/api/query` reaches the ODBC driver and then fails with an external database connectivity error.

## Useful validation commands

```bash
python -m pytest
python -m py_compile 000_python/Python/006_i7SQLSERVER/app.py
curl -I http://127.0.0.1:5000/api/query
```
