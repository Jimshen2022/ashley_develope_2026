import os
import webbrowser
from threading import Timer

import pandas as pd
from flask import Flask, render_template_string

app = Flask(__name__)

EDW_SERVER = os.getenv("EDW_SERVER", "ashley-edw.database.windows.net")
EDW_DATABASE = os.getenv("EDW_DATABASE", "ASHLEY_EDW")
MOCK_DATA_ENABLED = os.getenv("EDW_USE_MOCK_DATA", "1") != "0"


def get_sample_tranlog():
    """Return deterministic EDW sample data for offline development setup."""
    return pd.DataFrame(
        [
            {
                "wh_id": "335",
                "start_tran_date": "2026-04-26",
                "tran_type": "151",
                "employee_id": "E1024",
                "item_number": "B3381-99",
                "tran_qty": 2,
                "location_id": "A-01-01",
            },
            {
                "wh_id": "335",
                "start_tran_date": "2026-04-26",
                "tran_type": "151",
                "employee_id": "E2048",
                "item_number": "D9477-42",
                "tran_qty": 1,
                "location_id": "B-12-03",
            },
            {
                "wh_id": "335",
                "start_tran_date": "2026-04-26",
                "tran_type": "151",
                "employee_id": "E4096",
                "item_number": "M5520-11",
                "tran_qty": 4,
                "location_id": "C-07-09",
            },
        ]
    )


@app.route('/health', methods=['GET'])
def health():
    return {
        "database": EDW_DATABASE,
        "mock_data": MOCK_DATA_ENABLED,
        "server": EDW_SERVER,
    }


@app.route('/data', methods=['GET'])
def get_data():
    df = get_sample_tranlog()
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
        <h2>Sample TranLog Rows (mock data)</h2>
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