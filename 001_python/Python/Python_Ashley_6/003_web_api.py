from flask import Flask, render_template_string
import pyodbc
import webbrowser
from threading import Timer

app = Flask(__name__)

@app.route('/data', methods=['GET'])
def get_data():
    conn = pyodbc.connect(
        "Driver={ODBC Driver 18 for SQL Server};"
        "Server=ashley-edw.database.windows.net;"
        "Database=ASHLEY_EDW;"
        "Authentication=ActiveDirectoryInteractive;"
        "Encrypt=yes;TrustServerCertificate=no;"
    )
    cursor = conn.cursor()
    cursor.execute("SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_employee WHERE wh_id = '335'")
    cols = [c[0] for c in cursor.description]
    rows = cursor.fetchall()
    conn.close()

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
        <h2>Top 10 Employees (wh_id=335)</h2>
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