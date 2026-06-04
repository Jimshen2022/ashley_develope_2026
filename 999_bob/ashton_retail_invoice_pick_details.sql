WITH trips AS (
    SELECT DISTINCT TripNumber
    FROM Wholesale_SalesHistory_AFI.InvoiceDetail
    WHERE CustomerNumber IN (
        '8888000','8888300','8888600','9946600','9955000',
        '9955100','9956600','9966100','9974000','9977400',
        '9981000','9983800','9985500','9989200'
    )
    AND ShiptoNumber IN (
        '130','164','213','291','306','329','400','458','476','570',
        '600','656','669','738','740','796','904','926','933',
        'C72','D63','E38','G71','J58','J86','K05','M37','M57'
    )
    AND InvoiceDate > '2026-01-01'
    AND Warehouse = '335'
)
SELECT TOP 10 *
FROM Distribution_Warehouse_Wholesale.tranlog AS l
INNER JOIN trips AS t
    ON CAST(LEFT(l.control_number_2, 7) AS INT) = t.TripNumber
WHERE l.wh_id = '335'
    AND l.tran_type IN ('321', '363')
    AND l.start_tran_date >= '2026-01-01'
ORDER BY l.lot_number, l.start_tran_date, l.start_tran_time