import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32

def fetch_data(query, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2080'):
    """从数据库获取数据"""
    try:
        cnxn = po.connect(connection_string)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"数据获取过程中发生错误: {str(e)}")
        raise

def process_data(df):
    """处理数据"""
    try:
        df['ITNBR'] = df['ITNBR'].str.strip()
        # df['COQTY'] = pd.to_numeric(df['COQTY'])
        # df['QTYSH'] = pd.to_numeric(df['QTYSH'])
        # df['QTYBO'] = pd.to_numeric(df['QTYBO'])
        # 将多列同时转换为数值类型
        df[['COQTY', 'QTYSH', 'QTYBO','OPEN_CO_QTY']] = df[['COQTY', 'QTYSH', 'QTYBO','OPEN_CO_QTY']].apply(pd.to_numeric)
        df['BDTRP#'] = df['BDTRP#'].astype(str)
        # df['OPEN_CO_QTY'] = pd.to_numeric(df['OPEN_CO_QTY'])
        # df['QTSYR'] = pd.to_numeric(df['QTSYR'])
        return df
    except Exception as e:
        print(f"数据处理过程中发生错误: {str(e)}")
        raise


def save_and_format_excel(data, file_path):
    """保存并格式化Excel文件"""
    try:
        # 先保存数据
        data.to_excel(file_path, index=False)

        # 使用win32com格式化
        excel = win32.Dispatch('Excel.Application')
        try:
            excel.Visible = False  # 设置为不可见
            excel.DisplayAlerts = False  # 禁用警告弹窗

            wb = excel.Workbooks.Open(os.path.abspath(file_path))
            ws = wb.ActiveSheet

            # 自动调整列宽
            ws.UsedRange.Columns.AutoFit()

            # 冻结首行
            excel.ActiveWindow.SplitRow = 1
            excel.ActiveWindow.FreezePanes = True

            # 设置标题行格式
            header_range = ws.Range("A1").CurrentRegion.Rows(1)
            header_range.Font.Bold = True
            header_range.Interior.ColorIndex = 15  # 灰色背景

            # 设置所有单元格边框
            # ws.UsedRange.Borders.LineStyle = 1

            # 设置数字格式
            ws.Range("D:D").NumberFormat = "#,##0.00"  # MOHTQ列
            ws.Range("F:F").NumberFormat = "#,##0.00"  # QTSYR列

            # 设置列宽（如果自动调整的不够理想）
            ws.Columns("A:G").ColumnWidth = 15

            # 对齐方式
            # ws.UsedRange.HorizontalAlignment = -4108  # xlCenter

            wb.Save()
            wb.Close()
        except Exception as e:
            print(f"Excel格式化过程中发生错误: {str(e)}")
            raise
        finally:
            try:
                excel.Quit()
            except:
                pass
    except Exception as e:
        print(f"保存Excel文件过程中发生错误: {str(e)}")
        raise


def main():
    start_time = time.time()

    # SQL查询
    query = """
SELECT *
FROM (
    SELECT
        a1.HOUSE,
        a1.ORDNO,
        a1.ITMSQ,
        a1.ITNBR,
        a1.ITDSC,
        a1.ITCLS,
        a1.CCUSNO,
        a1.CSHPNO,
        a1.CUSNM,
        CHAR(a1.TKNDAT) AS Order_Taken_Date,
        CHAR(a1.FRZDAT) AS Original_Request_Date,
        CHAR(a1.RQSDAT) AS CRD,
        CHAR(a1.RQIDT) AS CPD,
        CHAR(a1.MFIDT) AS LoadDate,
        a1.ORDUSR,
        a1.COQTY,
        a1.QTYSH,
        a1.QTYBO,
        a1.OPEN_CO_QTY,
        a1.ALC,
        a1.Product,
        CHAR(x1.BDTRP#) AS BDTRP#,
        x1.BDISEQ,
        x1.BDITQT AS Trip_Qty,
        x1.BDITCT,
        x1.BDITWT,
        x1.BDREF#,
        x1.BHCDAT,
        x1.BHCTIM,
        x1.BHRDAT,
        x1.BHLDAT,
        x1.BHLTIM,
         t9.DSPDAT,t9.DSPTIM,
       TO_DATE(t9.DSPDAT||' '||right('000000'||ltrim(t9.DSPTIM),6), 'yyyymmdd hh24:mi:ss') as Dispatch_Time2,
       DATE(Substr(t9.LSCHDT, 1, 4) || '-'||  Substr(t9.LSCHDT, 5, 2)|| '-' ||substr(t9.LSCHDT, 7, 2)) as Latest_Load_Date,
       t9.CARRIR as CARRIER
    FROM (
        SELECT
            t1.HOUSE,
            t1.ORDNO,
            t1.ITMSQ,
            t1.ITNBR,
            t1.ITDSC,
            t1.ITCLS,
            t1.CCUSNO,
            t3.CUSNM,
            t1.CSHPNO,
            t1.RQIDT,
            t1.MFIDT,
            t1.UNMSR,
            (CASE
                WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'
                WHEN SUBSTR(t1.ITNBR, 1, 4) = '100-' THEN 'CG'
                WHEN SUBSTR(t1.ITNBR, 1, 1) IN ('A', 'B', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W', 'Z') THEN 'CG'
                ELSE 'UPH'
            END) AS Product,
            t2.TKNDAT,
            t2.FRZDAT,
            t2.RQSDAT,
            t2.ORDUSR,
            t1.COQTY,
            t1.QTYSH,
            t1.QTYBO,
            t1.COQTY - t1.QTYSH AS OPEN_CO_QTY,
            (CASE
                WHEN t1.IAFLG = 0 THEN 'N'
                WHEN t1.IAFLG = 2 THEN 'Y'
                ELSE 'Check'
            END) AS ALC
        FROM
            AFILELIB.CODATAN t1
            JOIN AFILELIB.EXTORD t2 ON t2.XORDNO = t1.ORDNO
            JOIN AFILELIB.ACUSMASJ t3 ON t3.CUSNO = t1.CCUSNO
            JOIN AFILELIB.COMAST t4 ON t1.ORDNO = t4.ORDNO
            JOIN AMFLIBA.ITMRVA t5 ON t1.ITNBR = t5.ITNBR AND t1.HOUSE = t5.STID
        WHERE
            t1.HOUSE IN ('335')
            AND t1.IAFLG = 2
            AND t1.COQTY - t1.QTYSH <> 0
    ) AS a1
    LEFT JOIN (
        SELECT
            t1.BDTRP#,
            t1.BDORD#,
            t1.BDISEQ,
            t1.BDITM#,
            t1.BDITMD,
            t1.BDCUS#,
            t1.BDITQT,
            t1.BDITCT,
            t1.BDITWT,
            t1.BDREF#,
            t1.BDCDAT,
            t1.BDCTIM,
            t2.BHTRPS,
            t2.BHCDAT,
            t2.BHCTIM,
            t2.BHRDAT,
            t2.BHLDAT,
            t2.BHLTIM
        FROM
            DISTLIB.BTTRIPD t1
            JOIN DISTLIB.BTTRIPH t2 ON t1.BDTRP# = t2.BHTRP#
        
        WHERE
            t2.BHWHS# IN ('335')
            AND t2.BHLDAT BETWEEN 0 AND 29991231
            AND t2.BHTRPS IN ('A', 'R', 'X')
        ORDER BY
            t1.BDTRP#, t1.BDISEQ, t1.BDITM#
    ) x1 ON a1.ORDNO || a1.ITMSQ || a1.ITNBR || a1.CCUSNO = x1.BDORD# || x1.BDISEQ || x1.BDITM# || x1.BDCUS#
    LEFT JOIN AFILELIB.ATOFILE AS t9 ON x1.BDTRP#=t9.TO#
    
    ORDER BY
        a1.ITNBR, a1.MFIDT
) d1
    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'ahston_demand_{current_time}.xlsx'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        print("正在处理数据...")
        processed_data = process_data(df)

        print("正在保存和格式化Excel文件...")
        save_and_format_excel(processed_data, file_path)

        print(f"Excel文件已成功保存到: {file_path}")

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()
