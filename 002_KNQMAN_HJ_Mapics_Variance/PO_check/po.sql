/*-- PO 
select top 10 * from t_po_master where item_number = 'L430914'
select top 10 * from t_po_detail where item_number = 'L430914' AND po_number = 'P2WCN65'

select * from t_po_detail where  po_number = 'P2WMW85'
select * from t_tran_log where  control_number_2 = 'P2WMW85'

*/

SELECT
    CAST(start_tran_date AS DATE) AS start_tran_date,
    item_number,
    control_number,
    control_number_2,
    tran_type,
    SUM(
        CASE 
            WHEN tran_type = '951' THEN -tran_qty
            ELSE tran_qty
        END
    ) AS tran_qty,
    SUM(
        SUM(
            CASE 
                WHEN tran_type = '951' THEN -tran_qty
                ELSE tran_qty
            END
        )
    ) OVER (
        PARTITION BY  control_number_2
    ) AS total_tran_qty
FROM t_tran_log
WHERE control_number_2 = 'P2WMW85'
  AND tran_type IN ('151', '951')
GROUP BY
    start_tran_date,
    item_number,
    control_number,
    control_number_2,
    tran_type
ORDER BY
    item_number,
    control_number_2,
    tran_type;
