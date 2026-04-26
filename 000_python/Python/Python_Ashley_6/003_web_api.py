import os
import urllib
import webbrowser
from threading import Timer

import pandas as pd
import pyodbc
from flask import Flask, render_template_string
from sqlalchemy import create_engine

app = Flask(__name__)

EDW_SERVER = os.getenv("EDW_SERVER", "ashley-edw.database.windows.net")
EDW_DATABASE = os.getenv("EDW_DATABASE", "ASHLEY_EDW")
EDW_AUTHENTICATION = os.getenv("EDW_AUTHENTICATION", "ActiveDirectoryServicePrincipal")
EDW_DRIVER = os.getenv("EDW_DRIVER")
EDW_CONNECT_TIMEOUT = os.getenv("EDW_CONNECT_TIMEOUT", "300")
EDW_CLIENT_ID = os.getenv("EDW_CLIENT_ID")
EDW_CLIENT_SECRET = os.getenv("EDW_CLIENT_SECRET")
EDW_TENANT_ID = os.getenv("EDW_TENANT_ID")

QUERY = """
SELECT TOP 10 *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335')
  AND t1.start_tran_date = '2026-04-26'
  AND t1.tran_type IN ('151');
"""


def get_edw_driver():
    if EDW_DRIVER:
        return EDW_DRIVER

    drivers = pyodbc.drivers()
    if "ODBC Driver 17 for SQL Server" in drivers:
        return "ODBC Driver 17 for SQL Server"
    if "ODBC Driver 18 for SQL Server" in drivers:
        return "ODBC Driver 18 for SQL Server"
    return "ODBC Driver 17 for SQL Server"


def create_edw_engine():
    conn_parts = [
        f"DRIVER={{{get_edw_driver()}}}",
        f"SERVER={EDW_SERVER}",
        f"DATABASE={EDW_DATABASE}",
        f"Authentication={EDW_AUTHENTICATION}",
        "Encrypt=yes",
        "TrustServerCertificate=no",
        f"Connection Timeout={EDW_CONNECT_TIMEOUT}",
    ]
    if EDW_AUTHENTICATION == "ActiveDirectoryServicePrincipal":
        missing = [
            name
            for name, value in {
                "EDW_CLIENT_ID": EDW_CLIENT_ID,
                "EDW_CLIENT_SECRET": EDW_CLIENT_SECRET,
            }.items()
            if not value
        ]
        if missing:
            raise ValueError(f"Missing required environment variables: {', '.join(missing)}")
        conn_parts.extend([f"UID={EDW_CLIENT_ID}", f"PWD={EDW_CLIENT_SECRET}"])

    params = urllib.parse.quote_plus(";".join(conn_parts) + ";")
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}")


@app.route('/health', methods=['GET'])
def health():
    return {
        "authentication": EDW_AUTHENTICATION,
        "client_id_configured": bool(EDW_CLIENT_ID),
        "database": EDW_DATABASE,
        "driver": get_edw_driver(),
        "server": EDW_SERVER,
        "tenant_id_configured": bool(EDW_TENANT_ID),
    }


@app.route('/data', methods=['GET'])
def get_data():
    df = pd.read_sql(QUERY, create_edw_engine())
    cols = df.columns.tolist()
    rows = df.itertuples(index=False, name=None)

    html = """
    <html>
    <head>
        <style>
            body { font-family: Arial; margin: 20px; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #0078d7; color: white; }
            tr:nth-child(even) { background-color: #f2f2f2; }
        </style>
    </head>
    <body>
        <h2>Top 10 TranLog Rows (wh_id=335, tran_type=151)</h2>
        <table>
            <tr>{% for c in cols %}<th>{{ c }}</th>{% endfor %}</tr>
            {% for row in rows %}
            <tr>{% for val in row %}<td>{{ val }}</td>{% endfor %}</tr>
            {% endfor %}
        </table>
    </body>
    </html>
    """
    return render_template_string(html, cols=cols, rows=rows)
def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000/data")

if __name__ == '__main__':
    Timer(1, open_browser).start()  # 延迟1秒打开浏览器
    app.run(host='0.0.0.0', port=5000, debug=True)