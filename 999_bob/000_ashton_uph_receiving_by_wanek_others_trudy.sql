with itm as (
    SELECT b.ITNBR, b.HOUSE, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID,
           b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE, b.MFPUS, b.OVRFLWBLDG, b.TOHLD, b.ATPQT
    FROM MasterData_ItemMaster_AFI.ITBEXT b
    WHERE b.HOUSE IN ('335')
),
trx as (
SELECT 
    t1.item_number,
    t1.start_tran_date,
    DATEADD(DAY, 7 - DATEPART(WEEKDAY, t1.start_tran_date), t1.start_tran_date) AS week_saturday_date,
    SUM(CASE 
            WHEN LEFT(t1.lot_number, 4) = '5039' THEN 
                CASE WHEN t1.tran_type = '951' THEN -t1.tran_qty ELSE t1.tran_qty END
            ELSE 0 
        END) AS Wanek_Quantity,
    SUM(CASE 
            WHEN LEFT(t1.lot_number, 4) <> '5039' THEN 
                CASE WHEN t1.tran_type = '951' THEN -t1.tran_qty ELSE t1.tran_qty END
            ELSE 0 
        END) AS Others_Vendor_Quantity
FROM
    Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE
    t1.wh_id IN ('335')
    AND t1.tran_type IN ('151', '183', '951')
    AND t1.start_tran_date BETWEEN
        DATEADD(WEEK, -5, DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE)))
        AND CAST(GETDATE() AS DATE)
GROUP BY t1.item_number, t1.start_tran_date
) 
select t.week_saturday_date,
        t.start_tran_date,
       SUM(t.Wanek_Quantity) AS Wanek_Quantity,
       SUM(t.Others_Vendor_Quantity) AS Others_Vendor_Quantity,
       SUM(t.Wanek_Quantity)+SUM(t.Others_Vendor_Quantity) AS Total_Quantity
from trx as t
left join itm as i on t.item_number = i.ITNBR
where i.PICKPUT = 'UPH'
group by t.week_saturday_date, t.start_tran_date
order by t.start_tran_date