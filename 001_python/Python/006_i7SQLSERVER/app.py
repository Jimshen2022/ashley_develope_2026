# 保存为 app.py
from flask import Flask, jsonify, send_file
import pyodbc
import pandas as pd
import io
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # 允许跨域请求

def get_data():
    conn = pyodbc.connect(
        'DRIVER={SQL Server};'
        'SERVER=JIM_SHEN;'
        'DATABASE=JIMSHEN666;'
        'Trusted_Connection=yes;'
    )
    df = pd.read_sql("SELECT * FROM item_master", conn)
    conn.close()
    return df

@app.route('/api/query')
def query():
    df = get_data()
    return df.to_json(orient='records')

@app.route('/api/download/<filetype>')
def download(filetype):
    df = get_data()
    buffer = io.BytesIO()
    if filetype == 'csv':
        df.to_csv(buffer, index=False)
        buffer.seek(0)
        return send_file(buffer, as_attachment=True, download_name='item_master.csv', mimetype='text/csv')
    elif filetype == 'excel':
        with pd.ExcelWriter(buffer, engine='xlsxwriter') as writer:
            df.to_excel(writer, index=False, sheet_name='Sheet1')
        buffer.seek(0)
        return send_file(buffer, as_attachment=True, download_name='item_master.xlsx',
                         mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    return "Invalid file type", 400

if __name__ == '__main__':
    app.run(debug=True)
