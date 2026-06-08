SELECT 
    t.customer_number,
    MAX(t.bill_to_name) AS customer_name,  -- 取非NULL值（NULL在MAX中会被忽略）
    CAST(LEFT(t.order_number, 7) AS INT) AS trip_nbr,
    MAX(ssi.instruction) AS customer_special_instruction
FROM t_order_c_number AS t
LEFT JOIN t_special_shipping_instructions AS ssi 
    ON t.customer_number = ssi.customer_number
GROUP BY 
    t.customer_number,
    CAST(LEFT(t.order_number, 7) AS INT)
ORDER BY trip_nbr
