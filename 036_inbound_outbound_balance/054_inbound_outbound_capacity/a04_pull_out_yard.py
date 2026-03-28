import pandas as pd
import pyodbc
import time
import warnings

warnings.filterwarnings('ignore', category=UserWarning, message='.*pandas only supports SQLAlchemy.*')

def run(dfs):
    print("Executing a04_pull_out_yard...")
    start_time = time.time()

    server_name = "AshtonWHJSQLprod"
    database_name = "AAD"
    driver = "{ODBC Driver 17 for SQL Server}"
    conn_str = f"DRIVER={driver};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes;"

    query = """
    WITH tmp_RP_item_order AS (
        SELECT DISTINCT d.item_number, 'RP' AS item_type
        FROM dbo.t_order o WITH (NOLOCK)
        JOIN dbo.t_order_detail d WITH (NOLOCK) ON o.order_number = d.order_number AND o.wh_id = d.wh_id
        WHERE o.type_id = '1159'
    ),
    main_query AS (
        SELECT 
            t.equipment_id, 
            t.state, 
            l.location_name, 
            t_ya_work_q.zone, 
            asn.disposition,
            d.customer_po_number, 
            p.vendor_code, 
            t.entered_yard,
            CASE WHEN l.[type] = 'DRAYAGE' THEN NULL ELSE 'Go To' END AS disposition_unit,
            asn.asn_number, 
            d.item_number,
            SUM(d.quantity_shipped) AS Qty_shipped,
            SUM(d.quantity_received) AS Qty_received,
            SUM(d.quantity_shipped) - SUM(d.quantity_received) AS Qty_remaining,
            asn.trailer_type_name, 
            tc.comments
        FROM dbo.t_trailer t WITH (NOLOCK)
        LEFT JOIN dbo.t_trailer_asn trl WITH (NOLOCK) ON t.trailer_id = trl.trailer_id
        LEFT JOIN dbo.t_asn asn WITH (NOLOCK) ON trl.asn_id = asn.asn_id AND asn.equipment_id = t.equipment_id
        LEFT JOIN dbo.t_ya_work_q WITH (NOLOCK) ON t.trailer_id = t_ya_work_q.trailer_id
            AND t_ya_work_q.status = 'UNASSIGNED' AND t_ya_work_q.type = '52'
        LEFT JOIN (
            SELECT t2.trailer_id, tc1.comments 
            FROM dbo.t_trailer_comments tc1 WITH (NOLOCK)
            INNER JOIN (
                SELECT trailer_id, MAX(sequence) AS maxsequence 
                FROM dbo.t_trailer_comments WITH (NOLOCK) 
                GROUP BY trailer_id
            ) t2 ON tc1.trailer_id = t2.trailer_id AND tc1.sequence = t2.maxsequence
        ) tc ON t.trailer_id = tc.trailer_id
        JOIN dbo.t_asn_detail d WITH (NOLOCK) ON asn.asn_id = d.asn_id
        JOIN dbo.t_ya_location l WITH (NOLOCK) ON t.location_id = l.location_id
        JOIN dbo.t_area a WITH (NOLOCK) ON t.area_id = a.area_id
        JOIN dbo.t_po_master p WITH (NOLOCK) ON d.customer_po_number = p.po_number
        LEFT JOIN dbo.t_item_attributes ita WITH (NOLOCK) ON d.item_number = ita.item_number
        LEFT JOIN tmp_RP_item_order rpi ON d.item_number = rpi.item_number
        WHERE t.status NOT IN ('HISTORY', 'LOST')
        GROUP BY 
            t.equipment_id, t.state, l.location_name, t_ya_work_q.zone, asn.disposition,
            d.customer_po_number, p.vendor_code, t.entered_yard, asn.asn_number, d.item_number,
            asn.trailer_type_name, tc.comments, l.[type], ita.inventory_type, ita.commodity_code, rpi.item_type
    )
    SELECT 
        equipment_id AS [Equipment Id], 
        state AS [State], 
        location_name AS [Location],
        zone AS [Zone], 
        disposition AS [Disposition], 
        customer_po_number AS [PO#],
        vendor_code AS [Vendor#], 
        entered_yard AS [Entered Yard], 
        disposition_unit AS [Schedule to Door],
        asn_number AS [ASN Number], 
        item_number AS [Item Number], 
        Qty_shipped AS [Qty Shipped],
        Qty_received AS [Qty Received], 
        Qty_remaining AS [Qty Remaining], 
        Qty_received AS [Qty Rec],
        Qty_remaining AS [Qty Rem], 
        trailer_type_name AS [Trailer Type], 
        comments AS [Comments]
    FROM main_query 
    ORDER BY [Entered Yard];
    """

    print("Connecting to SQL Server and executing yard query...")
    try:
        conn = pyodbc.connect(conn_str)
        df = pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error connecting or executing query: {e}")
        return
    finally:
        if 'conn' in locals() and conn:
            conn.close()

    for col in ['PO#', 'Item Number', 'ASN Number', 'Vendor#']:
        if col in df.columns:
            df[col] = df[col].astype(str)

    # Store in memory dictionary
    dfs['Yard'] = df

    elapsed_time = time.time() - start_time
    print(f"a04_pull_out_yard completed successfully in {elapsed_time:.2f} seconds.")
