WITH item_master_info AS (SELECT t1.ITNBR, 
                                         CASE WHEN t2.PICKPUT = 'UPH' THEN 'UPH' ELSE 'CG' END AS product_category 
                                  FROM MasterData_ItemMaster_AFI.ITMRVA AS t1 
                                           LEFT JOIN MasterData_ItemMaster_AFI.ITBEXT AS t2 
                                                     ON t2.ITNBR = t1.ITNBR AND t2.HOUSE = t1.STID 
                                  WHERE t1.STID = '335'),
             base_data AS (SELECT CAST(start_tran_date AS DATE)   AS tran_date, 
                                  DATEPART(HOUR, start_tran_time) AS tran_hour, 
                                  item_number, 
                                  SUM(tran_qty)                   AS picked_qty 
                           FROM Distribution_Warehouse_Wholesale.TranLog 
                           WHERE tran_type LIKE '363' 
                             AND start_tran_date >= '2025-06-01' 
                             AND wh_id = '335' 
                           GROUP BY CAST(start_tran_date AS DATE), 
                                    DATEPART(HOUR, start_tran_time), 
                                    item_number),
             item_first_appearance AS (SELECT tran_date, 
                                              item_number, 
                                              MIN(tran_hour)                                                AS first_hour_1h, 
                                              MIN(CASE WHEN tran_hour BETWEEN 0 AND 1 THEN tran_hour END)   AS first_in_0_1, 
                                              MIN(CASE WHEN tran_hour BETWEEN 2 AND 3 THEN tran_hour END)   AS first_in_2_3, 
                                              MIN(CASE WHEN tran_hour BETWEEN 4 AND 5 THEN tran_hour END)   AS first_in_4_5, 
                                              MIN(CASE WHEN tran_hour BETWEEN 6 AND 7 THEN tran_hour END)   AS first_in_6_7, 
                                              MIN(CASE WHEN tran_hour BETWEEN 8 AND 9 THEN tran_hour END)   AS first_in_8_9, 
                                              MIN(CASE WHEN tran_hour BETWEEN 10 AND 11 THEN tran_hour END) AS first_in_10_11, 
                                              MIN(CASE WHEN tran_hour BETWEEN 12 AND 13 THEN tran_hour END) AS first_in_12_13, 
                                              MIN(CASE WHEN tran_hour BETWEEN 14 AND 15 THEN tran_hour END) AS first_in_14_15, 
                                              MIN(CASE WHEN tran_hour BETWEEN 16 AND 17 THEN tran_hour END) AS first_in_16_17, 
                                              MIN(CASE WHEN tran_hour BETWEEN 18 AND 19 THEN tran_hour END) AS first_in_18_19, 
                                              MIN(CASE WHEN tran_hour BETWEEN 20 AND 21 THEN tran_hour END) AS first_in_20_21, 
                                              MIN(CASE WHEN tran_hour BETWEEN 22 AND 23 THEN tran_hour END) AS first_in_22_23, 
                                              MIN(CASE WHEN tran_hour BETWEEN 0 AND 2 THEN tran_hour END)   AS first_in_0_2, 
                                              MIN(CASE WHEN tran_hour BETWEEN 3 AND 5 THEN tran_hour END)   AS first_in_3_5, 
                                              MIN(CASE WHEN tran_hour BETWEEN 6 AND 8 THEN tran_hour END)   AS first_in_6_8, 
                                              MIN(CASE WHEN tran_hour BETWEEN 9 AND 11 THEN tran_hour END)  AS first_in_9_11, 
                                              MIN(CASE WHEN tran_hour BETWEEN 12 AND 14 THEN tran_hour END) AS first_in_12_14, 
                                              MIN(CASE WHEN tran_hour BETWEEN 15 AND 17 THEN tran_hour END) AS first_in_15_17, 
                                              MIN(CASE WHEN tran_hour BETWEEN 18 AND 20 THEN tran_hour END) AS first_in_18_20, 
                                              MIN(CASE WHEN tran_hour BETWEEN 21 AND 23 THEN tran_hour END) AS first_in_21_23, 
                                              MIN(CASE WHEN tran_hour BETWEEN 0 AND 3 THEN tran_hour END)   AS first_in_0_3, 
                                              MIN(CASE WHEN tran_hour BETWEEN 4 AND 7 THEN tran_hour END)   AS first_in_4_7, 
                                              MIN(CASE WHEN tran_hour BETWEEN 8 AND 11 THEN tran_hour END)  AS first_in_8_11, 
                                              MIN(CASE WHEN tran_hour BETWEEN 12 AND 15 THEN tran_hour END) AS first_in_12_15, 
                                              MIN(CASE WHEN tran_hour BETWEEN 16 AND 19 THEN tran_hour END) AS first_in_16_19, 
                                              MIN(CASE WHEN tran_hour BETWEEN 20 AND 23 THEN tran_hour END) AS first_in_20_23 
                                       FROM base_data 
                                       GROUP BY tran_date, item_number)
        SELECT b.tran_date, 
               b.tran_hour, 
               b.item_number, 
               im.product_category, 
               1       AS sku_count_by_hour, 
               CASE 
                   WHEN (b.tran_hour BETWEEN 0 AND 1 AND b.tran_hour = fa.first_in_0_1) OR 
                        (b.tran_hour BETWEEN 2 AND 3 AND b.tran_hour = fa.first_in_2_3) OR 
                        (b.tran_hour BETWEEN 4 AND 5 AND b.tran_hour = fa.first_in_4_5) OR 
                        (b.tran_hour BETWEEN 6 AND 7 AND b.tran_hour = fa.first_in_6_7) OR 
                        (b.tran_hour BETWEEN 8 AND 9 AND b.tran_hour = fa.first_in_8_9) OR 
                        (b.tran_hour BETWEEN 10 AND 11 AND b.tran_hour = fa.first_in_10_11) OR 
                        (b.tran_hour BETWEEN 12 AND 13 AND b.tran_hour = fa.first_in_12_13) OR 
                        (b.tran_hour BETWEEN 14 AND 15 AND b.tran_hour = fa.first_in_14_15) OR 
                        (b.tran_hour BETWEEN 16 AND 17 AND b.tran_hour = fa.first_in_16_17) OR 
                        (b.tran_hour BETWEEN 18 AND 19 AND b.tran_hour = fa.first_in_18_19) OR 
                        (b.tran_hour BETWEEN 20 AND 21 AND b.tran_hour = fa.first_in_20_21) OR 
                        (b.tran_hour BETWEEN 22 AND 23 AND b.tran_hour = fa.first_in_22_23) 
                       THEN 1 
                   ELSE 0 
                   END AS sku_count_2h, 
               CASE 
                   WHEN (b.tran_hour BETWEEN 0 AND 2 AND b.tran_hour = fa.first_in_0_2) OR 
                        (b.tran_hour BETWEEN 3 AND 5 AND b.tran_hour = fa.first_in_3_5) OR 
                        (b.tran_hour BETWEEN 6 AND 8 AND b.tran_hour = fa.first_in_6_8) OR 
                        (b.tran_hour BETWEEN 9 AND 11 AND b.tran_hour = fa.first_in_9_11) OR 
                        (b.tran_hour BETWEEN 12 AND 14 AND b.tran_hour = fa.first_in_12_14) OR 
                        (b.tran_hour BETWEEN 15 AND 17 AND b.tran_hour = fa.first_in_15_17) OR 
                        (b.tran_hour BETWEEN 18 AND 20 AND b.tran_hour = fa.first_in_18_20) OR 
                        (b.tran_hour BETWEEN 21 AND 23 AND b.tran_hour = fa.first_in_21_23) 
                       THEN 1 
                   ELSE 0 
                   END AS sku_count_3h, 
               CASE 
                   WHEN (b.tran_hour BETWEEN 0 AND 3 AND b.tran_hour = fa.first_in_0_3) OR 
                        (b.tran_hour BETWEEN 4 AND 7 AND b.tran_hour = fa.first_in_4_7) OR 
                        (b.tran_hour BETWEEN 8 AND 11 AND b.tran_hour = fa.first_in_8_11) OR 
                        (b.tran_hour BETWEEN 12 AND 15 AND b.tran_hour = fa.first_in_12_15) OR 
                        (b.tran_hour BETWEEN 16 AND 19 AND b.tran_hour = fa.first_in_16_19) OR 
                        (b.tran_hour BETWEEN 20 AND 23 AND b.tran_hour = fa.first_in_20_23) 
                       THEN 1 
                   ELSE 0 
                   END AS sku_count_4h, 
               b.picked_qty
        FROM base_data b
                 LEFT JOIN item_first_appearance fa
                           ON b.tran_date = fa.tran_date AND b.item_number = fa.item_number
                 LEFT JOIN item_master_info im
                           ON b.item_number = im.ITNBR
        ORDER BY b.tran_date, 
                 b.tran_hour, 
                 b.item_number 