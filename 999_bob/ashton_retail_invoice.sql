With trips as (
    select distinct TripNumber,CustomerNumber  
    from Wholesale_SalesHistory_AFI.InvoiceDetail as t
    where 1 = 1 
        and t.CustomerNumber IN (
    '8888000',
    '8888300',
    '8888600',
    '9946600',
    '9955000',
    '9955100',
    '9956600',
    '9966100',
    '9974000',
    '9977400',
    '9981000',
    '9983800',
    '9985500',
    '9989200'
    )
    and t.ShiptoNumber IN (
    '130',
    '164',
    '213',
    '291',
    '306',
    '329',
    '400',
    '458',
    '476',
    '570',
    '600',
    '656',
    '669',
    '738',
    '740',
    '796',
    '904',
    '926',
    '933',
    'C72',
    'D63',
    'E38',
    'G71',
    'J58',
    'J86',
    'K05',
    'M37',
    'M57'
    )
        and t.InvoiceDate > '2026-01-01'
        and t.Warehouse = '335'
)
select 