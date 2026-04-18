SELECT
        location_id AS equipment_id,
        CAST(start_tran_date AS DATE) AS tran_date,
        employee_id,
        tran_type,
        description,
        SUM(tran_qty) AS equipment_performed_qty
    FROM t_tran_log
    WHERE tran_type IN ('364', '252', '202','254')
      AND start_tran_date >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
    GROUP BY
        location_id,
        employee_id,
        tran_type,
        description,
        CAST(start_tran_date AS DATE)