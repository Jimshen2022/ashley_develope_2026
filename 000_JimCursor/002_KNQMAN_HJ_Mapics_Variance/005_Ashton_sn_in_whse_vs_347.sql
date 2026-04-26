/*
serial_no_status
L -- loaded
R -- InWarehouse
S -- Shipped
H -- Hold
O -- orphaned

master status
L -- loaded
R -- InWarehouse
S -- Shipped
H -- Hold

select top 10 *
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
where t1.wh_id = '335'
*/

declare @start_date date = '2022-01-01';
declare @end_date date = getdate();

with trx as (
select 
    t2.item_number,
    t2.tran_type,
    t2.start_tran_date,
    t2.lot_number,
    t2.control_number_2,
    t2.routing_code,
    t2.wh_id AS tranlog_wh_id
from Distribution_Warehouse_Wholesale.TranLog as t2 
where t2.wh_id = '335' 
    and t2.tran_type = '347' 
    and t2.start_tran_date >= @start_date
    and t2.start_tran_date <=  @end_date
),
sn as (
    SELECT t1.wh_id, 
    t1.serial_number, 
    t1.item_number, 
    t1.serial_no_status, 
    t1.master_status, 
    t1.location_id, 
    CAST(t1.received_date AS DATE) AS received_date
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    WHERE t1.wh_id = '335'
    AND t1.serial_no_status != 'O'
    AND t1.master_status != 'S'
)
SELECT t1.*, t2.start_tran_date, t2.tran_type, t2.control_number_2, t2.routing_code, t2.tranlog_wh_id
FROM sn AS t1
join trx AS t2
    ON t1.serial_number = t2.lot_number
WHERE EXISTS (
    SELECT 1
    FROM trx AS t2
    WHERE t1.serial_number = t2.lot_number
)
ORDER BY t2.start_tran_date, t1.item_number, t1.location_id, t1.serial_number