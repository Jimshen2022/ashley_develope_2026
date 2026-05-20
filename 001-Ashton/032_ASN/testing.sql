    SELECT
        LTRIM(RTRIM(CAST(item_number      AS VARCHAR(50)))) AS item_number,
        LTRIM(RTRIM(CAST(control_number_2 AS VARCHAR(50)))) AS po_number,
        --LTRIM(RTRIM(CAST(lot_number       AS VARCHAR(50)))) AS lot_number,
        lot_number,
        control_number                                      AS receiving_equipment,
        employee_id                                         AS receiving_employee,
        (start_tran_date + start_tran_time)                 AS receiving_time,
        tran_type
    FROM t_tran_log
    WHERE tran_type IN ('151','951')
      AND lot_number IS NOT NULL
      and lot_number = '548800117482'
      AND lot_number != ''