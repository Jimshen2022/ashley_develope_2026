import pandas as pd
import pyodbc
from datetime import datetime


def load_rp_open_orders(excel_path):
    df_config = pd.read_excel(excel_path, sheet_name='Setup', nrows=4, usecols="A", header=None)
    uname, upass, date_start, date_end = df_config[0].tolist()

    conn_str = (
        "Driver={IBM i Access ODBC Driver};"
        "System=10.18.18.104;"
        "DATABASE=JIMTDTA;"
        f"UID={uname};PWD={upass};"
    )

    sql = """
    SELECT d1.CUSNO, d1.CUSNM, d1.ENTDAT, d1.RPKEY, d1.MODEL, d1.SHPDAT, d1.ORDPCK, d1.TRIP#, 
           d1.WHOSE, d1.SHPCTY, d1.ITEMNO, t4.ITDSC, d1.QTY, d1.SHPFLG, d1.PCKDTE, d1.PCKTME, d1.SHPNO, d1.SHIP3
    FROM (
        SELECT t2.CUSNO, t3.CUSNM, t2.ENTDAT, t2.RPKEY, t2.MODEL, t2.SHPDAT, t2.ORDPCK, t2.TRIP#,
               t2.WHOSE, t2.SHPCTY, t1.ITEMNO, t1.QTY, t1.SHPFLG, t1.PCKDTE, t1.PCKTME, t2.SHPNO, t2.SHIP3
        FROM AFILELIB.ARPDETL t1
        JOIN AFILELIB.ARPHEDR t2 ON t2.RPKEY = t1.RPKEY
        JOIN AMFLIBA.CUSMAS t3 ON t2.CUSNO = t3.CUSNO
        WHERE t2.ACTCOD='A' AND t2.ENTDAT BETWEEN 20210101 AND 20291231
          AND t2.WHOSE='335' AND t2.SHPDAT=0
    ) d1
    LEFT JOIN (
        SELECT DISTINCT t0.ITNBR, UPPER(t0.ITDSC) AS ITDSC
        FROM AMFLIBA.ITMRVA t0
        WHERE t0.STID IN ('335')
    ) t4 ON d1.ITEMNO = t4.ITNBR
    """

    with pyodbc.connect(conn_str) as conn:
        df = pd.read_sql(sql, conn)

    df.to_excel(excel_path, sheet_name="RPOpenOrders", index=False, startrow=1)
    return df


def add_order_status(df):
    def judge(row):
        if row['SHPDAT'] != 0:
            return "Shipped"
        elif row['SHPDAT'] == 99999999:
            return "Order Cancelled"
        elif row['PCKDTE'] == 0 and row['SHPNO'] > 0:
            return "Packed and waiting for stick on trip"
        elif row['PCKDTE'] == 0 and row['ORDPCK'] > 0:
            return "Packed and waiting for stick on trip"
        elif row['PCKDTE'] > 0 and row['SHPNO'] > 0:
            return "Stuck on trip and waiting for picking"
        elif row['PCKDTE'] > 0 and row['ORDPCK'] > 0:
            return "Stuck on trip and waiting for picking"
        elif row['PCKDTE'] == 0 and row['ORDPCK'] == 0 and row['SHPNO'] == 0 and row['SHPDAT'] == 0:
            return "Still not pick&pack"
        return ""

    df["Status"] = df.apply(judge, axis=1)
    return df


def mark_unique_orders(df):
    df['RPKEY_Count'] = df['RPKEY'].map(df['RPKEY'].value_counts())
    df['UniqueFlag'] = df['RPKEY_Count'].apply(lambda x: 1 if x == 1 else 0)
    return df


def add_creation_days(df):
    def parse_date(d):
        try:
            return datetime.strptime(str(d), "%Y%m%d")
        except:
            return None

    df['CreationDate'] = df['ENTDAT'].apply(parse_date)
    df['PendingDays'] = (datetime.today() - df['CreationDate']).dt.days
    return df


def lookup_interval(df, excel_path):
    intervals = pd.read_excel(excel_path, sheet_name="intervals", usecols="A:B")
    intervals.columns = ['MinDay', 'Label']
    intervals = intervals.sort_values('MinDay')

    def lookup(days):
        result = intervals[intervals['MinDay'] <= days]
        if not result.empty:
            return result.iloc[-1]['Label']
        return None

    df['IntervalLabel'] = df['PendingDays'].apply(lookup)
    return df


def map_interval_no(df, excel_path):
    mapping_df = pd.read_excel(excel_path, sheet_name="intervals", usecols="B:C")
    mapping_dict = dict(zip(mapping_df.iloc[:, 0], mapping_df.iloc[:, 1]))
    df['IntervalNo'] = df['IntervalLabel'].map(mapping_dict).fillna("view")
    return df


def main():
    excel_path = r"D:\Documents\08-Ashton_Phu_my\03-RP\Python\Ashton RP Open Orders Fulfillment_v12.xlsb"
    df = load_rp_open_orders(excel_path)
    df = add_order_status(df)
    df = mark_unique_orders(df)
    df = add_creation_days(df)
    df = lookup_interval(df, excel_path)
    df = map_interval_no(df, excel_path)

    df.to_excel(excel_path, sheet_name="RPOpenOrders", index=False, engine='openpyxl')


if __name__ == "__main__":
    main()
