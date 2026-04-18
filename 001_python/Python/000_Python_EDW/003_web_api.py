from flask import Flask, jsonify
import pyodbc

app = Flask(__name__)
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True  # 👈 自动美化输出

@app.route('/')
def home():
    return "✅ Flask connected to Azure SQL! Try /data"

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
    rows = [dict(zip(cols, r)) for r in cursor.fetchall()]
    conn.close()
    return jsonify(rows)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
