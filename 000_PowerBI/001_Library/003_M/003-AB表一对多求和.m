2WK Trip Demand_2 = 
IF (
    ISBLANK (
        CALCULATE (
            SUM ( 'CO_TRIP'[TRIP_QTY] ),
            USERELATIONSHIP ( 'Fct_Data'[item_number], 'CO_TRIP'[ITNBR] )
        )
    ),
    0,
    CALCULATE (
        SUM ( 'CO_TRIP'[TRIP_QTY] ),
        USERELATIONSHIP ( 'Fct_Data'[item_number], 'CO_TRIP'[ITNBR] )
    )
)