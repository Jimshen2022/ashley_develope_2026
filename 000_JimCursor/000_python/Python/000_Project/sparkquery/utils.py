# utils.py
from pyspark.sql.types import *
from datetime import datetime, timedelta

def generate_date_periods(days=60):
    base_date = datetime.now().date()
    periods = []
    for i in range(days - 1, -1, -1):
        day = base_date - timedelta(days=i)
        start = '1' + day.strftime('%y%m%d') + ' 00:00:00'
        end = '1' + day.strftime('%y%m%d') + ' 23:59:59'
        periods.append((start, end))
    return periods

def get_schema():
    return StructType([
        StructField("HOUSE", StringType(), True),
        StructField("TCODE", StringType(), True),
        StructField("ORDNO", StringType(), True),
        StructField("ITNBR", StringType(), True),
        StructField("ITCLS", StringType(), True),
        StructField("UPDDT", StringType(), True),
        StructField("UPDTM", StringType(), True),
        StructField("TRQTY", StringType(), True),
        StructField("ENTUM", StringType(), True),
        StructField("VNDNR", StringType(), True),
        StructField("REFNO", StringType(), True),
        StructField("LLOCN", StringType(), True),
        StructField("BATCH", StringType(), True),
        StructField("TRMID", StringType(), True),
        StructField("TrxTime", StringType(), True)
    ])

def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")
