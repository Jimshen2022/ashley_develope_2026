-- 使用CTE和LEFT JOIN优化查询 -- Oct.18.2024 by Jim,Shen
WITH BaseData AS (SELECT t1.wh_id
                       , t1.tran_type
                       , t1.description
                       , t1.start_tran_date
                       , CAST(t1.start_tran_time AS TIME(0))                                                      as start_tran_time
                       , t1.end_tran_date
                       , CAST(t1.end_tran_time AS TIME(0))                                                        as end_tran_time
                       , t1.employee_id
                       , t1.control_number
                       , t1.line_number
                       , t1.control_number_2                                                                      as Reference
                       , SUBSTRING(t1.control_number_2, PATINDEX('%[^0]%', t1.control_number_2),
                                   CHARINDEX('-', t1.control_number_2) -
                                   PATINDEX('%[^0]%', t1.control_number_2))                                       as tripNbr
                       , t1.routing_code                                                                          as ContainerNbr
                       , SUBSTRING(t1.control_number_2, PATINDEX('%[^0]%', t1.control_number_2),
                                   CHARINDEX('-', t1.control_number_2) -
                                   PATINDEX('%[^0]%', t1.control_number_2)) + '_' + t1.routing_code   as Container#
                       , t1.hu_id
                       , t1.item_number
                       , CAST(t1.lot_number as VARCHAR(20))                                                       AS SN
                       , t1.uom
                       , t1.tran_qty
                       , t1.location_id AS 'from Location'
                       , t1.location_id_2 AS 'To Location'
                       , t1.employee_id_2
                       , t2.ITCLS
                       , t2.B2Z95S                                                                                AS UnitCubes
                       , t2.B2Z95S * t1.tran_qty                                                                  as Cubes
                       , t2.ITDSC
                       , CASE
                             WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
                             WHEN t1.item_number LIKE '100-%' THEN 'CG'
                             WHEN SUBSTRING(LTRIM(RTRIM(t1.item_number)), 1, 1) IN
                                  ('1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
                             WHEN SUBSTRING(LTRIM(RTRIM(t1.item_number)), 1, 1) = 'A' AND t2.B2Z95S >= 0.3 THEN 'CG'
                             WHEN SUBSTRING(LTRIM(RTRIM(t1.item_number)), 1, 1) IN ('A', 'L', 'R', 'Q') THEN 'ACCESSORY'
                             WHEN LEN(LTRIM(RTRIM(t1.item_number))) = 6 AND
                                  SUBSTRING(LTRIM(RTRIM(t1.item_number)), 1, 1) = 'M' THEN 'ACCESSORY'
                             ELSE 'CG'
        END                                                                                                       AS Product
                  FROM (SELECT * FROM Distribution_Warehouse_Wholesale.TranLog AS a where a.wh_id in ('335')) AS t1
                           LEFT JOIN
                       (SELECT a.STID, a.ITNBR, a.ITCLS, a.ITDSC, a.B2Z95S
                        FROM MasterData_ItemMaster_AFI.ITMRVA as a
                        WHERE a.STID = '335') as t2 ON t2.ITNBR = t1.item_number
                  WHERE t1.start_tran_date >= '2024-10-01'
                    AND t1.tran_type = '347'),
    ContainerTypes AS (
    SELECT
        Container#,
        CASE WHEN COUNT(DISTINCT Product) = 1 THEN 'None-Mixed' ELSE 'Mixed' END AS ContainerType
    FROM
        BaseData
    GROUP BY
        Container#
)
------------------------main query ------------------------------------
select  bd.wh_id
      , bd.tran_type
      , bd.description
      , bd.start_tran_date
      , bd.start_tran_time
      , bd.employee_id
      , bd.control_number
      , bd.line_number
      , bd.Reference
      , bd.tripNbr
      , bd.ContainerNbr
      , bd.Container#
      , bd.item_number
      , bd.SN
      , bd.uom
      , bd.tran_qty
       , bd.employee_id_2
       , bd.ITCLS
       , bd.Cubes
       , bd.ITDSC
      , bd.Product
      , ct.ContainerType
from BaseData as bd
    left join ContainerTypes as ct ON bd.Container# = ct.Container#