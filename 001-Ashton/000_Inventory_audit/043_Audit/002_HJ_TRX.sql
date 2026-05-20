with itm as (
    SELECT b.ITNBR, b.HOUSE, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID,
           b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE, b.MFPUS, b.OVRFLWBLDG, b.TOHLD, b.ATPQT
    FROM MasterData_ItemMaster_AFI.ITBEXT b
    WHERE b.HOUSE IN ('335')
),
trx as (
SELECT 
    t1.item_number,
    -- t1.control_number AS received_container_nbr,
    -- t1.control_number_2 as [reference_trip_po_nbr],
    t1.start_tran_date,
    case when left(t1.lot_number,4) = '5039' then 'Wanek'
         else 'Others' end as vendor,
    CASE WHEN t1.tran_type = '951' THEN SUM(-t1.tran_qty)
    ELSE SUM(t1.tran_qty) END   as tran_qty
FROM
    Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE
    t1.wh_id IN ('335')
    AND t1.tran_type IN ('151', '183','951')
    AND t1.start_tran_date BETWEEN
        DATEADD(WEEK, -8, DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE)))
        AND CAST(GETDATE() AS DATE)
GROUP BY t1.item_number, t1.start_tran_date, t1.tran_type, case when left(t1.lot_number,4) = '5039' then 'Wanek'
         else 'Others' end
) 
select t.*
from trx as t
left join itm as i on t.item_number = i.ITNBR
where i.PICKPUT = 'UPH'

