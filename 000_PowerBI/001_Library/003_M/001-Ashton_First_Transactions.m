
# add new columns
First Transaction = 
IF (
    CALCULATE (
        MIN ( 'Transactions'[Trx_Time] ),
        FILTER (
            ALL ( 'Transactions' ),
            'Transactions'[Empname] = EARLIER ( 'Transactions'[Empname] )
                && 'Transactions'[Trx_Time] <= EARLIER ( 'Transactions'[Trx_Time] )
        )
    ) = 'Transactions'[Trx_Time],
    "F",
    "N"
)



# creat table
First_Transactions = 
SUMMARIZE(
		Transactions,'Transactions'[Date],Transactions[Empname],Transactions[Supervisor],'Transactions'[Department],
		"min",MIN(Transactions[Trx_Time]))
		
		
		
